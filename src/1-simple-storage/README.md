# Section 1: Simple Storage

## Overview

This section introduces the fundamental concepts of Solidity smart contracts through a practical `SimpleStorage` contract. You'll learn the building blocks needed to write any smart contract.

## Concepts Covered

### 1. Contract Structure & Licensing

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleStorage { }
```

- **SPDX License**: Specifies the license for your code (MIT is permissive)
- **Pragma**: Defines which Solidity compiler version to use
- **Contract**: Similar to a class in other programming languages

### 2. Basic Data Types

```solidity
uint256 public favoriteNumber;     // Unsigned integer (always positive)
int256 public temperature;         // Signed integer (can be negative)
bool public hasFavoriteNumber;     // true or false
string public favoriteNumberText;  // Text
address public owner;              // Ethereum address
bytes32 public favoriteBytes;      // Fixed-size byte array
```

**Key Points:**
- State variables are stored permanently on the blockchain
- Each type has a default value (0 for numbers, false for bool, "" for string)
- `public` keyword automatically creates a getter function

### 3. Structs - Custom Data Types

```solidity
struct Person {
    string name;
    uint256 favoriteNumber;
}
```

Structs let you create custom types with multiple properties. Think of them as blueprints for objects.

### 4. Arrays - Lists of Data

```solidity
Person[] public listOfPeople;  // Dynamic array (can grow)
```

**Array Operations:**
- `push()`: Add element to the end
- `length`: Get number of elements
- `[index]`: Access element at position

### 5. Mappings - Key-Value Pairs

```solidity
mapping(string => uint256) public nameToFavoriteNumber;
```

Mappings are like dictionaries/hash tables:
- Fast lookups by key
- All keys "exist" and return default values if not set
- Cannot iterate through all keys

### 6. Functions

#### Function Visibility

- **public**: Can be called by anyone, internally or externally
- **external**: Can only be called from outside the contract (more gas efficient)
- **internal**: Can only be called within this contract or contracts that inherit from it
- **private**: Can only be called within this contract

#### Function State Mutability

- **view**: Reads blockchain state but doesn't modify it (free to call externally)
- **pure**: Doesn't read or modify state (free to call externally)
- **(none)**: Can read and modify state (costs gas)

```solidity
// Modifies state (costs gas)
function store(uint256 _favoriteNumber) public {
    favoriteNumber = _favoriteNumber;
}

// Reads state (free)
function retrieve() public view returns (uint256) {
    return favoriteNumber;
}

// No state access (free)
function add(uint256 _a, uint256 _b) public pure returns (uint256) {
    return _a + _b;
}
```

### 7. Data Locations - memory vs storage vs calldata

**Critical Concept:** You must specify data location for reference types (arrays, structs, strings, mappings)

```solidity
function addPerson(
    string memory _name,      // memory: temporary, modifiable
    uint256 _favoriteNumber   // value types don't need location
) public {
    listOfPeople.push(Person(_name, _favoriteNumber));
}
```

**Three Data Locations:**

1. **storage** 📦
   - Permanent data on the blockchain
   - State variables are automatically `storage`
   - Most expensive (costs gas to write)
   - Persists between function calls

2. **memory** 💾
   - Temporary data during function execution
   - Can be modified
   - Erased after function completes
   - Cheaper than storage

3. **calldata** 📋
   - Like memory but **read-only**
   - Used for function parameters
   - Cannot be modified
   - Most gas-efficient for external function parameters

```solidity
function demonstrateMemoryVsCalldata(
    string memory _memoryString,    // Can modify this
    string calldata _calldataString // Cannot modify this
) public pure returns (string memory, string calldata) {
    // _memoryString = "I can change this";     // ✓ Works
    // _calldataString = "I cannot change this"; // ✗ Error!
    return (_memoryString, _calldataString);
}
```

**When to use which?**
- Use `calldata` for external function parameters you don't need to modify (saves gas)
- Use `memory` when you need to modify the data
- `storage` is used for state variables (automatic)

### 8. Constructor

```solidity
constructor() {
    owner = msg.sender; // Runs once when contract is deployed
}
```

The constructor runs exactly once when the contract is deployed. It's often used to set initial values and establish ownership.

### 9. Global Variables

- `msg.sender`: Address of the account calling the function
- `msg.value`: Amount of Wei sent with the transaction
- `block.timestamp`: Current block timestamp
- `block.number`: Current block number

## Interacting with the Contract

### Using Foundry

1. **Compile the contract:**
   ```bash
   forge build
   ```

2. **Run tests:**
   ```bash
   forge test
   ```

3. **Deploy locally:**
   ```bash
   forge script script/DeploySimpleStorage.s.sol --rpc-url http://localhost:8545 --broadcast
   ```

4. **Deploy to testnet:**
   ```bash
   source .env
   forge script script/DeploySimpleStorage.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
   ```

### Common Operations

```solidity
// Store a favorite number
store(42);

// Retrieve it
uint256 number = retrieve(); // Returns 42

// Add a person
addPerson("Alice", 7);

// Look up by name
uint256 aliceNumber = nameToFavoriteNumber["Alice"]; // Returns 7

// Get person by index
Person memory person = listOfPeople[0];
```

## Practice Exercises

1. **Basic Storage:**
   - Deploy the contract and store your favorite number
   - Retrieve it and verify it matches

2. **Working with Arrays:**
   - Add 5 people with their favorite numbers
   - Retrieve each person by index
   - Check the total count with `getNumberOfPeople()`

3. **Using Mappings:**
   - Look up favorite numbers by name
   - What happens when you look up a name that wasn't added?

4. **Understanding Data Locations:**
   - Try modifying parameters in different functions
   - Observe which ones allow modification and which don't

## Gas Considerations

- Writing to storage (state variables) is expensive
- Reading from storage is cheaper
- Pure and view functions are free when called externally
- Every operation costs gas when part of a transaction

## Common Pitfalls

1. **Forgetting data location for strings:**
   ```solidity
   // ✗ Wrong
   function bad(string _name) public { }

   // ✓ Correct
   function good(string memory _name) public { }
   ```

2. **Array index out of bounds:**
   ```solidity
   // If array has 3 items, valid indices are 0, 1, 2
   listOfPeople[3]; // ✗ This will revert!
   ```

3. **Assuming mappings have a length:**
   ```solidity
   nameToFavoriteNumber.length; // ✗ Doesn't exist!
   ```

## Next Steps

Once you're comfortable with these concepts, move on to **Section 2: Storage Factory** to learn about:
- Deploying contracts from other contracts
- Contract composition and interaction
- Inheritance
- Imports

## Additional Resources

- [Solidity Docs - Types](https://docs.soliditylang.org/en/latest/types.html)
- [Solidity Docs - Data Location](https://docs.soliditylang.org/en/latest/types.html#data-location)
- [Cyfrin Updraft - Simple Storage](https://updraft.cyfrin.io/)
