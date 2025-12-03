# Section 3: Fund Me

## Overview

This section introduces advanced Solidity concepts through building a crowdfunding contract. You'll learn how to accept ETH, interact with Chainlink oracles for price data, use libraries, implement access control, and optimize for gas efficiency.

## Concepts Covered

### 1. Payable Functions

Functions marked `payable` can receive ETH:

```solidity
function fund() public payable {
    // msg.value contains the amount of Wei sent
    require(msg.value >= minimumUSD, "Didn't send enough ETH");
}
```

**Key Points:**
- `payable` keyword allows function to accept ETH
- `msg.value` is the amount sent (in Wei)
- 1 ETH = 1,000,000,000,000,000,000 Wei (18 decimals)
- Without `payable`, sending ETH to a function will revert

**msg Object Properties:**
- `msg.sender`: Address calling the function
- `msg.value`: Amount of Wei sent
- `msg.data`: Complete calldata
- `msg.sig`: First 4 bytes of calldata (function selector)

### 2. Chainlink Oracles & Price Feeds

Blockchains cannot access external data natively. Oracles solve this problem.

**The Oracle Problem:**
```
❌ Smart Contract → Internet → Get ETH price
   (Impossible - blockchains are isolated)

✅ Smart Contract → Chainlink Oracle → ETH price
   (Decentralized oracle network provides data)
```

**Why Chainlink?**
- **Decentralized**: Multiple independent nodes provide data
- **Reliable**: Data aggregated from many sources
- **Secure**: Cryptographically signed data
- **Live**: Continuously updated prices
- **Battle-tested**: Secures billions in DeFi

**Using Price Feeds:**

```solidity
import {AggregatorV3Interface} from "@chainlink/contracts/...";

AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
(, int256 price,,,) = priceFeed.latestRoundData();
```

**Price Feed Addresses:**
- Sepolia ETH/USD: `0x694AA1769357215DE4FAC081bf1f309aDC325306`
- Mainnet ETH/USD: `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`
- Find more: [Chainlink Price Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)

### 3. Libraries

Libraries are reusable code without state:

```solidity
library PriceConverter {
    using AggregatorV3Interface for address;

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed)
        internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        return (ethPrice * ethAmount) / 1e18;
    }
}

// Using the library
using PriceConverter for uint256;
uint256 usdValue = msg.value.getConversionRate(s_priceFeed);
```

**Library Characteristics:**
- Cannot have state variables
- Cannot inherit or be inherited
- Cannot receive Ether
- All functions usually `internal` or `pure`
- Embedded in contract or deployed separately

**Benefits:**
- Code reuse across contracts
- Keep contracts organized
- Save deployment gas (if deployed separately)
- Cleaner, more readable code

### 4. Decimals in Solidity

Solidity doesn't support floating-point numbers. We use integers with implied decimals:

```solidity
// ETH uses 18 decimals
1 ETH = 1_000_000_000_000_000_000 Wei

// Chainlink uses 8 decimals for prices
$2000 = 2000_00000000 (200000000000)

// Converting:
// 1. Get price: 2000e8 (8 decimals)
// 2. Convert to 18: 2000e8 * 1e10 = 2000e18
// 3. Multiply: (2000e18 * amountInWei) / 1e18
```

**Why 18 decimals for ETH?**
- Allows for very small fractions (important for pricing)
- Standard across Ethereum ecosystem
- 1 Wei is the smallest unit

**Handling Decimals:**

```solidity
// Always align decimals before calculations
uint256 ethPrice = uint256(price) * 1e10; // 8 decimals → 18 decimals
uint256 usdValue = (ethPrice * ethAmount) / 1e18; // Keep 18 decimals
```

### 5. Modifiers

Modifiers add reusable logic to functions:

```solidity
modifier onlyOwner() {
    if (msg.sender != i_owner) {
        revert FundMe__NotOwner();
    }
    _; // Function body executes here
}

function withdraw() public onlyOwner {
    // Only owner can execute this
}
```

**How Modifiers Work:**
1. Modifier code runs first
2. `_` represents where function body executes
3. Code after `_` runs after function (if any)

**Common Use Cases:**
- Access control (`onlyOwner`, `onlyAdmin`)
- Input validation (`nonZero`, `validAddress`)
- State checks (`whenNotPaused`, `afterDeadline`)
- Reentrancy guards (`nonReentrant`)

