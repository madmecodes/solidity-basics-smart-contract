# Smart Contract Learning Project

A comprehensive Foundry-based project designed to help you master Solidity fundamentals through hands-on examples, complete with tests, documentation, and deployment scripts.

## 🎯 Project Overview

This project covers **three progressive sections** that take you from Solidity basics to building production-ready smart contracts:

1. **Simple Storage** - Solidity fundamentals
2. **Storage Factory** - Contract interaction and inheritance
3. **Fund Me** - Advanced concepts with real-world oracles

Each section includes:
- ✅ Fully documented, beginner-friendly contracts
- ✅ Comprehensive test suites (71 tests total!)
- ✅ Detailed READMEs with concepts and examples
- ✅ Deployment scripts for local and testnet
- ✅ Gas optimization demonstrations

## 📚 What You'll Learn

### Section 1: Simple Storage
**Duration:** ~2 hours | **Concepts:** 12 | **Tests:** 25

Learn the building blocks of Solidity:
- Basic data types (uint256, bool, string, address)
- Structs and custom types
- Arrays (dynamic and fixed)
- Mappings (key-value storage)
- Functions and visibility
- Memory vs Storage vs Calldata
- Constructors and state variables

**[📖 Read Section 1 Guide →](src/1-simple-storage/README.md)**

### Section 2: Storage Factory
**Duration:** ~1.5 hours | **Concepts:** 8 | **Tests:** 23

Master contract composition and interaction:
- Importing contracts
- Deploying contracts from contracts
- Contract interaction (ABI + Address)
- Inheritance and code reuse
- Function overriding (virtual/override)
- The Factory Pattern
- Polymorphism in Solidity

**[📖 Read Section 2 Guide →](src/2-storage-factory/README.md)**

### Section 3: Fund Me
**Duration:** ~3 hours | **Concepts:** 15+ | **Tests:** 23

Build production-ready contracts:
- Payable functions and receiving ETH
- Chainlink Price Feeds (oracles)
- Libraries and code organization
- Modifiers for access control
- Constants and immutable variables
- Custom errors (gas optimization)
- Receive and fallback functions
- For loops and array iteration
- Sending ETH (transfer/send/call)
- Gas optimization techniques

**[📖 Read Section 3 Guide →](src/3-fund-me/README.md)**

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git
- A code editor (VS Code recommended)

### Installation

```bash
# Install dependencies
forge install

# Compile contracts
forge build

# Run all tests
forge test

# Run tests with gas report
forge test --gas-report
```

### Project Structure

```
smart-contracts/
├── src/
│   ├── 1-simple-storage/
│   │   ├── SimpleStorage.sol          # Basic Solidity concepts
│   │   └── README.md                  # Section 1 guide
│   ├── 2-storage-factory/
│   │   ├── StorageFactory.sol         # Factory pattern
│   │   ├── AddFiveStorage.sol         # Inheritance example
│   │   └── README.md                  # Section 2 guide
│   └── 3-fund-me/
│       ├── FundMe.sol                 # Crowdfunding contract
│       ├── PriceConverter.sol         # Chainlink price library
│       └── README.md                  # Section 3 guide
├── test/
│   ├── SimpleStorageTest.t.sol        # 25 tests
│   ├── StorageFactoryTest.t.sol       # 23 tests
│   ├── FundMeTest.t.sol               # 23 tests
│   └── mocks/
│       └── MockV3Aggregator.sol       # Mock Chainlink feed
├── foundry.toml                       # Foundry configuration
├── .env.example                       # Environment variables template
└── README.md                          # This file
```

## 🧪 Testing

This project includes **71 comprehensive tests** covering all functionality:

```bash
# Run all tests
forge test

# Run tests for specific section
forge test --match-contract SimpleStorageTest
forge test --match-contract StorageFactoryTest
forge test --match-contract FundMeTest

# Run specific test
forge test --match-test test_StoreFavoriteNumber

# Verbose output (see transaction traces)
forge test -vvvv

# Gas report
forge test --gas-report
```

### Test Coverage

- ✅ Happy paths (expected behavior)
- ✅ Sad paths (error handling)
- ✅ Edge cases (boundary conditions)
- ✅ Access control (authorization)
- ✅ Gas optimization comparisons
- ✅ Fuzz testing (random inputs)

