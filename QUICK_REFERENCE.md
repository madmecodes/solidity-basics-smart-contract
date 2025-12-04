# Quick Reference - Deploy & Interact

## 🚀 Deploy (Like clicking "Deploy" in Remix)

### Local (Anvil)
```bash
# Terminal 1 - Start Anvil
anvil

# Terminal 2 - Deploy
forge script script/DeployFundMe.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### Sepolia Testnet
```bash
source .env
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 🎮 Interact (Like clicking buttons in Remix)

Replace `<CONTRACT>` with your deployed contract address!

### SimpleStorage

```bash
# Store a number (sends transaction)
cast send <CONTRACT> "store(uint256)" 42 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Retrieve number (free, no transaction)
cast call <CONTRACT> "retrieve()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# Add a person
cast send <CONTRACT> "addPerson(string,uint256)" "Alice" 7 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

### FundMe

```bash
# Fund with 0.01 ETH
cast send <CONTRACT> "fund()" --value 0.01ether --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Check your funded amount
cast call <CONTRACT> "getAddressToAmountFunded(address)(uint256)" <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL

# Withdraw (only owner)
cast send <CONTRACT> "withdraw()" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

## 🔍 Useful Commands

```bash
# Check contract balance
cast balance <CONTRACT> --rpc-url $SEPOLIA_RPC_URL

# Check your balance
cast balance <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL

# Get transaction details
cast tx <TX_HASH> --rpc-url $SEPOLIA_RPC_URL

# View on Etherscan
# https://sepolia.etherscan.io/address/<CONTRACT>
```

## 💡 Key Differences: Remix vs Foundry

| Action | Remix | Foundry |
|--------|-------|---------|
| Deploy | Click "Deploy" | `forge script ...` |
| Send transaction | Click button | `cast send ...` |
| Read data | Click button | `cast call ...` |
| See on Etherscan | Click link | Open browser |

## 🎯 Common Patterns

**Deploy and Save Address:**
```bash
CONTRACT=$(forge script script/DeployFundMe.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac... | grep "Contract Address" | awk '{print $3}')
echo $CONTRACT
```

**Fund and Check Balance:**
```bash
cast send $CONTRACT "fund()" --value 0.01ether --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
cast balance $CONTRACT --rpc-url $SEPOLIA_RPC_URL
```

---

See **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** for full details!
