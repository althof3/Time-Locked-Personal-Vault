# Quick Start Guide 🚀

Get your Time-Locked Vault up and running in minutes!

## Prerequisites

1. Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Verify installation:
```bash
forge --version
```

## Setup (5 minutes)

### 1. Clone and Build

```bash
# Clone the repository
git clone <your-repo-url>
cd mancer

# Install dependencies
forge install

# Build the project
forge build
```

### 2. Run Tests

```bash
# Run all tests
forge test -vv

# Expected output: 26 tests passed ✅
```

## Local Testing (Anvil)

### 1. Start Local Node

```bash
# Terminal 1: Start Anvil
anvil
```

This will give you 10 test accounts with 10,000 ETH each.

### 2. Deploy Contract

```bash
# Terminal 2: Deploy to local network
forge script script/DeployTimeLockedVault.s.sol:DeployTimeLockedVault \
  --rpc-url http://localhost:8545 \
  --broadcast
```

### 3. Interact with Contract

```bash
# Save the deployed contract address
export VAULT_ADDRESS=<address_from_deployment>

# Check unlock time
cast call $VAULT_ADDRESS "unlockTime()(uint256)" --rpc-url http://localhost:8545

# Deposit 1 ETH
cast send $VAULT_ADDRESS "deposit()" \
  --value 1ether \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Check balance
cast call $VAULT_ADDRESS "getBalance()(uint256)" --rpc-url http://localhost:8545

# Try to withdraw (will fail if locked)
cast send $VAULT_ADDRESS "withdraw()" \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

## Sepolia Deployment

### 1. Get Sepolia ETH

Get test ETH from a faucet:
- https://sepoliafaucet.com/
- https://www.alchemy.com/faucets/ethereum-sepolia

### 2. Setup Environment

```bash
# Copy example env file
cp .env.example .env

# Edit .env with your details
nano .env
```

Add:
- Your private key (from MetaMask or other wallet)
- Sepolia RPC URL (from Alchemy, Infura, etc.)
- Etherscan API key (from etherscan.io)

### 3. Deploy to Sepolia

```bash
# Load environment variables
source .env

# Deploy with verification
forge script script/DeployTimeLockedVault.s.sol:DeployTimeLockedVault \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

### 4. Verify Deployment

After deployment, you'll see:
- Contract address
- Etherscan link (if verified)
- Owner address
- Unlock time

## Common Commands

### Testing
```bash
# Run all tests
forge test

# Run specific test
forge test --match-test test_Withdraw_SucceedsAfterUnlockTime

# Run with gas report
forge test --gas-report

# Run with coverage
forge coverage
```

### Interacting with Deployed Contract

```bash
# Set your contract address
export VAULT=0x...

# Check owner
cast call $VAULT "owner()(address)" --rpc-url $SEPOLIA_RPC_URL

# Check unlock time
cast call $VAULT "unlockTime()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# Get time until unlock
cast call $VAULT "getTimeUntilUnlock()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# Deposit ETH
cast send $VAULT "deposit()" \
  --value 0.1ether \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY

# Extend lock time (owner only)
# New time must be > current unlockTime
cast send $VAULT "extendLock(uint256)" <NEW_TIMESTAMP> \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY

# Withdraw (after unlock time, owner only)
cast send $VAULT "withdraw()" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY
```

### Utility Commands

```bash
# Get current timestamp
cast block latest timestamp --rpc-url $SEPOLIA_RPC_URL

# Calculate future timestamp (5 minutes from now)
echo $(($(date +%s) + 300))

# Convert timestamp to human-readable
date -r <TIMESTAMP>

# Check ETH balance
cast balance <ADDRESS> --rpc-url $SEPOLIA_RPC_URL
```

## Troubleshooting

### "FundsLocked" Error
- You're trying to withdraw before the unlock time
- Check: `cast call $VAULT "getTimeUntilUnlock()(uint256)"`

### "OnlyOwner" Error
- You're not using the owner's private key
- Check: `cast call $VAULT "owner()(address)"`

### "InvalidUnlockTime" Error
- Unlock time is in the past
- Use a future timestamp: `echo $(($(date +%s) + 300))`

### "CannotReduceLockTime" Error
- New unlock time must be greater than current
- Check current: `cast call $VAULT "unlockTime()(uint256)"`

## Next Steps

1. ✅ Run tests locally
2. ✅ Deploy to Anvil and test interactions
3. ✅ Get Sepolia ETH
4. ✅ Deploy to Sepolia
5. ✅ Verify on Etherscan
6. ✅ Test deposit/withdraw cycle

## Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Cast Reference](https://book.getfoundry.sh/reference/cast/)
- [Sepolia Faucet](https://sepoliafaucet.com/)
- [Etherscan Sepolia](https://sepolia.etherscan.io/)

---

Need help? Check the main [README.md](./README.md) for detailed documentation.

