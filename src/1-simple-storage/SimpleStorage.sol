// SPDX-License-Identifier: MIT
// SPDX License Identifier specifies the license for the contract
// MIT is a permissive open-source license

pragma solidity ^0.8.19;
// Pragma specifies the Solidity compiler version
// ^0.8.19 means any version from 0.8.19 up to (but not including) 0.9.0

/**
 * @title SimpleStorage
 * @author Your Name
 * @notice This contract demonstrates fundamental Solidity concepts for beginners
 * @dev Covers: basic types, structs, arrays, mappings, functions, memory/storage/calldata
 */
contract SimpleStorage {
    // ============== STATE VARIABLES ==============
    // State variables are stored permanently on the blockchain

    // Basic Types:
    uint256 public favoriteNumber; // Unsigned integer (256 bits), defaults to 0
    bool public hasFavoriteNumber; // Boolean, defaults to false
    string public favoriteNumberText; // String, defaults to ""
    address public owner; // Ethereum address (20 bytes), defaults to 0x0
    int256 public temperature; // Signed integer (can be negative), defaults to 0
    bytes32 public favoriteBytes; // Fixed-size byte array (32 bytes)

    // ============== STRUCT ==============
    // Structs allow you to create custom types with multiple properties
    struct Person {
        string name;
        uint256 favoriteNumber;
    }

    // ============== ARRAYS ==============
    // Dynamic array - can grow in size
    Person[] public listOfPeople;

    // We could also have fixed-size arrays like this:
    // Person[10] public fixedListOfPeople; // Can only hold 10 people

    // ============== MAPPINGS ==============
    // Mappings are like hash tables or dictionaries
    // They map a key type to a value type
    mapping(string => uint256) public nameToFavoriteNumber;

    // Nested mapping example (commented out, but shows the concept)
    // mapping(address => mapping(uint256 => bool)) public nestedMapping;

    // ============== CONSTRUCTOR ==============
    // Constructor runs once when the contract is deployed
    constructor() {
        owner = msg.sender; // msg.sender is the address deploying the contract
        hasFavoriteNumber = false;
    }

    // ============== FUNCTIONS ==============

    /**
     * @notice Store a favorite number
     * @dev This is a public function that modifies state (costs gas)
     * @dev Marked as virtual so it can be overridden by child contracts
     * @param _favoriteNumber The number to store
     */
    function store(uint256 _favoriteNumber) public virtual {
        favoriteNumber = _favoriteNumber;
        hasFavoriteNumber = true;
    }

    /**
     * @notice Retrieve the stored favorite number
     * @dev View function - reads state but doesn't modify it (free to call externally)
     * @return The stored favorite number
     */
    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }

    /**
     * @notice Add a person with their favorite number
     * @dev Demonstrates memory keyword for strings
     * @param _name Person's name (stored in memory temporarily)
     * @param _favoriteNumber Person's favorite number
     */
    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        // Create a new Person and add to the array
        listOfPeople.push(Person(_name, _favoriteNumber));

        // Also add to the mapping for quick lookup
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }

    /**
     * @notice Get a person from the list by index
     * @dev Demonstrates returning a struct
     * @param _index The index in the listOfPeople array
     * @return Person struct at the given index
     */
    function getPerson(uint256 _index) public view returns (Person memory) {
        return listOfPeople[_index];
    }

    /**
     * @notice Get favorite number by name using the mapping
     * @dev Demonstrates mapping lookup
     * @param _name The name to look up
     * @return The favorite number associated with the name
     */
    function getNumberByName(string memory _name) public view returns (uint256) {
        return nameToFavoriteNumber[_name];
    }

    /**
     * @notice Demonstrates the difference between memory and calldata
     * @dev calldata is like memory but the variable cannot be modified
     * @param _memoryString Can be modified within the function
     * @param _calldataString Cannot be modified (read-only)
     * @return Both strings concatenated
     */
    function demonstrateMemoryVsCalldata(
        string memory _memoryString,
        string calldata _calldataString
    ) public pure returns (string memory, string calldata) {
        // _memoryString can be reassigned
        // _memoryString = "I can change this"; // This would work

        // _calldataString cannot be reassigned
        // _calldataString = "I cannot change this"; // This would cause an error

        return (_memoryString, _calldataString);
    }

    /**
     * @notice Pure function example - doesn't read or modify state
     * @dev Pure functions are deterministic and cost no gas when called externally
     * @param _a First number
     * @param _b Second number
     * @return Sum of the two numbers
     */
    function add(uint256 _a, uint256 _b) public pure returns (uint256) {
        return _a + _b;
    }

    /**
     * @notice Get the total number of people stored
     * @dev Array length is a property you can access
     * @return The length of the listOfPeople array
     */
    function getNumberOfPeople() public view returns (uint256) {
        return listOfPeople.length;
    }

    /**
     * @notice Internal function example - only callable from within this contract
     * @dev Internal functions are not part of the contract's public interface
     * @param _number Number to double
     * @return The doubled number
     */
    function _internalDouble(uint256 _number) internal pure returns (uint256) {
        return _number * 2;
    }

    /**
     * @notice Public function that calls an internal function
     * @param _number Number to double
     * @return The doubled number
     */
    function doubleNumber(uint256 _number) public pure returns (uint256) {
        return _internalDouble(_number);
    }

    /**
     * @notice Private function example - only callable from within this contract
     * @dev Private functions are even more restricted than internal (not accessible by derived contracts)
     * @param _number Number to triple
     * @return The tripled number
     */
    function _privateTriple(uint256 _number) private pure returns (uint256) {
        return _number * 3;
    }

    /**
     * @notice External function example - can only be called from outside the contract
     * @dev External functions are more gas efficient for external calls
     * @param _text Some text to return
     * @return The same text
     */
    function externalFunction(string calldata _text) external pure returns (string calldata) {
        return _text;
    }
}

/*
 * KEY CONCEPTS SUMMARY:
 *
 * 1. DATA TYPES:
 *    - uint256: Unsigned integer (0 to 2^256-1)
 *    - int256: Signed integer (negative to positive)
 *    - bool: true or false
 *    - string: Text data
 *    - address: Ethereum address
 *    - bytes: Fixed or dynamic byte arrays
 *
 * 2. STRUCTS:
 *    - Custom data types that group related data together
 *    - Like objects in other programming languages
 *
 * 3. ARRAYS:
 *    - Dynamic: Can grow in size (Type[] variableName)
 *    - Fixed: Fixed size (Type[size] variableName)
 *
 * 4. MAPPINGS:
 *    - Key-value pairs (like hash tables/dictionaries)
 *    - All possible keys exist, default values are returned for unset keys
 *
 * 5. FUNCTION VISIBILITY:
 *    - public: Can be called internally and externally
 *    - private: Only callable within this contract
 *    - internal: Callable within this contract and derived contracts
 *    - external: Only callable from outside the contract
 *
 * 6. FUNCTION STATE MUTABILITY:
 *    - view: Reads state but doesn't modify it
 *    - pure: Doesn't read or modify state
 *    - (no keyword): Can read and modify state
 *
 * 7. DATA LOCATIONS:
 *    - storage: Permanent data stored on blockchain (expensive)
 *    - memory: Temporary data, erased between function calls
 *    - calldata: Like memory but read-only, used for function parameters
 *
 * 8. STATE VARIABLES vs LOCAL VARIABLES:
 *    - State variables: Declared at contract level, stored permanently
 *    - Local variables: Declared in functions, temporary
 */
