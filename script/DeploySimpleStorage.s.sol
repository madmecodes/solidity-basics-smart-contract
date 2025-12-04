// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/1-simple-storage/SimpleStorage.sol";

/**
 * @title DeploySimpleStorage
 * @notice Deployment script for SimpleStorage contract
 * @dev Run with: forge script script/DeploySimpleStorage.s.sol --rpc-url <RPC_URL> --broadcast
 */
contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        // vm.startBroadcast() - everything after this is sent as a transaction
        vm.startBroadcast();

        // Deploy the SimpleStorage contract
        SimpleStorage simpleStorage = new SimpleStorage();

        vm.stopBroadcast();

        return simpleStorage;
    }
}

/*
 * DEPLOYMENT COMMANDS:
 *
 * 1. LOCAL (Anvil):
 *    Terminal 1: anvil
 *    Terminal 2: forge script script/DeploySimpleStorage.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
 *
 * 2. SEPOLIA TESTNET:
 *    source .env
 *    forge script script/DeploySimpleStorage.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
 *
 * AFTER DEPLOYMENT:
 * - Copy the deployed contract address from the output
 * - Use cast to interact with it (see examples below)
 */
