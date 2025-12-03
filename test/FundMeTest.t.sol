// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/3-fund-me/FundMe.sol";
import {PriceConverter} from "../src/3-fund-me/PriceConverter.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

/**
 * @title FundMeTest
 * @notice Comprehensive tests for the FundMe contract
 * @dev Tests all functionality including funding, withdrawing, and access control
 */
contract FundMeTest is Test {
    FundMe public fundMe;
    MockV3Aggregator public mockPriceFeed;

    // Test users
    address public owner;
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    // Allow test contract to receive ETH
    receive() external payable {}

    // Constants for testing
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; // $2000 per ETH
    uint256 public constant SEND_VALUE = 0.1 ether; // 0.1 ETH
    uint256 public constant STARTING_BALANCE = 10 ether;

    /**
     * @notice setUp runs before each test
     */
    function setUp() public {
        // Deploy mock price feed
        mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);

        // Deploy FundMe contract
        fundMe = new FundMe(address(mockPriceFeed));
        owner = fundMe.i_owner();

        // Give test users some ETH
        vm.deal(user1, STARTING_BALANCE);
        vm.deal(user2, STARTING_BALANCE);
    }

    // ============== CONSTRUCTOR TESTS ==============

    /**
     * @notice Test that owner is set correctly
     */
    function test_OwnerIsSetCorrectly() public view {
        assertEq(fundMe.i_owner(), address(this));
    }

    /**
     * @notice Test that price feed is set correctly
     */
    function test_PriceFeedIsSetCorrectly() public view {
        address priceFeedAddress = address(fundMe.s_priceFeed());
        assertEq(priceFeedAddress, address(mockPriceFeed));
    }

    // ============== FUNDING TESTS ==============

    /**
     * @notice Test that funding fails without enough ETH
     */
    function test_RevertWhen_FundingWithoutEnoughETH() public {
        vm.expectRevert(FundMe.FundMe__InsufficientFunding.selector);
        fundMe.fund();
    }

    /**
     * @notice Test funding with sufficient ETH
     */
    function test_FundUpdatesFundedDataStructure() public {
        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(user1);
        assertEq(amountFunded, SEND_VALUE);
    }

    /**
     * @notice Test that funder is added to array
     */
    function test_AddsFunderToArrayOfFunders() public {
        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, user1);
    }

    /**
     * @notice Test multiple fundings from same address
     */
    function test_MultipleFundingsFromSameAddress() public {
        vm.startPrank(user1);
        fundMe.fund{value: SEND_VALUE}();
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(user1);
        assertEq(amountFunded, SEND_VALUE * 2);

        // Should still only be one entry in funders array
        assertEq(fundMe.getNumberOfFunders(), 1);
    }

    /**
     * @notice Test multiple different funders
     */
    function test_MultipleFunders() public {
        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(user2);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getNumberOfFunders(), 2);
        assertEq(fundMe.getFunder(0), user1);
        assertEq(fundMe.getFunder(1), user2);
    }

    /**
     * @notice Test contract balance increases
     */
    function test_ContractBalanceIncreases() public {
        uint256 initialBalance = fundMe.getBalance();

        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        uint256 finalBalance = fundMe.getBalance();
        assertEq(finalBalance, initialBalance + SEND_VALUE);
    }

    // ============== PRICE FEED TESTS ==============

    /**
     * @notice Test that minimum USD requirement works correctly
     */
    function test_MinimumUSDRequirement() public {
        // $2000 per ETH, need $5 minimum
        // $5 / $2000 = 0.0025 ETH
        uint256 minimumETH = 0.0025 ether;

        // Sending less than minimum should fail
        vm.prank(user1);
        vm.expectRevert(FundMe.FundMe__InsufficientFunding.selector);
        fundMe.fund{value: minimumETH - 1}();

        // Sending exactly minimum should work
        vm.prank(user1);
        fundMe.fund{value: minimumETH}();

        assertEq(fundMe.getAddressToAmountFunded(user1), minimumETH);
    }

    /**
     * @notice Test price changes affect minimum requirement
     */
    function test_PriceChangeAffectsMinimum() public {
        // At $2000, 0.0025 ETH = $5
        vm.prank(user1);
        fundMe.fund{value: 0.0025 ether}();

        // Change price to $1000
        mockPriceFeed.updateAnswer(1000e8);

        // Now need 0.005 ETH for $5
        vm.prank(user2);
        vm.expectRevert(FundMe.FundMe__InsufficientFunding.selector);
        fundMe.fund{value: 0.0025 ether}(); // Too little now

        vm.prank(user2);
        fundMe.fund{value: 0.005 ether}(); // This should work

        assertEq(fundMe.getAddressToAmountFunded(user2), 0.005 ether);
    }

    // ============== WITHDRAW TESTS ==============

    /**
     * @notice Test withdraw with single funder
     */
    function test_WithdrawWithSingleFunder() public {
        // Arrange
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance + SEND_VALUE
        );
    }

    /**
     * @notice Test withdraw with multiple funders
     */
    function test_WithdrawWithMultipleFunders() public {
        // Arrange - add multiple funders
        uint256 numberOfFunders = 5;
        for (uint256 i = 1; i <= numberOfFunders; i++) {
            address funder = address(uint160(i));
            vm.deal(funder, STARTING_BALANCE);
            vm.prank(funder);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            owner.balance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    /**
     * @notice Test that withdraw resets funders array
     */
    function test_WithdrawResetsFundersArray() public {
        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(owner);
        fundMe.withdraw();

        assertEq(fundMe.getNumberOfFunders(), 0);
    }

    /**
     * @notice Test that withdraw resets mapping
     */
    function test_WithdrawResetsMapping() public {
        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(owner);
        fundMe.withdraw();

        assertEq(fundMe.getAddressToAmountFunded(user1), 0);
    }

    /**
     * @notice Test that only owner can withdraw
     */
    function test_RevertWhen_NonOwnerWithdraws() public {
        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(user1);
        vm.expectRevert(FundMe.FundMe__NotOwner.selector);
        fundMe.withdraw();
    }

    // ============== CHEAPER WITHDRAW TESTS ==============

    /**
     * @notice Test cheaper withdraw with single funder
     */
    function test_CheaperWithdrawWithSingleFunder() public {
        uint256 startingOwnerBalance = owner.balance;

        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(owner);
        fundMe.cheaperWithdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, startingOwnerBalance + SEND_VALUE);
    }

    /**
     * @notice Test cheaper withdraw with multiple funders
     */
    function test_CheaperWithdrawWithMultipleFunders() public {
        uint256 numberOfFunders = 5;
        for (uint256 i = 1; i <= numberOfFunders; i++) {
            address funder = address(uint160(i));
            vm.deal(funder, STARTING_BALANCE);
            vm.prank(funder);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(owner);
        fundMe.cheaperWithdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, startingOwnerBalance + startingFundMeBalance);
    }

    /**
     * @notice Compare gas costs between withdraw and cheaperWithdraw
     */
    function test_CompareWithdrawGasCosts() public {
        // Add multiple funders
        uint256 numberOfFunders = 10;
        for (uint256 i = 1; i <= numberOfFunders; i++) {
            address funder = address(uint160(i));
            vm.deal(funder, STARTING_BALANCE);
            vm.prank(funder);
            fundMe.fund{value: SEND_VALUE}();
        }

        // Test regular withdraw gas
        uint256 gasBefore1 = gasleft();
        vm.prank(owner);
        fundMe.withdraw();
        uint256 gasAfter1 = gasleft();
        uint256 regularGas = gasBefore1 - gasAfter1;

        // Reset and test cheaper withdraw gas
        for (uint256 i = 1; i <= numberOfFunders; i++) {
            address funder = address(uint160(i));
            vm.prank(funder);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 gasBefore2 = gasleft();
        vm.prank(owner);
        fundMe.cheaperWithdraw();
        uint256 gasAfter2 = gasleft();
        uint256 cheaperGas = gasBefore2 - gasAfter2;

        console.log("Regular withdraw gas:", regularGas);
        console.log("Cheaper withdraw gas:", cheaperGas);
        console.log("Gas saved:", regularGas - cheaperGas);

        assertTrue(cheaperGas < regularGas, "Cheaper withdraw should use less gas");
    }

    // ============== RECEIVE & FALLBACK TESTS ==============

    /**
     * @notice Test receive function
     */
    function test_ReceiveFunctionWorks() public {
        vm.prank(user1);
        (bool success,) = address(fundMe).call{value: SEND_VALUE}("");

        assertTrue(success);
        assertEq(fundMe.getAddressToAmountFunded(user1), SEND_VALUE);
    }

    /**
     * @notice Test fallback function
     */
    function test_FallbackFunctionWorks() public {
        vm.prank(user1);
        (bool success,) = address(fundMe).call{value: SEND_VALUE}("trigger fallback");

        assertTrue(success);
        assertEq(fundMe.getAddressToAmountFunded(user1), SEND_VALUE);
    }

    // ============== VIEW FUNCTION TESTS ==============

    /**
     * @notice Test all view functions
     */
    function test_ViewFunctions() public {
        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        // Test getOwner
        assertEq(fundMe.getOwner(), owner);

        // Test getPriceFeed
        assertEq(address(fundMe.getPriceFeed()), address(mockPriceFeed));

        // Test getBalance
        assertEq(fundMe.getBalance(), SEND_VALUE);

        // Test getNumberOfFunders
        assertEq(fundMe.getNumberOfFunders(), 1);

        // Test getFunder
        assertEq(fundMe.getFunder(0), user1);

        // Test getAddressToAmountFunded
        assertEq(fundMe.getAddressToAmountFunded(user1), SEND_VALUE);
    }

    // ============== FUZZ TESTS ==============

    /**
     * @notice Fuzz test funding with various amounts
     */
    function testFuzz_FundingWithVariousAmounts(uint256 amount) public {
        // Bound amount to reasonable range
        amount = bound(amount, 0.003 ether, 100 ether);

        vm.deal(user1, amount);
        vm.prank(user1);
        fundMe.fund{value: amount}();

        assertEq(fundMe.getAddressToAmountFunded(user1), amount);
    }

    // ============== INTEGRATION TESTS ==============

    /**
     * @notice Test full lifecycle: fund, withdraw, fund again
     */
    function test_FullLifecycle() public {
        // Round 1: Fund
        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(user2);
        fundMe.fund{value: SEND_VALUE * 2}();

        assertEq(fundMe.getNumberOfFunders(), 2);

        // Withdraw
        vm.prank(owner);
        fundMe.withdraw();

        assertEq(fundMe.getNumberOfFunders(), 0);
        assertEq(address(fundMe).balance, 0);

        // Round 2: Fund again
        vm.prank(user1);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getNumberOfFunders(), 1);
        assertEq(fundMe.getAddressToAmountFunded(user1), SEND_VALUE);
    }
}