## 📦 Deployment & Interaction

**Just like Remix IDE with MetaMask!**

### Quick Start

**Local (Anvil):**
```bash
# Terminal 1
anvil

# Terminal 2 - Deploy FundMe
forge script script/DeployFundMe.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

**Sepolia Testnet:**
```bash
# 1. Setup environment
cp .env.example .env
# Edit .env with your RPC URL, private key, and Etherscan API key

# 2. Deploy
source .env
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

### Interact with Deployed Contracts

**Fund the contract (like clicking "fund" in Remix):**
```bash
cast send <CONTRACT_ADDRESS> "fund()" --value 0.01ether --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

**Check balance (like view functions in Remix):**
```bash
cast call <CONTRACT_ADDRESS> "getBalance()(uint256)" --rpc-url $SEPOLIA_RPC_URL
```

**📖 See full guide:** [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

## 💡 Key Learning Outcomes

By completing this project, you will:

### ✅ Understand Solidity Fundamentals
- Data types, structs, arrays, mappings
- Functions, modifiers, constructors
- Visibility and state mutability
- Memory management

### ✅ Master Contract Interaction
- Deploying contracts from contracts
- Working with interfaces and ABIs
- Inheritance and polymorphism
- Import statements and code organization

### ✅ Build Production-Ready Contracts
- Accept and manage ETH
- Integrate external data (Chainlink oracles)
- Implement access control
- Optimize for gas efficiency
- Write comprehensive tests
- Deploy to multiple networks

### ✅ Follow Best Practices
- Clear naming conventions
- Proper error handling
- Gas optimization techniques
- Security considerations
- Comprehensive documentation
- Thorough testing

## 📊 Gas Optimization Insights

This project demonstrates real gas savings:

| Technique | Before | After | Savings |
|-----------|--------|-------|---------|
| Custom errors vs require | ~23,000 gas | ~17,000 gas | ~26% |
| Constant variables | ~2,100 gas/read | ~3 gas/read | ~99% |
| Immutable variables | ~2,100 gas/read | ~3 gas/read | ~99% |
| Memory vs storage in loops | 19,252 gas | 16,022 gas | ~17% |

## 🎓 How to Use This Project

### For Absolute Beginners
1. Start with [Section 1: Simple Storage](src/1-simple-storage/README.md)
2. Read the contract code with comments
3. Run the tests and observe the output
4. Try modifying the contract and re-running tests
5. Move to Section 2 when comfortable

### For Intermediate Learners
1. Review all three sections quickly
2. Focus on areas you're less familiar with
3. Study the test files to understand testing patterns
4. Try deploying to testnet
5. Experiment with modifications

### For Advanced Learners
1. Use this as a reference implementation
2. Study gas optimization techniques
3. Review test patterns for your own projects
4. Fork and customize for your needs
5. Contribute improvements!

## 🔗 Additional Resources

### Official Documentation
- [Solidity Docs](https://docs.soliditylang.org/)
- [Foundry Book](https://book.getfoundry.sh/)
- [Chainlink Docs](https://docs.chain.link/)

### Learning Platforms
- [Cyfrin Updraft](https://updraft.cyfrin.io/) - Free Solidity course
- [Ethereum.org](https://ethereum.org/en/developers/) - Developer resources
- [Solidity by Example](https://solidity-by-example.org/) - Code examples

### Tools
- [Remix IDE](https://remix.ethereum.org/) - Browser-based Solidity IDE
- [Etherscan](https://sepolia.etherscan.io/) - Blockchain explorer
- [Tenderly](https://tenderly.co/) - Smart contract monitoring

## ⚠️ Disclaimer

This project is for educational purposes only. The contracts are designed for learning and have not been audited. Do not use in production without:
- Professional security audit
- Extensive testing
- Additional security features (reentrancy guards, etc.)
- Proper access control
- Emergency pause mechanisms

## 📄 License

MIT License - feel free to use for learning and reference.

## 🎯 Next Steps

After completing this project, consider:
1. Building your own DeFi protocol
2. Creating an NFT collection
3. Exploring Layer 2 solutions (zkSync, Optimism)
4. Learning about DAO governance
5. Contributing to open-source Web3 projects

---

**Happy Learning! 🚀**

Built with ❤️ using Foundry and Solidity
