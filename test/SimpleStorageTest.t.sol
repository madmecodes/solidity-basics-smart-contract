// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/1-simple-storage/SimpleStorage.sol";

/**
 * @title SimpleStorageTest
 * @notice Comprehensive tests for the SimpleStorage contract
 * @dev Tests cover all functionality with detailed explanations
 */
contract SimpleStorageTest is Test {
    // Declare the contract we're testing
    SimpleStorage public simpleStorage;

    // Test addresses
    address public owner = address(this);
    address public user1 = address(0x1);
    address public user2 = address(0x2);

    /**
     * @notice setUp runs before each test
     * @dev This is a special function in Foundry that runs before each test
     */
    function setUp() public {
        // Deploy a fresh SimpleStorage contract before each test
        simpleStorage = new SimpleStorage();
    }

    // ============== BASIC STORAGE TESTS ==============

    /**
     * @notice Test that favoriteNumber starts at 0
     */
    function test_InitialFavoriteNumberIsZero() public view {
        uint256 expectedValue = 0;
        uint256 actualValue = simpleStorage.favoriteNumber();
        assertEq(actualValue, expectedValue, "Initial favorite number should be 0");
    }

    /**
     * @notice Test that hasFavoriteNumber starts as false
     */
    function test_InitialHasFavoriteNumberIsFalse() public view {
        bool expected = false;
        bool actual = simpleStorage.hasFavoriteNumber();
        assertEq(actual, expected, "Initial hasFavoriteNumber should be false");
    }

    /**
     * @notice Test storing a favorite number
     */
    function test_StoreFavoriteNumber() public {
        uint256 expectedValue = 42;

        // Call the store function
        simpleStorage.store(expectedValue);

        // Verify the value was stored correctly
        uint256 actualValue = simpleStorage.retrieve();
        assertEq(actualValue, expectedValue, "Stored value should match");
    }

    /**
     * @notice Test that store function updates hasFavoriteNumber
     */
    function test_StoreSetsHasFavoriteNumberToTrue() public {
        simpleStorage.store(123);

        bool hasNumber = simpleStorage.hasFavoriteNumber();
        assertTrue(hasNumber, "hasFavoriteNumber should be true after storing");
    }

    /**
     * @notice Test storing zero as a valid favorite number
     */
    function test_CanStoreZero() public {
        simpleStorage.store(0);

        uint256 value = simpleStorage.retrieve();
        assertEq(value, 0, "Should be able to store 0");
    }

    /**
     * @notice Test storing maximum uint256 value
     */
    function test_CanStoreMaxUint256() public {
        uint256 maxValue = type(uint256).max;
        simpleStorage.store(maxValue);

        uint256 value = simpleStorage.retrieve();
        assertEq(value, maxValue, "Should be able to store max uint256");
    }

    // ============== FUZZ TESTING ==============

    /**
     * @notice Fuzz test - Foundry will run this with many random values
     * @dev This tests that any uint256 value can be stored and retrieved
     */
    function testFuzz_StoreAnyNumber(uint256 randomNumber) public {
        simpleStorage.store(randomNumber);

        uint256 retrieved = simpleStorage.retrieve();
        assertEq(retrieved, randomNumber, "Should store and retrieve any number");
    }

    // ============== STRUCT AND ARRAY TESTS ==============

    /**
     * @notice Test adding a person
     */
    function test_AddPerson() public {
        string memory name = "Alice";
        uint256 favoriteNum = 7;

        simpleStorage.addPerson(name, favoriteNum);

        // Verify person was added to array
        SimpleStorage.Person memory person = simpleStorage.getPerson(0);
        assertEq(person.name, name, "Person name should match");
        assertEq(person.favoriteNumber, favoriteNum, "Person favorite number should match");

        // Verify person was added to mapping
        uint256 mappedNumber = simpleStorage.nameToFavoriteNumber(name);
        assertEq(mappedNumber, favoriteNum, "Mapping should contain the correct number");
    }

    /**
     * @notice Test adding multiple people
     */
    function test_AddMultiplePeople() public {
        // Add three people
        simpleStorage.addPerson("Alice", 7);
        simpleStorage.addPerson("Bob", 42);
        simpleStorage.addPerson("Charlie", 99);

        // Check array length
        uint256 count = simpleStorage.getNumberOfPeople();
        assertEq(count, 3, "Should have 3 people");

        // Verify each person
        SimpleStorage.Person memory alice = simpleStorage.getPerson(0);
        assertEq(alice.name, "Alice");
        assertEq(alice.favoriteNumber, 7);

        SimpleStorage.Person memory bob = simpleStorage.getPerson(1);
        assertEq(bob.name, "Bob");
        assertEq(bob.favoriteNumber, 42);

        SimpleStorage.Person memory charlie = simpleStorage.getPerson(2);
        assertEq(charlie.name, "Charlie");
        assertEq(charlie.favoriteNumber, 99);
    }

    /**
     * @notice Test that array starts empty
     */
    function test_InitialArrayIsEmpty() public view {
        uint256 count = simpleStorage.getNumberOfPeople();
        assertEq(count, 0, "Initial array should be empty");
    }

    /**
     * @notice Test getting person by index reverts for invalid index
     */
    function test_RevertWhen_GetPersonWithInvalidIndex() public {
        // Expect the next call to revert because array is empty
        vm.expectRevert();
        simpleStorage.getPerson(0);
    }

    // ============== MAPPING TESTS ==============

    /**
     * @notice Test looking up favorite number by name
     */
    function test_GetNumberByName() public {
        simpleStorage.addPerson("Alice", 7);

        uint256 number = simpleStorage.getNumberByName("Alice");
        assertEq(number, 7, "Should retrieve correct number by name");
    }

    /**
     * @notice Test that mappings return 0 for non-existent keys
     */
    function test_MappingReturnsZeroForNonExistentKey() public view {
        // Looking up a name that was never added should return 0
        uint256 number = simpleStorage.nameToFavoriteNumber("NonExistent");
        assertEq(number, 0, "Non-existent mapping keys return default value (0)");
    }

    /**
     * @notice Test updating a person's favorite number
     */
    function test_UpdatePersonFavoriteNumber() public {
        // Add Alice with favorite number 7
        simpleStorage.addPerson("Alice", 7);

        // Add Alice again with a new favorite number
        simpleStorage.addPerson("Alice", 13);

        // Mapping should have the latest value
        uint256 number = simpleStorage.nameToFavoriteNumber("Alice");
        assertEq(number, 13, "Mapping should update to new value");

        // Array should have both entries (it doesn't update, just appends)
        assertEq(simpleStorage.getNumberOfPeople(), 2, "Array should have 2 entries");
    }

    // ============== FUNCTION VISIBILITY TESTS ==============

    /**
     * @notice Test public function can be called
     */
    function test_PublicFunctionCanBeCalled() public {
        // Public functions can be called internally
        simpleStorage.store(42);
        assertEq(simpleStorage.retrieve(), 42);
    }

    /**
     * @notice Test external function can be called
     */
    function test_ExternalFunctionCanBeCalled() public view {
        // External functions can be called from tests
        string memory result = simpleStorage.externalFunction("Hello");
        assertEq(result, "Hello", "External function should work");
    }

    // ============== PURE FUNCTION TESTS ==============

    /**
     * @notice Test pure function (add)
     */
    function test_PureFunction() public view {
        uint256 result = simpleStorage.add(5, 7);
        assertEq(result, 12, "Add function should work correctly");
    }

    /**
     * @notice Fuzz test for add function
     */
    function testFuzz_AddFunction(uint128 a, uint128 b) public view {
        // Using uint128 to avoid overflow
        uint256 result = simpleStorage.add(a, b);
        assertEq(result, uint256(a) + uint256(b), "Addition should be correct");
    }

    /**
     * @notice Test doubleNumber function (which uses internal function)
     */
    function test_DoubleNumber() public view {
        uint256 result = simpleStorage.doubleNumber(21);
        assertEq(result, 42, "Should double the number");
    }

    // ============== CONSTRUCTOR TESTS ==============

    /**
     * @notice Test that owner is set correctly in constructor
     */
    function test_OwnerIsSetCorrectly() public view {
        address contractOwner = simpleStorage.owner();
        assertEq(contractOwner, owner, "Owner should be the deployer");
    }

    // ============== GAS TESTING ==============

    /**
     * @notice Test gas usage for storing a number
     * @dev This helps understand gas costs
     */
    function test_StoreGasCost() public {
        uint256 gasBefore = gasleft();
        simpleStorage.store(42);
        uint256 gasAfter = gasleft();

        uint256 gasUsed = gasBefore - gasAfter;
        console.log("Gas used for store():", gasUsed);

        // Just logging, no assertion needed
        assertTrue(gasUsed > 0, "Should use some gas");
    }

    /**
     * @notice Test that view functions don't cost gas when called externally
     * @dev When called within a transaction, they do cost gas
     */
    function test_ViewFunctionGas() public view {
        // This is a view function, so it's free to call externally
        // But costs gas when called from another function
        uint256 gasBefore = gasleft();
        simpleStorage.retrieve();
        uint256 gasAfter = gasleft();

        uint256 gasUsed = gasBefore - gasAfter;
        console.log("Gas used for retrieve() within transaction:", gasUsed);
    }

    // ============== EDGE CASES ==============

    /**
     * @notice Test adding person with empty string name
     */
    function test_AddPersonWithEmptyName() public {
        simpleStorage.addPerson("", 42);

        SimpleStorage.Person memory person = simpleStorage.getPerson(0);
        assertEq(person.name, "", "Should accept empty string");
        assertEq(person.favoriteNumber, 42);
    }

    /**
     * @notice Test adding person with very long name
     */
    function test_AddPersonWithLongName() public {
        string memory longName = "ThisIsAVeryLongNameThatSomeoneDecidedToUseForSomeReason";
        simpleStorage.addPerson(longName, 123);

        SimpleStorage.Person memory person = simpleStorage.getPerson(0);
        assertEq(person.name, longName, "Should handle long names");
    }

    // ============== DEMONSTRATION TESTS ==============

    /**
     * @notice Demonstrate memory vs calldata
     */
    function test_MemoryVsCalldata() public view {
        (string memory mem, string memory call) =
            simpleStorage.demonstrateMemoryVsCalldata("memory string", "calldata string");

        assertEq(mem, "memory string");
        assertEq(call, "calldata string");
    }
}

/*
 * TEST NAMING CONVENTIONS:
 *
 * test_Description          - Regular test
 * testFail_Description      - Test that should revert/fail
 * testFuzz_Description      - Fuzz test with random inputs
 *
 * RUNNING TESTS:
 *
 * forge test                           - Run all tests
 * forge test --match-test test_Store   - Run specific test
 * forge test -vv                       - Verbose output
 * forge test -vvvv                     - Very verbose (shows traces)
 * forge test --gas-report              - Show gas usage
 *
 * USEFUL ASSERTIONS:
 *
 * assertEq(a, b)           - Assert equality
 * assertTrue(x)            - Assert true
 * assertFalse(x)           - Assert false
 * assertGt(a, b)           - Assert a > b
 * assertLt(a, b)           - Assert a < b
 * assertGe(a, b)           - Assert a >= b
 * assertLe(a, b)           - Assert a <= b
 */
