# Time-Locked Personal Vault 🔐

A secure Ethereum smart contract that enforces a mandatory holding period for deposited ETH. Built with Solidity and Foundry for the Ethereum Foundations Capstone challenge.

## 📋 Overview

The **TimeLockedVault** is a savings vault smart contract that allows users to deposit ETH but prevents withdrawals until a specific future timestamp. This enforces disciplined saving by making funds strictly inaccessible until the lock period expires.

### Key Features

- ✅ **Time-Locked Withdrawals**: Funds remain locked until a specific timestamp
- ✅ **Owner-Only Access**: Only the vault owner can withdraw funds
- ✅ **Flexible Deposits**: Anyone can deposit, but only owner can withdraw
- ✅ **Lock Extension**: Owner can extend the lock time (but never reduce it)
- ✅ **Gas Optimized**: Uses Solidity 0.8+ with built-in overflow protection
- ✅ **Secure**: Follows Checks-Effects-Interactions pattern
- ✅ **Fully Tested**: 24 comprehensive tests with 100% pass rate

## 🛠️ Tech Stack

- **Language**: Solidity ^0.8.20
- **Framework**: Foundry
- **Target Chain**: Ethereum Sepolia Testnet
- **Asset**: Native ETH

## 📦 Installation

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Git

### Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd mancer

# Install dependencies
forge install

# Build the project
forge build
```

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
forge test

# Run tests with verbosity
forge test -vv

# Run tests with gas report
forge test --gas-report

# Run specific test
forge test --match-test test_Withdraw_SucceedsAfterUnlockTime -vvv
```

### Test Coverage

The project includes 24 tests covering:
- ✅ Constructor validation
- ✅ Deposit functionality
- ✅ Withdrawal logic and access control
- ✅ Lock extension mechanism
- ✅ View functions
- ✅ Fuzz testing
- ✅ Full integration cycles

**All tests pass with 100% success rate.**

## 🚀 Deployment

### Local Deployment (Anvil)

```bash
# Start local node
anvil

# Deploy to local network
forge script script/DeployTimeLockedVault.s.sol:DeployTimeLockedVault --rpc-url http://localhost:8545 --broadcast
```

### Sepolia Testnet Deployment

1. **Set up environment variables**:

```bash
# Create .env file
echo "PRIVATE_KEY=your_private_key_here" > .env
echo "SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY" >> .env
echo "ETHERSCAN_API_KEY=your_etherscan_api_key" >> .env
```

2. **Deploy to Sepolia**:

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

3. **Verify contract** (if not done automatically):

```bash
forge verify-contract <CONTRACT_ADDRESS> src/TimeLockedVault.sol:TimeLockedVault \
  --chain sepolia \
  --constructor-args $(cast abi-encode "constructor(uint256)" <UNLOCK_TIME>)
```

## 📖 Usage

### Deploying Your Own Vault

```solidity
// Deploy with 5 minutes lock time
uint256 unlockTime = block.timestamp + 5 minutes;
TimeLockedVault vault = new TimeLockedVault(unlockTime);
```

### Depositing ETH

```solidity
// Using deposit function
vault.deposit{value: 1 ether}();

// Or send ETH directly
payable(address(vault)).transfer(1 ether);
```

### Extending Lock Time

```solidity
// Extend lock by 10 more minutes
uint256 newUnlockTime = vault.unlockTime() + 10 minutes;
vault.extendLock(newUnlockTime);
```

### Withdrawing Funds

```solidity
// After unlock time has passed
vault.withdraw(); // Sends all funds to owner
```

### Checking Status

```solidity
// Get current balance
uint256 balance = vault.getBalance();

// Get time until unlock
uint256 timeRemaining = vault.getTimeUntilUnlock();

// Get unlock timestamp
uint256 unlockTime = vault.unlockTime();
```

## 🔒 Security Features

### Access Control
- **onlyOwner modifier**: Restricts sensitive functions to the vault owner
- **Immutable owner**: Owner address cannot be changed after deployment

### Time Validation
- **Constructor check**: Prevents deployment with unlock time in the past
- **Extension validation**: Lock time can only be extended, never reduced
- **Withdrawal check**: Reverts if attempting to withdraw before unlock time

### Safe Transfers
- **Checks-Effects-Interactions**: Follows best practice pattern
- **Custom errors**: Gas-efficient error handling
- **Event emissions**: All state changes emit events for transparency

### Built-in Safety
- **Solidity 0.8+**: Automatic overflow/underflow protection
- **No external dependencies**: Minimal attack surface
- **Tested extensively**: 24 tests including fuzz tests

## 📊 Gas Report

| Function       | Min   | Avg   | Median | Max   |
|---------------|-------|-------|--------|-------|
| deposit       | 22819 | 22819 | 22819  | 22819 |
| extendLock    | 21706 | 28306 | 28365  | 28377 |
| withdraw      | 21276 | 29741 | 35028  | 35028 |
| getBalance    | 335   | 335   | 335    | 335   |

**Deployment Cost**: ~465,557 gas

## 📝 Contract Interface

```solidity
interface ITimeLockedVault {
    // State variables
    function owner() external view returns (address);
    function unlockTime() external view returns (uint256);

    // Core functions
    function deposit() external payable;
    function withdraw() external;
    function extendLock(uint256 newTime) external;

    // View functions
    function getBalance() external view returns (uint256);
    function getTimeUntilUnlock() external view returns (uint256);

    // Events
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 oldUnlockTime, uint256 newUnlockTime);

    // Errors
    error FundsLocked();
    error OnlyOwner();
    error InvalidUnlockTime();
    error CannotReduceLockTime();
    error WithdrawalFailed();
}
```

## 🎯 Requirements Checklist

### Core Requirements
- ✅ Owner can deposit ETH easily
- ✅ Funds locked until specific unlockTime
- ✅ Withdrawals before time limit fail (revert)
- ✅ Only owner can withdraw after time limit
- ✅ Owner can extend lock time but never reduce it

### Must-Haves
- ✅ Constructor initializes owner and unlockTime
- ✅ Public state variables for owner and unlockTime
- ✅ Payable deposit() function with event emission
- ✅ extendLock() function with validation
- ✅ withdraw() with time and owner checks
- ✅ Custom error handling
- ✅ Event emissions for all state changes

### Security Requirements
- ✅ Solidity ^0.8.x with overflow safety
- ✅ onlyOwner access control
- ✅ block.timestamp for time comparisons
- ✅ Checks-Effects-Interactions pattern
- ✅ Cannot deploy with unlockTime in the past

## 🤝 Contributing

This is a capstone project, but suggestions and improvements are welcome!

## 📄 License

MIT License - see LICENSE file for details

## 🔗 Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Ethereum Sepolia Faucet](https://sepoliafaucet.com/)

## 👨‍💻 Author

Built as part of the Ethereum Foundations Capstone challenge.

---

**⚠️ Disclaimer**: This is an educational project. Use at your own risk. Always audit smart contracts before deploying to mainnet.
