// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Import our PriceConverter library
import {PriceConverter} from "./PriceConverter.sol";
// Import Chainlink's AggregatorV3Interface
import {AggregatorV3Interface} from
    "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title FundMe
 * @author Your Name
 * @notice A contract for crowd funding that accepts ETH and tracks funders
 * @dev Demonstrates: payable, msg.value, modifiers, libraries, oracles, for loops, receive/fallback
 */
contract FundMe {
    // ============== TYPE DECLARATIONS ==============

    // Attach the PriceConverter library to uint256
    // This allows us to call library functions on uint256 variables
    // Example: msg.value.getConversionRate(s_priceFeed)
    using PriceConverter for uint256;

    // ============== STATE VARIABLES ==============

    // Minimum USD amount required to fund (with 18 decimals)
    // $5 = 5 * 1e18 = 5000000000000000000
    uint256 public constant MINIMUM_USD = 5 * 1e18;

    // Array to track all funders
    address[] public s_funders;

    // Mapping to track how much each address has funded
    mapping(address => uint256) public s_addressToAmountFunded;

    // The owner of the contract (who can withdraw funds)
    address public immutable i_owner;

    // Chainlink Price Feed for ETH/USD
    AggregatorV3Interface public s_priceFeed;

    // ============== ERRORS ==============

    // Custom error for unauthorized access (more gas efficient than require with string)
    error FundMe__NotOwner();
    error FundMe__InsufficientFunding();
    error FundMe__WithdrawFailed();

    // ============== MODIFIERS ==============

    /**
     * @notice Restricts function access to only the contract owner
     * @dev Modifier is executed before the function body
     */
    modifier onlyOwner() {
        // Check if the caller is the owner
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _; // Continue executing the function
    }

    // ============== CONSTRUCTOR ==============

    /**
     * @notice Constructor runs once when contract is deployed
     * @dev Sets the deployer as owner and stores the price feed address
     * @param priceFeed The address of the Chainlink ETH/USD Price Feed
     */
    constructor(address priceFeed) {
        i_owner = msg.sender; // Set deployer as owner
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // ============== RECEIVE & FALLBACK ==============

    /**
     * @notice Called when ETH is sent directly to contract with no data
     * @dev Automatically routes to fund() function
     */
    receive() external payable {
        fund();
    }

    /**
     * @notice Called when ETH is sent with data that doesn't match any function
     * @dev Also routes to fund() function
     */
    fallback() external payable {
        fund();
    }

    // ============== PUBLIC FUNCTIONS ==============

    /**
     * @notice Fund the contract with ETH
     * @dev Requires minimum USD value, tracks funder and amount
     * Function must be payable to receive ETH
     */
    function fund() public payable {
        // msg.value = amount of Wei sent with the transaction

        // Get USD value of sent ETH using our library
        // This is equivalent to: PriceConverter.getConversionRate(msg.value, s_priceFeed)
        uint256 usdValue = msg.value.getConversionRate(s_priceFeed);

        // Require minimum USD value
        // If condition fails, transaction reverts and gas is refunded
        if (usdValue < MINIMUM_USD) {
            revert FundMe__InsufficientFunding();
        }

        // Add funder to array (if they haven't funded before)
        // Check if this is a new funder
        if (s_addressToAmountFunded[msg.sender] == 0) {
            s_funders.push(msg.sender);
        }

        // Track the amount funded
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    /**
     * @notice Withdraw all funds from the contract (only owner)
     * @dev Resets all funders' balances and empties the funders array
     */
    function withdraw() public onlyOwner {
        // Reset all funders' balances using a for loop
        // Start at index 0, go while i < length, increment i each time
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // Reset the funders array to a new empty array
        s_funders = new address[](0);

        // Transfer all ETH in contract to owner
        // There are 3 ways to send ETH: transfer, send, call
        // call is the recommended way (most flexible and safe)

        // Call returns two values: success boolean and returned data
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");

        // Revert if transfer failed
        if (!callSuccess) {
            revert FundMe__WithdrawFailed();
        }
    }

    /**
     * @notice More gas-efficient withdraw function
     * @dev Same as withdraw but optimized to save gas
     */
    function cheaperWithdraw() public onlyOwner {
        // Reading from storage is expensive
        // Read funders array once into memory (cheaper)
        address[] memory funders = s_funders;

        // Loop through memory array (cheaper than storage)
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // Reset storage array
        s_funders = new address[](0);

        // Transfer funds
        (bool success,) = i_owner.call{value: address(this).balance}("");
        if (!success) {
            revert FundMe__WithdrawFailed();
        }
    }

    // ============== VIEW / PURE FUNCTIONS ==============

    /**
     * @notice Get the amount a specific address has funded
     * @param fundingAddress The address to check
     * @return The amount funded by that address
     */
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    /**
     * @notice Get a funder by index
     * @param index The index in the funders array
     * @return The address at that index
     */
    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    /**
     * @notice Get the total number of funders
     * @return The length of the funders array
     */
    function getNumberOfFunders() public view returns (uint256) {
        return s_funders.length;
    }

    /**
     * @notice Get the owner of the contract
     * @return The owner's address
     */
    function getOwner() public view returns (address) {
        return i_owner;
    }

    /**
     * @notice Get the price feed address
     * @return The Chainlink Price Feed address
     */
    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    /**
     * @notice Get the contract's current balance
     * @return The balance in Wei
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

/*
 * KEY CONCEPTS SUMMARY:
 *
 * 1. PAYABLE FUNCTIONS:
 *    - Functions marked 'payable' can receive ETH
 *    - msg.value contains the amount of Wei sent
 *    - 1 ETH = 1,000,000,000,000,000,000 Wei
 *
 * 2. MODIFIERS:
 *    - Reusable code that runs before function execution
 *    - Used for access control, validation, etc.
 *    - '_' represents where the function body executes
 *    - Can have multiple modifiers on one function
 *
 * 3. CONSTRUCTOR:
 *    - Runs exactly once when contract is deployed
 *    - Sets initial state (owner, config, etc.)
 *    - Can have parameters for deployment configuration
 *
 * 4. IMMUTABLE & CONSTANT:
 *    - constant: Value set at compile time, cannot change
 *    - immutable: Value set at deployment time, cannot change after
 *    - Both save gas by not using storage slots
 *    - Naming: CONSTANT_VAR for constants, i_immutableVar for immutable
 *
 * 5. CUSTOM ERRORS:
 *    - More gas efficient than require with strings
 *    - Error names should be descriptive
 *    - Convention: ContractName__ErrorDescription
 *
 * 6. RECEIVE & FALLBACK:
 *    - receive(): Called when ETH sent with no data
 *    - fallback(): Called when no function matches or ETH sent with data
 *    - Both must be external payable
 *    - Useful for accepting direct ETH transfers
 *
 * 7. FOR LOOPS:
 *    - for (initialization; condition; increment) { body }
 *    - Be careful with loops over dynamic arrays (gas limits!)
 *    - Consider gas costs for large arrays
 *
 * 8. THREE WAYS TO SEND ETH:
 *    - transfer: 2300 gas, reverts on failure
 *    - send: 2300 gas, returns bool
 *    - call: forwards all gas, returns bool - RECOMMENDED
 *
 * 9. CHAINLINK ORACLES:
 *    - Provide real-world data to smart contracts
 *    - Decentralized network of nodes
 *    - Price Feeds for crypto prices
 *    - Different addresses per network
 *
 * 10. LIBRARIES:
 *     - Reusable code without state
 *     - 'using LibraryName for Type' attaches functions to types
 *     - Called like: value.libraryFunction()
 *
 * GAS OPTIMIZATION TECHNIQUES:
 * - Use constants and immutable for values that don't change
 * - Use custom errors instead of require strings
 * - Cache array length in loops
 * - Read from memory instead of storage when possible
 * - Use cheaper withdraw when possible
 *
 * SECURITY CONSIDERATIONS:
 * - Always use onlyOwner for sensitive functions
 * - Check return values of call
 * - Use custom errors to save gas
 * - Be aware of reentrancy (not shown here but important!)
 *
 * NAMING CONVENTIONS (used in this project):
 * - s_variableName: storage variable
 * - i_variableName: immutable variable
 * - CONSTANT_NAME: constant variable
 * - _localVariable: local/function parameter
 */
