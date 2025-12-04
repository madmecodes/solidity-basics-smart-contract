# Deployment & Interaction Guide

This guide shows you how to deploy and interact with your smart contracts using Foundry - similar to what you did in Remix with MetaMask!

## 🎯 Overview

In Remix, you:
1. Click "Deploy" → MetaMask pops up → Confirm transaction
2. Click function buttons → MetaMask confirms → Transaction sent
3. View functions work instantly (no MetaMask needed)

With Foundry, you:
1. Run `forge script` → Deploys contract
2. Use `cast send` → Sends transactions (like clicking buttons in Remix)
3. Use `cast call` → Calls view functions (instant, free)

## 📋 Prerequisites

1. **Get Testnet ETH**
   - Go to [Sepolia Faucet](https://sepoliafaucet.com/)
   - Enter your wallet address
   - Receive free Sepolia ETH

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env and add:
   # - SEPOLIA_RPC_URL (from Alchemy or Infura)
   # - PRIVATE_KEY (your wallet private key)
   # - ETHERSCAN_API_KEY (from etherscan.io)
   ```

3. **Load environment variables**
   ```bash
   source .env
   ```

## 🚀 Deployment

### Option 1: Deploy to Local Blockchain (Anvil)

**Step 1: Start Anvil**
```bash
# Terminal 1
anvil
```

This gives you:
- 10 accounts with 10,000 ETH each
- Instant mining (no waiting!)
- Perfect for testing

**Step 2: Deploy SimpleStorage**
```bash
# Terminal 2
forge script script/DeploySimpleStorage.s.sol \
    --rpc-url http://localhost:8545 \
    --broadcast \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

**Step 3: Deploy FundMe**
```bash
forge script script/DeployFundMe.s.sol \
    --rpc-url http://localhost:8545 \
    --broadcast \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

**📝 Copy the deployed addresses from the output!**

### Option 2: Deploy to Sepolia Testnet (Real Blockchain!)

**This is like clicking "Deploy" in Remix with MetaMask on Sepolia**

```bash
# Load your environment variables
source .env

# Deploy SimpleStorage
forge script script/DeploySimpleStorage.s.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify

# Deploy FundMe
forge script script/DeployFundMe.s.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify
```

**What `--verify` does:**
- Automatically verifies your contract on Etherscan
- Makes your code readable on Etherscan
- Others can interact with it easily

**📝 Important: Save your deployed contract addresses!**

## 🎮 Interacting with Deployed Contracts

### SimpleStorage Contract

Let's say your deployed address is: `0x5FbDB2315678afecb367f032d93F642f64180aa3`

#### 1. Store a Number (Like clicking "store" in Remix)

```bash
# Store the number 42
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
    "store(uint256)" 42 \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

**This sends a transaction!** Just like clicking "store" in Remix and confirming in MetaMask.

#### 2. Retrieve the Number (Like clicking "retrieve" in Remix)

```bash
# Read the stored number
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
    "retrieve()(uint256)" \
    --rpc-url $SEPOLIA_RPC_URL
```

**This is FREE!** No transaction needed - just like view functions in Remix.

#### 3. Add a Person

```bash
# Add Alice with favorite number 7
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
    "addPerson(string,uint256)" "Alice" 7 \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

#### 4. Get Person by Index

```bash
# Get person at index 0
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
    "getPerson(uint256)((string,uint256))" 0 \
    --rpc-url $SEPOLIA_RPC_URL
```

#### 5. Look Up by Name

```bash
# Get Alice's favorite number
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
    "nameToFavoriteNumber(string)(uint256)" "Alice" \
    --rpc-url $SEPOLIA_RPC_URL
```

### FundMe Contract

Let's say your deployed address is: `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`

#### 1. Fund the Contract (Send ETH)

```bash
# Send 0.01 ETH to the contract
cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 \
    "fund()" \
    --value 0.01ether \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

**This is like clicking "fund" in Remix with a value of 0.01 ETH!**

#### 2. Check How Much You Funded

```bash
# Replace YOUR_ADDRESS with your wallet address
cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 \
    "getAddressToAmountFunded(address)(uint256)" YOUR_ADDRESS \
    --rpc-url $SEPOLIA_RPC_URL
```

#### 3. Check Contract Balance

```bash
# See how much ETH is in the contract
cast balance 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 \
    --rpc-url $SEPOLIA_RPC_URL
```

#### 4. Get Number of Funders

```bash
cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 \
    "getNumberOfFunders()(uint256)" \
    --rpc-url $SEPOLIA_RPC_URL
```

#### 5. Withdraw (Only Owner!)

```bash
# Only the owner can do this
cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 \
    "withdraw()" \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

#### 6. Use Cheaper Withdraw (Gas Optimized!)

```bash
cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 \
    "cheaperWithdraw()" \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

## 🔍 Viewing on Etherscan

After deployment, you can view your contract on Etherscan:

**Sepolia Testnet:**
```
https://sepolia.etherscan.io/address/<YOUR_CONTRACT_ADDRESS>
```

If you used `--verify`, you'll see:
- ✅ Contract source code
- ✅ Read Contract tab (call view functions)
- ✅ Write Contract tab (send transactions)

## 📊 Useful Cast Commands

### Get Transaction Receipt
```bash
cast receipt <TRANSACTION_HASH> --rpc-url $SEPOLIA_RPC_URL
```

### Get Transaction Details
```bash
cast tx <TRANSACTION_HASH> --rpc-url $SEPOLIA_RPC_URL
```

### Check Your Balance
```bash
cast balance <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
```

### Convert Wei to Ether
```bash
cast --to-unit 1000000000000000000 ether
# Output: 1
```

### Convert Ether to Wei
```bash
cast --to-wei 0.01 ether
# Output: 10000000000000000
```

### Get Current Block Number
```bash
cast block-number --rpc-url $SEPOLIA_RPC_URL
```

### Estimate Gas for a Transaction
```bash
cast estimate 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 \
    "fund()" \
    --value 0.01ether \
    --rpc-url $SEPOLIA_RPC_URL
```

## 🎯 Complete Example Workflow

Let's do a complete deployment and interaction:

```bash
# 1. Load environment
source .env

# 2. Deploy FundMe to Sepolia
forge script script/DeployFundMe.s.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify

# 3. Save the deployed address (let's say it's 0xABC...)
CONTRACT=0xABC...

# 4. Fund it with 0.01 ETH
cast send $CONTRACT "fund()" --value 0.01ether --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# 5. Check the balance
cast balance $CONTRACT --rpc-url $SEPOLIA_RPC_URL

# 6. Check how much you funded
cast call $CONTRACT "getAddressToAmountFunded(address)(uint256)" <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL

# 7. Check total funders
cast call $CONTRACT "getNumberOfFunders()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# 8. Withdraw (as owner)
cast send $CONTRACT "withdraw()" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# 9. Verify balance is now 0
cast balance $CONTRACT --rpc-url $SEPOLIA_RPC_URL
```

## 🔐 Security Best Practices

1. **Never commit your private key or .env file**
   - Already in `.gitignore`
   - Use separate wallets for development/production

2. **Never use mainnet private keys for testing**
   - Create a separate testnet wallet

3. **Always test on testnet first**
   - Anvil (local) → Sepolia → Mainnet

4. **Verify contracts on Etherscan**
   - Use `--verify` flag
   - Makes your contract transparent

## 🚨 Common Issues

### Issue: "Insufficient funds"
**Solution:** Get testnet ETH from a faucet

### Issue: "Nonce too low"
**Solution:** Your transaction is stuck. Wait or increase gas price

### Issue: "Transaction reverted"
**Solution:** Check the revert reason. Often it's:
- Not enough ETH sent
- Not the owner
- Failed requirement

### Issue: RPC URL not working
**Solution:**
- Check your Alchemy/Infura dashboard
- Try a different RPC provider
- Use public RPC: `https://rpc.sepolia.org`

## 🎓 Remix vs Foundry Comparison

| Action | Remix | Foundry |
|--------|-------|---------|
| Deploy | Click "Deploy" button | `forge script` |
| Call function (send tx) | Click button, confirm MetaMask | `cast send` |
| Call view function | Click button, see result | `cast call` |
| See contract on Etherscan | Click address link | Go to etherscan.io/address/... |
| Verify contract | Click verify button | Add `--verify` to deploy |
| Change network | MetaMask network selector | Change `--rpc-url` |

## 🎉 You're Ready!

You now know how to:
- ✅ Deploy contracts to local and testnet
- ✅ Interact with deployed contracts
- ✅ Send transactions
- ✅ Call view functions
- ✅ Verify contracts on Etherscan
- ✅ Debug and troubleshoot

**This is exactly what you did in Remix, but using Foundry!**

---

**Need Help?**
- Check contract addresses in deployment output
- View transactions on Etherscan
- Use `-vvvv` flag for verbose output
- Test locally first on Anvil
