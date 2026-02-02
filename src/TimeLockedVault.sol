// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TimeLockedVault
 * @notice A savings vault that enforces a mandatory holding period for deposited ETH
 * @dev Implements time-locked withdrawals with owner-only access control
 */
contract TimeLockedVault {
    // ============ State Variables ============
    
    /// @notice The address of the vault owner
    address public immutable OWNER;
    
    /// @notice The timestamp when funds can be withdrawn
    uint256 public unlockTime;
    
    // ============ Events ============
    
    /// @notice Emitted when ETH is deposited into the vault
    /// @param sender The address that deposited the funds
    /// @param amount The amount of ETH deposited
    event Deposit(address indexed sender, uint256 amount);
    
    /// @notice Emitted when ETH is withdrawn from the vault
    /// @param amount The amount of ETH withdrawn
    /// @param timestamp The timestamp when the withdrawal occurred
    event Withdrawal(uint256 amount, uint256 timestamp);
    
    /// @notice Emitted when the unlock time is extended
    /// @param oldUnlockTime The previous unlock time
    /// @param newUnlockTime The new unlock time
    event LockExtended(uint256 oldUnlockTime, uint256 newUnlockTime);
    
    // ============ Errors ============
    
    /// @notice Thrown when attempting to withdraw before the unlock time
    error FundsLocked();
    
    /// @notice Thrown when a non-owner attempts to call an owner-only function
    error OnlyOwner();
    
    /// @notice Thrown when trying to set an unlock time in the past
    error InvalidUnlockTime();
    
    /// @notice Thrown when trying to reduce the lock time
    error CannotReduceLockTime();
    
    /// @notice Thrown when withdrawal transfer fails
    error WithdrawalFailed();
    
    // ============ Modifiers ============
    
    /// @notice Restricts function access to the owner only
    modifier onlyOwner() {
        if (msg.sender != OWNER) revert OnlyOwner();
        _;
    }
    
    // ============ Constructor ============
    
    /// @notice Initializes the vault with an owner and unlock time
    /// @param _unlockTime The initial unlock timestamp (must be in the future)
    constructor(uint256 _unlockTime) {
        if (_unlockTime <= block.timestamp) revert InvalidUnlockTime();
        
        OWNER = msg.sender;
        unlockTime = _unlockTime;
    }
    
    // ============ External Functions ============
    
    /// @notice Deposits ETH into the vault
    /// @dev Anyone can deposit, but only the owner can withdraw
    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    
    /// @notice Allows the contract to receive ETH directly
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    
    /// @notice Extends the lock time to a new future timestamp
    /// @param newTime The new unlock timestamp (must be greater than current unlockTime)
    /// @dev Can only be called by the owner and cannot reduce the lock time
    function extendLock(uint256 newTime) external onlyOwner {
        if (newTime <= unlockTime) revert CannotReduceLockTime();
        
        uint256 oldTime = unlockTime;
        unlockTime = newTime;
        
        emit LockExtended(oldTime, newTime);
    }
    
    /// @notice Withdraws all funds from the vault to the owner
    /// @dev Can only be called by the owner after the unlock time has passed
    function withdraw() external onlyOwner {
        // Checks
        if (block.timestamp < unlockTime) revert FundsLocked();
        
        uint256 balance = address(this).balance;
        
        // Effects (emit event before transfer)
        emit Withdrawal(balance, block.timestamp);
        
        // Interactions
        (bool success, ) = OWNER.call{value: balance}("");
        if (!success) revert WithdrawalFailed();
    }
    
    // ============ View Functions ============
    
    /// @notice Returns the current balance of the vault
    /// @return The vault's ETH balance in wei
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /// @notice Returns the time remaining until unlock
    /// @return The number of seconds until unlock (0 if already unlocked)
    function getTimeUntilUnlock() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }
}