/*
 * TEST PATTERNS DEMONSTRATED:
 *
 * 1. ARRANGE-ACT-ASSERT:
 *    - Arrange: Set up test state
 *    - Act: Execute the function being tested
 *    - Assert: Verify the expected outcome
 *
 * 2. FOUNDRY CHEATCODES:
 *    - vm.prank(address): Set msg.sender for next call
 *    - vm.startPrank(address): Set msg.sender for multiple calls
 *    - vm.stopPrank(): Stop the prank
 *    - vm.deal(address, amount): Give address some ETH
 *    - vm.expectRevert(): Expect next call to revert
 *    - makeAddr(string): Create labeled test address
 *
 * 3. TESTING PATTERNS:
 *    - Test happy paths (things that should work)
 *    - Test sad paths (things that should fail)
 *    - Test edge cases (boundary conditions)
 *    - Test access control (who can do what)
 *    - Test state changes (verify storage updates)
 *    - Fuzz testing (test with random inputs)
 *
 * 4. GAS TESTING:
 *    - Use gasleft() to measure gas consumption
 *    - Compare different implementations
 *    - Validate optimization claims
 *
 * RUNNING TESTS:
 *
 * forge test                                      - Run all tests
 * forge test --match-contract FundMeTest          - Run this test file
 * forge test --match-test test_Withdraw           - Run specific test
 * forge test --gas-report                         - Show gas usage
 * forge test -vvvv                                - Very verbose output
 * forge test --fork-url $SEPOLIA_RPC_URL          - Test against real network
 */