**Multiple Modifiers:**
```solidity
function criticalFunction()
    public
    onlyOwner
    whenNotPaused
    nonReentrant
{
    // All modifiers execute in order
}
```

### 6. Immutable & Constant

Both save gas by not using storage:

```solidity
// Constant - value set at compile time
uint256 public constant MINIMUM_USD = 5 * 1e18;

// Immutable - value set at deployment (in constructor)
address public immutable i_owner;

constructor() {
    i_owner = msg.sender; // Set once, never changes
}
```

**Gas Savings:**
- Regular variable: ~2100 gas to read
- Constant/Immutable: ~3 gas to read
- Saves gas on every read operation!

**Naming Conventions:**
- `CONSTANT_NAME` - all caps with underscores
- `i_immutableName` - prefix with i_

### 7. Custom Errors

More gas-efficient than `require` with strings:

```solidity
// ❌ Old way (expensive)
require(msg.sender == owner, "Only owner can call this function");

// ✅ New way (cheaper)
error FundMe__NotOwner();
if (msg.sender != owner) {
    revert FundMe__NotOwner();
}
```

**Gas Comparison:**
- `require` with string: ~23,000 gas
- Custom error: ~17,000 gas
- **Savings: ~6,000 gas per revert!**

**Naming Convention:**
```solidity
error ContractName__ErrorDescription();
```

### 8. Receive & Fallback Functions

Special functions for handling ETH sent to contract:

```solidity
// Called when ETH sent with NO data
receive() external payable {
    fund();
}

// Called when:
// - ETH sent with data that doesn't match any function
// - Function called doesn't exist
fallback() external payable {
    fund();
}
```

**Decision Tree:**
```
Is ETH sent to contract?
│
├─ Yes → Is msg.data empty?
│        │
│        ├─ Yes → receive() exists?
│        │        ├─ Yes → Call receive()
│        │        └─ No → Call fallback()
│        │
│        └─ No → Call fallback()
│
└─ No → Normal function call
```

**Use Cases:**
- Accept direct ETH transfers
- Redirect to main function (like `fund()`)
- Log unexpected calls
- Implement proxy patterns

### 9. For Loops

Iterate over arrays or repeat operations:

```solidity
for (uint256 i = 0; i < array.length; i++) {
    // Do something with array[i]
    s_addressToAmountFunded[funders[i]] = 0;
}
```

**Structure:**
```solidity
for (initialization; condition; increment) {
    // Loop body
}
```

**Gas Optimization:**
```solidity
// ❌ Expensive - reads from storage each iteration
for (uint256 i = 0; i < s_funders.length; i++) {
    // ...
}

// ✅ Cheaper - read once into memory
uint256 fundersLength = s_funders.length;
for (uint256 i = 0; i < fundersLength; i++) {
    // ...
}

// ✅ Even better - use memory array
address[] memory funders = s_funders;
for (uint256 i = 0; i < funders.length; i++) {
    // ...
}
```

**Warning:** Be careful with unbounded loops! They can run out of gas if array is too large.

### 10. Sending ETH from Contracts

Three ways to send ETH:

```solidity
// 1. transfer (2300 gas, reverts on failure)
payable(msg.sender).transfer(amount);

// 2. send (2300 gas, returns bool)
bool success = payable(msg.sender).send(amount);
require(success, "Send failed");

// 3. call (forwards all gas, returns bool) ✅ RECOMMENDED
(bool success, ) = payable(msg.sender).call{value: amount}("");
require(success, "Call failed");
```

**Why `call` is recommended:**
- Forwards all available gas
- More flexible than transfer/send
- Can call other functions while sending ETH
- Consistent with best practices

**Gas Limits:**
- `transfer`/`send`: Fixed 2300 gas (can fail if recipient needs more)
- `call`: Forwards all available gas (more reliable)

## Contract Architecture

### Data Structures

```solidity
// Track all funders
address[] public s_funders;

// Map address to amount funded
mapping(address => uint256) public s_addressToAmountFunded;
```

**Why both array and mapping?**
- Array: Know who all the funders are, iterate for withdrawals
- Mapping: Quick lookup of individual amounts

### Funding Flow

```
User sends ETH → fund() function
                 ↓
        Check minimum USD value
        (using Chainlink price feed)
                 ↓
         Add to s_funders array
                 ↓
    Update s_addressToAmountFunded
                 ↓
              Success!
```

