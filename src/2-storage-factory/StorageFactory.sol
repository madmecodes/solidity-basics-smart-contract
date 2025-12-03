// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ============== IMPORTS ==============
// We can import contracts from other files
// This allows us to use the SimpleStorage contract in this file
import {SimpleStorage} from "../1-simple-storage/SimpleStorage.sol";

/**
 * @title StorageFactory
 * @author Your Name
 * @notice This contract demonstrates deploying and interacting with other contracts
 * @dev Covers: imports, contract deployment, contract interaction, ABI, composability
 */
contract StorageFactory {
    // ============== STATE VARIABLES ==============

    // Array to keep track of all SimpleStorage contracts we deploy
    SimpleStorage[] public listOfSimpleStorageContracts;

    // ============== FUNCTIONS ==============

    /**
     * @notice Deploy a new SimpleStorage contract
     * @dev Uses the 'new' keyword to deploy a contract from within this contract
     */
    function createSimpleStorageContract() public {
        // Deploy a new SimpleStorage contract
        // The 'new' keyword creates a new contract instance
        SimpleStorage newSimpleStorage = new SimpleStorage();

        // Add the new contract to our array
        listOfSimpleStorageContracts.push(newSimpleStorage);
    }

    /**
     * @notice Store a favorite number in a specific SimpleStorage contract
     * @dev This demonstrates how to interact with deployed contracts
     * @param _simpleStorageIndex The index of the SimpleStorage contract in our array
     * @param _newSimpleStorageNumber The number to store
     */
    function sfStore(uint256 _simpleStorageIndex, uint256 _newSimpleStorageNumber) public {
        // To interact with a contract, we need two things:
        // 1. The contract's address
        // 2. The contract's ABI (Application Binary Interface)
        //
        // We already have both because we imported SimpleStorage:
        // - The type SimpleStorage gives us the ABI
        // - Our array stores the deployed contract instances (which have addresses)

        // Get the SimpleStorage contract at the specified index
        SimpleStorage mySimpleStorage = listOfSimpleStorageContracts[_simpleStorageIndex];

        // Call the store function on that contract
        mySimpleStorage.store(_newSimpleStorageNumber);
    }

    /**
     * @notice Get a favorite number from a specific SimpleStorage contract
     * @dev View function to read from another contract
     * @param _simpleStorageIndex The index of the SimpleStorage contract in our array
     * @return The favorite number stored in that contract
     */
    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256) {
        // Get the SimpleStorage contract at the specified index
        SimpleStorage mySimpleStorage = listOfSimpleStorageContracts[_simpleStorageIndex];

        // Call the retrieve function on that contract
        return mySimpleStorage.retrieve();
    }

    /**
     * @notice Get the total number of SimpleStorage contracts deployed
     * @return The length of the listOfSimpleStorageContracts array
     */
    function getNumberOfContracts() public view returns (uint256) {
        return listOfSimpleStorageContracts.length;
    }

    /**
     * @notice Get the address of a specific SimpleStorage contract
     * @dev This shows that contracts have addresses just like regular accounts
     * @param _index The index of the contract in our array
     * @return The address of the SimpleStorage contract
     */
    function getContractAddress(uint256 _index) public view returns (address) {
        // Convert the contract instance to an address
        return address(listOfSimpleStorageContracts[_index]);
    }

    /**
     * @notice Add a person to a specific SimpleStorage contract
     * @dev Demonstrates calling more complex functions on deployed contracts
     * @param _simpleStorageIndex The index of the SimpleStorage contract
     * @param _name The person's name
     * @param _favoriteNumber The person's favorite number
     */
    function sfAddPerson(
        uint256 _simpleStorageIndex,
        string memory _name,
        uint256 _favoriteNumber
    ) public {
        SimpleStorage mySimpleStorage = listOfSimpleStorageContracts[_simpleStorageIndex];
        mySimpleStorage.addPerson(_name, _favoriteNumber);
    }
}

/*
 * KEY CONCEPTS SUMMARY:
 *
 * 1. IMPORTS:
 *    - Import contracts from other files using: import {ContractName} from "path"
 *    - Can also use: import "path" to import everything
 *    - Named imports are preferred for clarity: import {A, B} from "path"
 *
 * 2. DEPLOYING CONTRACTS:
 *    - Use the 'new' keyword: ContractType variableName = new ContractType()
 *    - The deploying contract becomes the owner/deployer of the new contract
 *    - Each deployment costs gas
 *
 * 3. CONTRACT INTERACTION (ABI):
 *    - To interact with a contract, you need:
 *      a) The contract's ADDRESS (where it's deployed)
 *      b) The contract's ABI (its interface/function signatures)
 *    - When you import a contract, you get its ABI automatically
 *    - The deployed instance gives you the address
 *
 * 4. COMPOSABILITY:
 *    - Contracts can create and interact with other contracts
 *    - This is the foundation of DeFi and complex blockchain applications
 *    - One contract can orchestrate many others (factory pattern)
 *
 * 5. CONTRACT ADDRESSES:
 *    - Every deployed contract has an address
 *    - Contracts can have addresses just like externally owned accounts (EOAs)
 *    - Contract addresses are deterministic (based on deployer address and nonce)
 *
 * WORKFLOW:
 * 1. User calls createSimpleStorageContract()
 * 2. StorageFactory deploys a new SimpleStorage contract
 * 3. The new contract's instance is stored in the array
 * 4. User can interact with the deployed contract through StorageFactory
 * 5. StorageFactory acts as a registry/manager for multiple SimpleStorage contracts
 */
