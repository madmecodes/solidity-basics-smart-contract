// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/3-fund-me/FundMe.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

/**
 * @title DeployFundMe
 * @notice Deployment script for FundMe contract
 * @dev Handles both local (with mocks) and testnet deployment
 */
contract DeployFundMe is Script {
    // Chainlink Price Feed addresses
    address constant SEPOLIA_ETH_USD = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    // Mock price feed parameters
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8; // $2000

    function run() external returns (FundMe, address) {
        address priceFeed;

        // Determine if we're on a local chain or testnet
        if (block.chainid == 31337) {
            // Local Anvil chain - deploy mock
            vm.startBroadcast();
            MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
            priceFeed = address(mockPriceFeed);
            vm.stopBroadcast();
        } else if (block.chainid == 11155111) {
            // Sepolia testnet - use real Chainlink feed
            priceFeed = SEPOLIA_ETH_USD;
        } else {
            revert("Unsupported chain - add price feed address for this chain");
        }

        // Deploy FundMe contract
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();

        return (fundMe, priceFeed);
    }
}

/*
 * DEPLOYMENT COMMANDS:
 *
 * 1. LOCAL (Anvil):
 *    Terminal 1: anvil
 *    Terminal 2: forge script script/DeployFundMe.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
 *
 * 2. SEPOLIA TESTNET:
 *    source .env
 *    forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
 *
 * INTERACTING WITH DEPLOYED CONTRACT:
 *
 * 1. Fund the contract (send 0.01 ETH):
 *    cast send <FUNDME_ADDRESS> "fund()" --value 0.01ether --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
 *
 * 2. Check your funded amount:
 *    cast call <FUNDME_ADDRESS> "getAddressToAmountFunded(address)(uint256)" <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
 *
 * 3. Check contract balance:
 *    cast balance <FUNDME_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
 *
 * 4. Withdraw (only owner):
 *    cast send <FUNDME_ADDRESS> "withdraw()" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
 *
 * 5. View functions (free, no transaction):
 *    cast call <FUNDME_ADDRESS> "getOwner()(address)" --rpc-url $SEPOLIA_RPC_URL
 *    cast call <FUNDME_ADDRESS> "getNumberOfFunders()(uint256)" --rpc-url $SEPOLIA_RPC_URL
 */