### Withdrawal Flow

```
Owner calls withdraw()
          ↓
    Check onlyOwner modifier
          ↓
  Loop through all funders
          ↓
   Reset their balances to 0
          ↓
    Clear the funders array
          ↓
  Transfer all ETH to owner
```

## Gas Optimization Techniques

### 1. Constants (Compile-time)
```solidity
uint256 public constant MINIMUM_USD = 5 * 1e18;
// Saves ~2100 gas per read
```

### 2. Immutable (Runtime)
```solidity
address public immutable i_owner;
// Saves ~2100 gas per read
```

### 3. Custom Errors
```solidity
error FundMe__NotOwner();
// Saves ~6000 gas per revert
```

### 4. Memory vs Storage
```solidity
// ❌ Expensive
for (uint256 i = 0; i < s_funders.length; i++) {
    s_addressToAmountFunded[s_funders[i]] = 0;
}

// ✅ Cheaper
address[] memory funders = s_funders;
for (uint256 i = 0; i < funders.length; i++) {
    s_addressToAmountFunded[funders[i]] = 0;
}
```

**Our tests show:**
- Regular withdraw: 19,252 gas
- Optimized withdraw: 16,022 gas
- **Savings: 3,230 gas (17% reduction!)**

### 5. Proper Variable Packing
```solidity
// Variables are packed into 32-byte slots
// Put smaller types together to save storage slots
```

## Practice Exercises

### Basic
1. Deploy FundMe with a mock price feed
2. Fund the contract with different amounts
3. Verify minimum USD requirement
4. Withdraw as owner

### Intermediate
1. Add multiple funders
2. Check individual balances
3. Change the ETH price and observe effects
4. Test the receive and fallback functions

### Advanced
1. Compare gas costs between withdraw methods
2. Test with fork of real network
3. Implement emergency withdraw
4. Add events for transparency

## Real-World Applications

1. **Crowdfunding**: Kickstarter-style campaigns
2. **DAOs**: Treasury management
3. **Yield Farming**: Deposit tracking
4. **Lending Protocols**: Collateral management
5. **Insurance**: Premium collection

## Security Considerations

### Implemented
✅ Access control (onlyOwner)
✅ Minimum funding requirement
✅ Custom errors for gas efficiency
✅ Using `call` for ETH transfers

### Not Implemented (Would add in production)
- ⚠️ Reentrancy guard
- ⚠️ Pause mechanism
- ⚠️ Withdrawal timelock
- ⚠️ Events for transparency
- ⚠️ Price feed staleness check

## Testing

```bash
# Run all FundMe tests
forge test --match-contract FundMeTest

# Run with gas report
forge test --match-contract FundMeTest --gas-report

# Run specific test
forge test --match-test test_Withdraw

# Very verbose output
forge test --match-contract FundMeTest -vvvv

# Test against real network (fork)
forge test --fork-url $SEPOLIA_RPC_URL
```

## Deployment

### Local (Anvil)
```bash
# Start Anvil
anvil

# Deploy
forge script script/DeployFundMe.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Testnet (Sepolia)
```bash
source .env
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## Key Takeaways

1. **Payable functions** accept ETH via `msg.value`
2. **Chainlink oracles** provide real-world data to smart contracts
3. **Libraries** enable code reuse without state
4. **Modifiers** add reusable logic to functions
5. **Constants & immutable** save significant gas
6. **Custom errors** are more gas-efficient than strings
7. **Receive & fallback** handle direct ETH transfers
8. **For loops** can iterate but watch gas limits
9. **Call** is the recommended way to send ETH
10. **Gas optimization** can save users money

## Next Steps

This FundMe contract demonstrates production-ready patterns used in real DeFi protocols. Master these concepts and you'll be ready to:
- Build DeFi applications
- Understand existing protocols
- Write gas-efficient code
- Implement proper access control
- Work with oracles

## Additional Resources

- [Chainlink Price Feeds](https://docs.chain.link/data-feeds)
- [Solidity Docs - Special Functions](https://docs.soliditylang.org/en/latest/contracts.html#special-functions)
- [Gas Optimization Patterns](https://www.alchemy.com/overviews/solidity-gas-optimization)
- [Smart Contract Security](https://consensys.github.io/smart-contract-best-practices/)
