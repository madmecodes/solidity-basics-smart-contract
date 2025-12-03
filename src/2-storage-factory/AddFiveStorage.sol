// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Import the SimpleStorage contract
import {SimpleStorage} from "../1-simple-storage/SimpleStorage.sol";

/**
 * @title AddFiveStorage
 * @author Your Name
 * @notice This contract demonstrates inheritance and function overriding in Solidity
 * @dev Inherits from SimpleStorage and overrides the store function
 */

// The 'is' keyword means AddFiveStorage inherits from SimpleStorage
// AddFiveStorage gets all the state variables and functions from SimpleStorage
contract AddFiveStorage is SimpleStorage {
    // ============== INHERITANCE ==============
    // By using 'is SimpleStorage', this contract inherits:
    // - All state variables (favoriteNumber, listOfPeople, etc.)
    // - All functions (retrieve, addPerson, etc.)
    // - The constructor logic
    //
    // We can now:
    // 1. Use all inherited functions as-is
    // 2. Add new functions
    // 3. Override existing functions to change their behavior

    /**
     * @notice Store a number, but add 5 to it first
     * @dev This function OVERRIDES the store function from SimpleStorage
     * @param _newNumber The number to store (5 will be added to it)
     *
     * For a function to be overrideable:
     * - Parent function must be marked 'virtual' (which it is in SimpleStorage)
     * - Child function must be marked 'override' (which we do here)
     */
    function store(uint256 _newNumber) public override {
        // Call the parent contract's store function with the number + 5
        // 'super' refers to the parent contract (SimpleStorage)
        super.store(_newNumber + 5);

        // Alternative approach: We could also access the state variable directly
        // instead of calling super.store():
        // favoriteNumber = _newNumber + 5;
        // hasFavoriteNumber = true;
        //
        // Using super.store() is often preferred because it ensures all the
        // parent's logic is executed (in case it does more than just setting variables)
    }

    /**
     * @notice New function that doesn't exist in the parent contract
     * @dev This demonstrates adding new functionality to an inherited contract
     * @return A greeting message
     */
    function sayHello() public pure returns (string memory) {
        return "Hello from AddFiveStorage!";
    }
}

/*
 * KEY CONCEPTS SUMMARY:
 *
 * 1. INHERITANCE:
 *    - Use 'is' keyword: contract Child is Parent
 *    - Child inherits all state variables and functions from Parent
 *    - Can inherit from multiple contracts: contract Child is Parent1, Parent2
 *    - Inheritance creates an "is-a" relationship
 *
 * 2. VIRTUAL AND OVERRIDE:
 *    - Parent function must be marked 'virtual' to be overrideable
 *    - Child function must be marked 'override' to override parent
 *    - Syntax: function foo() public virtual { } // in parent
 *              function foo() public override { } // in child
 *
 * 3. SUPER KEYWORD:
 *    - 'super' refers to the parent contract
 *    - super.functionName() calls the parent's version of the function
 *    - Useful when you want to extend (not replace) parent functionality
 *
 * 4. WHY USE INHERITANCE?
 *    - Code reuse: Don't duplicate code
 *    - Extensibility: Add new features to existing contracts
 *    - Polymorphism: Different implementations of the same interface
 *    - Organization: Create contract hierarchies
 *
 * 5. INHERITANCE CHAIN:
 *    - Contracts can inherit from contracts that inherit from other contracts
 *    - Example: A is B, B is C means A inherits from both B and C
 *    - Solidity uses C3 linearization for multiple inheritance
 *
 * EXAMPLE USAGE:
 *
 * AddFiveStorage addFiveStorage = new AddFiveStorage();
 *
 * // This will store 10 (5 + 5)
 * addFiveStorage.store(5);
 *
 * // This returns 10
 * uint256 value = addFiveStorage.retrieve();
 *
 * // We can still use all SimpleStorage functions
 * addFiveStorage.addPerson("Alice", 7);
 *
 * // And we have the new function
 * string memory greeting = addFiveStorage.sayHello();
 *
 * IMPORTANT NOTE:
 * The store function in SimpleStorage has been marked as 'virtual', which allows
 * us to override it here. In practice, when designing contracts that will be inherited,
 * you should mark functions as 'virtual' if you want child contracts to be able to
 * override them. Not all functions need to be virtual - only those you want to allow
 * customization of in derived contracts.
 */
