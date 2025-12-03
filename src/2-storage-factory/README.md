# Section 2: Storage Factory

## Overview

This section introduces advanced Solidity concepts including deploying contracts from other contracts, imports, contract interaction, and inheritance. You'll learn how contracts can work together to create more complex blockchain applications.

## Concepts Covered

### 1. Imports

Solidity allows you to import code from other files to reuse and organize your contracts.

```solidity
// Import specific contracts (preferred - cleaner)
import {SimpleStorage} from "../1-simple-storage/SimpleStorage.sol";

// Import everything from a file
import "../1-simple-storage/SimpleStorage.sol";

// Import with alias
import {SimpleStorage as SS} from "../1-simple-storage/SimpleStorage.sol";
```

**Benefits of Imports:**
- Code reuse - don't duplicate code
- Better organization - separate concerns into different files
- Easier maintenance - update one file instead of many
- Composability - build complex systems from simple parts

### 2. Deploying Contracts from Contracts

Contracts can deploy other contracts using the `new` keyword:

```solidity
SimpleStorage newSimpleStorage = new SimpleStorage();
```

**Key Points:**
- The deploying contract becomes the "creator" of the new contract
- Each deployment costs gas
- The new contract gets its own address on the blockchain
- You can deploy unlimited contracts (limited only by gas)

**Use Cases:**
- **Factory Pattern**: One contract creates many instances (e.g., token factory, DAO factory)
- **Upgradeable Contracts**: Deploy new versions while keeping the factory
- **Multi-Contract Systems**: Complex dApps with specialized contracts

### 3. Contract Interaction & ABI

To interact with a contract, you need two things:

1. **Address**: Where the contract is deployed
2. **ABI** (Application Binary Interface): The contract's interface

```solidity
// We have both when we import and deploy:
SimpleStorage myContract = listOfContracts[0]; // Has address and type (ABI)
myContract.store(42); // Call functions on the deployed contract
```

**What is an ABI?**
- A JSON description of the contract's functions and variables
- Contains function names, parameter types, return types
- Enables interaction between contracts and external applications
- Generated automatically by the compiler

**Example ABI Entry:**
```json
{
  "name": "store",
  "type": "function",
  "inputs": [{"name": "_favoriteNumber", "type": "uint256"}],
  "outputs": []
}
```

### 4. Inheritance

Inheritance allows a contract to inherit features from another contract:

```solidity
contract AddFiveStorage is SimpleStorage {
    // AddFiveStorage gets all of SimpleStorage's:
    // - State variables
    // - Functions
    // - Events
}
```

**Inheritance Hierarchy:**

```
SimpleStorage (Parent)
    ├── favoriteNumber
    ├── store()
    └── retrieve()
        ↓ inherits
AddFiveStorage (Child)
    ├── favoriteNumber (inherited)
    ├── store() (overridden)
    ├── retrieve() (inherited)
    └── sayHello() (new)
```

**Benefits:**
- **Code Reuse**: Don't duplicate code
- **Extension**: Add new features to existing contracts
- **Polymorphism**: Different implementations of the same interface
- **Organization**: Create logical hierarchies

### 5. Virtual and Override

To override a function, the parent must allow it:

```solidity
// In parent contract (SimpleStorage)
function store(uint256 _favoriteNumber) public virtual {
    favoriteNumber = _favoriteNumber;
}

// In child contract (AddFiveStorage)
function store(uint256 _newNumber) public override {
    super.store(_newNumber + 5); // Calls parent's version
}
```

**Keywords:**
- `virtual`: Parent marks function as overrideable
- `override`: Child marks that it's overriding parent
- `super`: Refers to the parent contract

**When to Override:**
- Modify behavior while keeping the same interface
- Add extra logic before/after parent's logic
- Completely replace parent's implementation

### 6. The Factory Pattern

StorageFactory demonstrates the Factory Pattern:

```
User → StorageFactory → Deploy SimpleStorage #1
                    → Deploy SimpleStorage #2
                    → Deploy SimpleStorage #3
                    → Manage all deployed contracts
```

**Advantages:**
- Central registry of deployed contracts
- Simplified deployment process
- Easy tracking and management
- Can enforce rules on created contracts

**Real-World Examples:**
- Uniswap Factory: Creates trading pair contracts
- OpenZeppelin Clones: Deploys minimal proxy contracts
- DAO Factories: Creates new DAOs
- NFT Collection Factories: Deploys new NFT contracts

## Contract Walkthrough

### StorageFactory.sol

