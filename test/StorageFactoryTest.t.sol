// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StorageFactory} from "../src/2-storage-factory/StorageFactory.sol";
import {AddFiveStorage} from "../src/2-storage-factory/AddFiveStorage.sol";
import {SimpleStorage} from "../src/1-simple-storage/SimpleStorage.sol";

/**
 * @title StorageFactoryTest
 * @notice Comprehensive tests for StorageFactory and AddFiveStorage contracts
 * @dev Tests cover deployment, interaction, and inheritance concepts
 */
contract StorageFactoryTest is Test {
    StorageFactory public factory;
    AddFiveStorage public addFiveStorage;

    function setUp() public {
        factory = new StorageFactory();
        addFiveStorage = new AddFiveStorage();
    }

    // ============== FACTORY DEPLOYMENT TESTS ==============

    /**
     * @notice Test that factory starts with no contracts
     */
    function test_InitialFactoryIsEmpty() public view {
        uint256 count = factory.getNumberOfContracts();
        assertEq(count, 0, "Factory should start with 0 contracts");
    }

    /**
     * @notice Test creating a single SimpleStorage contract
     */
    function test_CreateOneSimpleStorageContract() public {
        factory.createSimpleStorageContract();

        uint256 count = factory.getNumberOfContracts();
        assertEq(count, 1, "Should have 1 contract after creation");
    }

    /**
     * @notice Test creating multiple SimpleStorage contracts
     */
    function test_CreateMultipleSimpleStorageContracts() public {
        factory.createSimpleStorageContract();
        factory.createSimpleStorageContract();
        factory.createSimpleStorageContract();

        uint256 count = factory.getNumberOfContracts();
        assertEq(count, 3, "Should have 3 contracts");
    }

    /**
     * @notice Test that each deployed contract has a unique address
     */
    function test_DeployedContractsHaveUniqueAddresses() public {
        factory.createSimpleStorageContract();
        factory.createSimpleStorageContract();
        factory.createSimpleStorageContract();

        address addr1 = factory.getContractAddress(0);
        address addr2 = factory.getContractAddress(1);
        address addr3 = factory.getContractAddress(2);

        // All addresses should be different
        assertTrue(addr1 != addr2, "First two addresses should differ");
        assertTrue(addr2 != addr3, "Last two addresses should differ");
        assertTrue(addr1 != addr3, "First and last addresses should differ");

        // All addresses should be non-zero
        assertTrue(addr1 != address(0), "Address 1 should not be zero");
        assertTrue(addr2 != address(0), "Address 2 should not be zero");
        assertTrue(addr3 != address(0), "Address 3 should not be zero");
    }

    // ============== CONTRACT INTERACTION TESTS ==============

    /**
     * @notice Test storing a value through the factory
     */
    function test_StoreValueThroughFactory() public {
        factory.createSimpleStorageContract();

        uint256 valueToStore = 42;
        factory.sfStore(0, valueToStore);

        uint256 retrievedValue = factory.sfGet(0);
        assertEq(retrievedValue, valueToStore, "Retrieved value should match stored value");
    }

    /**
     * @notice Test storing different values in different contracts
     */
    function test_StoreDifferentValuesInDifferentContracts() public {
        // Create 3 contracts
        factory.createSimpleStorageContract();
        factory.createSimpleStorageContract();
        factory.createSimpleStorageContract();

        // Store different values in each
        factory.sfStore(0, 100);
        factory.sfStore(1, 200);
        factory.sfStore(2, 300);

        // Verify each contract has its own value
        assertEq(factory.sfGet(0), 100, "First contract should have 100");
        assertEq(factory.sfGet(1), 200, "Second contract should have 200");
        assertEq(factory.sfGet(2), 300, "Third contract should have 300");
    }

    /**
     * @notice Test updating a value in a specific contract
     */
    function test_UpdateValueInSpecificContract() public {
        factory.createSimpleStorageContract();

        // Store initial value
        factory.sfStore(0, 42);
        assertEq(factory.sfGet(0), 42, "Initial value should be 42");

        // Update value
        factory.sfStore(0, 777);
        assertEq(factory.sfGet(0), 777, "Updated value should be 777");
    }

    /**
     * @notice Test adding a person through the factory
     */
    function test_AddPersonThroughFactory() public {
        factory.createSimpleStorageContract();

        string memory name = "Alice";
        uint256 favoriteNum = 7;

        factory.sfAddPerson(0, name, favoriteNum);

        // Get the deployed contract to verify
        SimpleStorage deployedContract = factory.listOfSimpleStorageContracts(0);
        uint256 retrievedNum = deployedContract.nameToFavoriteNumber(name);

        assertEq(retrievedNum, favoriteNum, "Person should be added with correct favorite number");
    }

    /**
     * @notice Test that each contract maintains its own state
     */
    function test_ContractsMaintainIndependentState() public {
        factory.createSimpleStorageContract();
        factory.createSimpleStorageContract();

        // Add different people to each contract
        factory.sfAddPerson(0, "Alice", 7);
        factory.sfAddPerson(1, "Bob", 42);

        // Verify state is independent
        SimpleStorage contract1 = factory.listOfSimpleStorageContracts(0);
        SimpleStorage contract2 = factory.listOfSimpleStorageContracts(1);

        assertEq(contract1.nameToFavoriteNumber("Alice"), 7);
        assertEq(contract1.nameToFavoriteNumber("Bob"), 0); // Bob not in contract 1

        assertEq(contract2.nameToFavoriteNumber("Bob"), 42);
        assertEq(contract2.nameToFavoriteNumber("Alice"), 0); // Alice not in contract 2
    }

    // ============== DIRECT INTERACTION TESTS ==============

    /**
     * @notice Test interacting directly with deployed contract
     * @dev Shows you can bypass the factory and interact directly
     */
    function test_DirectInteractionWithDeployedContract() public {
        factory.createSimpleStorageContract();

        // Get the deployed contract
        SimpleStorage deployedContract = factory.listOfSimpleStorageContracts(0);

        // Interact directly (not through factory)
        deployedContract.store(999);

        uint256 value = deployedContract.retrieve();
        assertEq(value, 999, "Should be able to interact directly with deployed contract");

        // Verify factory can also see this change
        uint256 factoryValue = factory.sfGet(0);
        assertEq(factoryValue, 999, "Factory should see the same value");
    }

    // ============== INHERITANCE TESTS - AddFiveStorage ==============

    /**
     * @notice Test that AddFiveStorage adds 5 to stored value
     */
    function test_AddFiveStorageAdds5() public {
        uint256 inputValue = 10;
        addFiveStorage.store(inputValue);

        uint256 retrievedValue = addFiveStorage.retrieve();
        assertEq(retrievedValue, inputValue + 5, "Should store value plus 5");
    }

    /**
     * @notice Fuzz test AddFiveStorage with various values
     */
    function testFuzz_AddFiveStorageAdds5(uint256 value) public {
        // Avoid overflow
        vm.assume(value <= type(uint256).max - 5);

        addFiveStorage.store(value);
        uint256 retrieved = addFiveStorage.retrieve();

        assertEq(retrieved, value + 5, "Should always add 5");
    }

    /**
     * @notice Test that AddFiveStorage inherits SimpleStorage functions
     */
    function test_AddFiveStorageInheritsFunctions() public {
        // addPerson is inherited from SimpleStorage
        addFiveStorage.addPerson("Alice", 7);

        // Verify it works
        uint256 num = addFiveStorage.nameToFavoriteNumber("Alice");
        assertEq(num, 7, "Inherited addPerson function should work");
    }

    /**
     * @notice Test the new sayHello function in AddFiveStorage
     */
    function test_AddFiveStorageSayHello() public view {
        string memory greeting = addFiveStorage.sayHello();
        assertEq(greeting, "Hello from AddFiveStorage!", "Should return correct greeting");
    }

    /**
     * @notice Test that AddFiveStorage has all SimpleStorage state variables
     */
    function test_AddFiveStorageInheritsStateVariables() public {
        // Store a value (will be +5)
        addFiveStorage.store(20); // Stores 25

        // Check favoriteNumber (inherited state variable)
        uint256 favNum = addFiveStorage.favoriteNumber();
        assertEq(favNum, 25, "Should have access to inherited state variable");

        // Check hasFavoriteNumber (inherited state variable)
        bool hasFav = addFiveStorage.hasFavoriteNumber();
        assertTrue(hasFav, "Inherited hasFavoriteNumber should be true");
    }

    /**
     * @notice Test storing zero in AddFiveStorage
     */
    function test_AddFiveStorageStoreZero() public {
        addFiveStorage.store(0);

        uint256 value = addFiveStorage.retrieve();
        assertEq(value, 5, "Storing 0 should result in 5");
    }

    // ============== TYPE AND POLYMORPHISM TESTS ==============

    /**
     * @notice Test that AddFiveStorage IS-A SimpleStorage
     * @dev AddFiveStorage can be treated as SimpleStorage (polymorphism)
     */
    function test_AddFiveStorageIsSimpleStorage() public {
        AddFiveStorage child = new AddFiveStorage();

        // Can treat AddFiveStorage as SimpleStorage
        SimpleStorage parent = SimpleStorage(address(child));

        // Store through parent reference (will still add 5 because override is respected)
        parent.store(10);

        uint256 value = parent.retrieve();
        assertEq(value, 15, "Override should work even through parent reference");
    }

    // ============== GAS TESTING ==============

    /**
     * @notice Test gas cost of deploying through factory
     */
    function test_DeploymentGasCost() public {
        uint256 gasBefore = gasleft();
        factory.createSimpleStorageContract();
        uint256 gasAfter = gasleft();

        uint256 gasUsed = gasBefore - gasAfter;
        console.log("Gas used to deploy SimpleStorage through factory:", gasUsed);

        assertTrue(gasUsed > 0, "Should use gas to deploy");
    }

    /**
     * @notice Compare gas between direct deployment and factory deployment
     */
    function test_CompareDeploymentGas() public {
        // Direct deployment
        uint256 gasBefore1 = gasleft();
        new SimpleStorage();
        uint256 gasAfter1 = gasleft();
        uint256 directGas = gasBefore1 - gasAfter1;

        // Factory deployment
        uint256 gasBefore2 = gasleft();
        factory.createSimpleStorageContract();
        uint256 gasAfter2 = gasleft();
        uint256 factoryGas = gasBefore2 - gasAfter2;

        console.log("Direct deployment gas:", directGas);
        console.log("Factory deployment gas:", factoryGas);
        console.log("Factory overhead:", factoryGas - directGas);

        assertTrue(factoryGas > directGas, "Factory should use more gas (overhead for tracking)");
    }

    // ============== ERROR CASES ==============

    /**
     * @notice Test accessing non-existent contract index reverts
     */
    function test_RevertWhen_AccessingInvalidIndex() public {
        factory.createSimpleStorageContract();

        // Try to access index 1 when only index 0 exists
        vm.expectRevert();
        factory.sfGet(1);
    }

    /**
     * @notice Test storing in non-existent contract reverts
     */
    function test_RevertWhen_StoringInInvalidIndex() public {
        // No contracts created yet
        vm.expectRevert();
        factory.sfStore(0, 42);
    }

    // ============== ADVANCED TESTS ==============

    /**
     * @notice Test creating many contracts
     */
    function test_CreateManyContracts() public {
        uint256 numberOfContracts = 10;

        for (uint256 i = 0; i < numberOfContracts; i++) {
            factory.createSimpleStorageContract();
        }

        assertEq(
            factory.getNumberOfContracts(),
            numberOfContracts,
            "Should have created 10 contracts"
        );
    }

    /**
     * @notice Test that contract addresses are deterministic (based on nonce)
     * @dev Each deployment increments the nonce, making addresses predictable
     */
    function test_ContractAddressesAreDeterministic() public {
        // Deploy first contract
        factory.createSimpleStorageContract();
        address firstAddr = factory.getContractAddress(0);

        // Deploy second factory and contract
        StorageFactory factory2 = new StorageFactory();
        factory2.createSimpleStorageContract();
        address secondAddr = factory2.getContractAddress(0);

        // Addresses should be different (different deployer nonces)
        assertTrue(firstAddr != secondAddr, "Different factories produce different addresses");
    }
}

/*
 * TEST INSIGHTS:
 *
 * 1. FACTORY PATTERN TESTING:
 *    - Verify contract creation and tracking
 *    - Test independence of deployed contracts
 *    - Check state management across multiple instances
 *
 * 2. INHERITANCE TESTING:
 *    - Verify overridden functions behave correctly
 *    - Check inherited functions still work
 *    - Test that state variables are inherited
 *    - Validate polymorphism (child can be treated as parent)
 *
 * 3. GAS TESTING:
 *    - Measure deployment costs
 *    - Compare factory vs direct deployment
 *    - Understand overhead of patterns
 *
 * 4. INTERACTION TESTING:
 *    - Test both factory-mediated and direct interaction
 *    - Verify ABI/address usage
 *    - Check contract independence
 *
 * RUNNING TESTS:
 *
 * forge test --match-contract StorageFactoryTest         - Run all tests
 * forge test --match-test test_CreateOne                 - Run specific test
 * forge test --gas-report                                - Show gas usage
 * forge test -vvvv                                       - Very verbose output
 */
