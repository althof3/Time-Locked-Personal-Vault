// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimeLockedVault {
    address public immutable OWNER;
    uint256 public unlockTime;

    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 oldUnlockTime, uint256 newUnlockTime);

    error FundsLocked();
    error OnlyOwner();
    error InvalidUnlockTime();
    error CannotReduceLockTime();
    error WithdrawalFailed();

    modifier onlyOwner() {
        if (msg.sender != OWNER) revert OnlyOwner();
        _;
    }

    constructor(uint256 _unlockTime) {
        if (_unlockTime <= block.timestamp) revert InvalidUnlockTime();

        OWNER = msg.sender;
        unlockTime = _unlockTime;
    }

    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function extendLock(uint256 newTime) external onlyOwner {
        if (newTime <= unlockTime) revert CannotReduceLockTime();

        uint256 oldTime = unlockTime;
        unlockTime = newTime;

        emit LockExtended(oldTime, newTime);
    }

    function withdraw() external onlyOwner {
        if (block.timestamp < unlockTime) revert FundsLocked();

        uint256 balance = address(this).balance;

        emit Withdrawal(balance, block.timestamp);

        (bool success,) = OWNER.call{value: balance}("");
        if (!success) revert WithdrawalFailed();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTimeUntilUnlock() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }
}