```solidity
SimpleStorage[] public listOfSimpleStorageContracts;

function createSimpleStorageContract() public {
    SimpleStorage newSimpleStorage = new SimpleStorage();
    listOfSimpleStorageContracts.push(newSimpleStorage);
}

function sfStore(uint256 _index, uint256 _number) public {
    SimpleStorage mySimpleStorage = listOfSimpleStorageContracts[_index];
    mySimpleStorage.store(_number);
}
```

**Workflow:**
1. Call `createSimpleStorageContract()` - Deploys new SimpleStorage
2. Contract is added to array for tracking
3. Use `sfStore()` to interact with specific deployed contract
4. Factory acts as intermediary/manager

### AddFiveStorage.sol

```solidity
contract AddFiveStorage is SimpleStorage {
    function store(uint256 _newNumber) public override {
        super.store(_newNumber + 5);
    }
}
```

**Behavior:**
- When you call `store(10)`, it actually stores `15`
- All other SimpleStorage functions work normally
- Adds new `sayHello()` function

## Interacting with the Contracts

### Deploy and Use Factory

```bash
# Deploy StorageFactory
forge create src/2-storage-factory/StorageFactory.sol:StorageFactory --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Or use scripts
forge script script/DeployStorageFactory.s.sol
```

### Example Usage

```solidity
// Deploy factory
StorageFactory factory = new StorageFactory();

// Create 3 SimpleStorage contracts
factory.createSimpleStorageContract();
factory.createSimpleStorageContract();
factory.createSimpleStorageContract();

// Store values in each
factory.sfStore(0, 42);  // First contract stores 42
factory.sfStore(1, 77);  // Second contract stores 77
factory.sfStore(2, 99);  // Third contract stores 99

// Read values back
uint256 value1 = factory.sfGet(0); // Returns 42
uint256 value2 = factory.sfGet(1); // Returns 77
uint256 value3 = factory.sfGet(2); // Returns 99

// Get total number of contracts
uint256 count = factory.getNumberOfContracts(); // Returns 3

// Get contract address
address contractAddr = factory.getContractAddress(0);
```

### Use AddFiveStorage

```solidity
AddFiveStorage addFive = new AddFiveStorage();

// Store 10, but actually stores 15
addFive.store(10);

// Retrieve returns 15
uint256 value = addFive.retrieve(); // 15

// Can still use all SimpleStorage functions
addFive.addPerson("Alice", 7);

// Plus new functions
string memory greeting = addFive.sayHello(); // "Hello from AddFiveStorage!"
```

## Practice Exercises

1. **Factory Basics:**
   - Deploy StorageFactory
   - Create 5 SimpleStorage contracts using the factory
   - Store different numbers in each
   - Retrieve and verify all values

2. **Contract Addresses:**
   - Get the address of each deployed SimpleStorage
   - Verify they all have different addresses
   - Calculate gas cost of deployment

3. **Inheritance:**
   - Deploy AddFiveStorage
   - Store the number 100 (should actually store 105)
   - Verify the behavior is different from regular SimpleStorage
   - Test that inherited functions still work

4. **Advanced Challenge:**
   - Create your own child contract that multiplies by 2 instead of adding 5
   - Name it `DoubleStorage`
   - Add a custom function to it

## Gas Considerations

- Deploying contracts is expensive (lots of gas)
- Each `new SimpleStorage()` costs ~100,000+ gas
- Factory pattern adds overhead but provides management benefits
- Consider minimal proxies (clones) for cheaper deployments of identical contracts

## Common Patterns

### 1. Factory with Tracking
```solidity
mapping(address => address[]) public userToContracts;

function create() public {
    Contract c = new Contract();
    userToContracts[msg.sender].push(address(c));
}
```

### 2. Factory with Access Control
```solidity
address public owner;

modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}

function create() public onlyOwner {
    Contract c = new Contract();
}
```

### 3. Inheritance Chain
```solidity
contract A { }
contract B is A { }
contract C is B { } // C inherits from both B and A
```

## Real-World Applications

1. **Uniswap**: Factory creates pair contracts for token swaps
2. **Compound**: Factory deploys cToken contracts
3. **Gnosis Safe**: Factory deploys multi-sig wallets
4. **ENS**: Registry manages domain contracts
5. **OpenZeppelin**: Proxy factory for upgradeable contracts

## Next Steps

Once you're comfortable with these concepts, move on to **Section 3: FundMe** to learn about:
- Sending and receiving ETH
- Chainlink oracles for real-world data
- Libraries
- Modifiers
- Receive and fallback functions
- Gas optimization

## Additional Resources

- [Solidity Docs - Contracts](https://docs.soliditylang.org/en/latest/contracts.html)
- [Solidity Docs - Inheritance](https://docs.soliditylang.org/en/latest/contracts.html#inheritance)
- [Factory Pattern](https://en.wikipedia.org/wiki/Factory_method_pattern)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
