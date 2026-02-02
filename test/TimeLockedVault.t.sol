// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TimeLockedVault} from "../src/TimeLockedVault.sol";

contract TimeLockedVaultTest is Test {
    TimeLockedVault public vault;
    
    address public owner = address(1);
    address public user = address(2);
    
    uint256 public constant LOCK_DURATION = 5 minutes;
    uint256 public unlockTime;
    
    // Events to test
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 oldUnlockTime, uint256 newUnlockTime);
    
    function setUp() public {
        unlockTime = block.timestamp + LOCK_DURATION;
        
        vm.prank(owner);
        vault = new TimeLockedVault(unlockTime);
    }
    
    // ============ Constructor Tests ============
    
    function test_Constructor_SetsOwner() public view {
        assertEq(vault.OWNER(), owner);
    }
    
    function test_Constructor_SetsUnlockTime() public view {
        assertEq(vault.unlockTime(), unlockTime);
    }
    
    function test_Constructor_RevertsIfUnlockTimeInPast() public {
        vm.prank(owner);
        vm.expectRevert(TimeLockedVault.InvalidUnlockTime.selector);
        new TimeLockedVault(block.timestamp - 1);
    }
    
    function test_Constructor_RevertsIfUnlockTimeIsNow() public {
        vm.prank(owner);
        vm.expectRevert(TimeLockedVault.InvalidUnlockTime.selector);
        new TimeLockedVault(block.timestamp);
    }
    
    // ============ Deposit Tests ============
    
    function test_Deposit_AcceptsETH() public {
        uint256 depositAmount = 1 ether;
        
        vm.deal(user, depositAmount);
        vm.prank(user);
        vault.deposit{value: depositAmount}();
        
        assertEq(address(vault).balance, depositAmount);
    }
    
    function test_Deposit_EmitsEvent() public {
        uint256 depositAmount = 1 ether;
        
        vm.deal(user, depositAmount);
        vm.prank(user);
        
        vm.expectEmit(true, false, false, true);
        emit Deposit(user, depositAmount);
        
        vault.deposit{value: depositAmount}();
    }
    
    function test_Deposit_AllowsMultipleDeposits() public {
        vm.deal(owner, 5 ether);
        
        vm.prank(owner);
        vault.deposit{value: 1 ether}();
        
        vm.prank(owner);
        vault.deposit{value: 2 ether}();
        
        assertEq(address(vault).balance, 3 ether);
    }
    
    function test_Receive_AcceptsETH() public {
        uint256 depositAmount = 1 ether;
        
        vm.deal(user, depositAmount);
        vm.prank(user);
        (bool success, ) = address(vault).call{value: depositAmount}("");
        
        assertTrue(success);
        assertEq(address(vault).balance, depositAmount);
    }
    
    // ============ Withdraw Tests ============
    
    function test_Withdraw_RevertsBeforeUnlockTime() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        vault.deposit{value: 1 ether}();
        
        vm.prank(owner);
        vm.expectRevert(TimeLockedVault.FundsLocked.selector);
        vault.withdraw();
    }
    
    function test_Withdraw_SucceedsAfterUnlockTime() public {
        uint256 depositAmount = 1 ether;
        vm.deal(owner, depositAmount);
        
        vm.prank(owner);
        vault.deposit{value: depositAmount}();
        
        // Fast forward time
        vm.warp(unlockTime);
        
        uint256 ownerBalanceBefore = owner.balance;
        
        vm.prank(owner);
        vault.withdraw();
        
        assertEq(owner.balance, ownerBalanceBefore + depositAmount);
        assertEq(address(vault).balance, 0);
    }
    
    function test_Withdraw_EmitsEvent() public {
        uint256 depositAmount = 1 ether;
        vm.deal(owner, depositAmount);
        
        vm.prank(owner);
        vault.deposit{value: depositAmount}();
        
        vm.warp(unlockTime);
        
        vm.prank(owner);
        vm.expectEmit(false, false, false, true);
        emit Withdrawal(depositAmount, unlockTime);
        
        vault.withdraw();
    }
    
    function test_Withdraw_RevertsIfNotOwner() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        vault.deposit{value: 1 ether}();

        vm.warp(unlockTime);

        vm.prank(user);
        vm.expectRevert(TimeLockedVault.OnlyOwner.selector);
        vault.withdraw();
    }

    // ============ ExtendLock Tests ============

    function test_ExtendLock_ExtendsUnlockTime() public {
        uint256 newUnlockTime = unlockTime + 10 minutes;

        vm.prank(owner);
        vault.extendLock(newUnlockTime);

        assertEq(vault.unlockTime(), newUnlockTime);
    }

    function test_ExtendLock_EmitsEvent() public {
        uint256 newUnlockTime = unlockTime + 10 minutes;

        vm.prank(owner);
        vm.expectEmit(false, false, false, true);
        emit LockExtended(unlockTime, newUnlockTime);

        vault.extendLock(newUnlockTime);
    }

    function test_ExtendLock_RevertsIfNotOwner() public {
        uint256 newUnlockTime = unlockTime + 10 minutes;

        vm.prank(user);
        vm.expectRevert(TimeLockedVault.OnlyOwner.selector);
        vault.extendLock(newUnlockTime);
    }

    function test_ExtendLock_RevertsIfReducingTime() public {
        uint256 shorterTime = unlockTime - 1 minutes;

        vm.prank(owner);
        vm.expectRevert(TimeLockedVault.CannotReduceLockTime.selector);
        vault.extendLock(shorterTime);
    }

    function test_ExtendLock_RevertsIfSameTime() public {
        vm.prank(owner);
        vm.expectRevert(TimeLockedVault.CannotReduceLockTime.selector);
        vault.extendLock(unlockTime);
    }

    function test_ExtendLock_PreventsWithdrawalUntilNewTime() public {
        uint256 depositAmount = 1 ether;
        vm.deal(owner, depositAmount);

        vm.prank(owner);
        vault.deposit{value: depositAmount}();

        // Extend lock
        uint256 newUnlockTime = unlockTime + 10 minutes;
        vm.prank(owner);
        vault.extendLock(newUnlockTime);

        // Try to withdraw at original unlock time
        vm.warp(unlockTime);
        vm.prank(owner);
        vm.expectRevert(TimeLockedVault.FundsLocked.selector);
        vault.withdraw();

        // Should succeed at new unlock time
        vm.warp(newUnlockTime);
        vm.prank(owner);
        vault.withdraw();

        assertEq(address(vault).balance, 0);
    }

    // ============ View Function Tests ============

    function test_GetBalance_ReturnsCorrectBalance() public {
        assertEq(vault.getBalance(), 0);

        vm.deal(owner, 5 ether);
        vm.prank(owner);
        vault.deposit{value: 3 ether}();

        assertEq(vault.getBalance(), 3 ether);
    }

    function test_GetTimeUntilUnlock_ReturnsCorrectTime() public {
        uint256 timeRemaining = vault.getTimeUntilUnlock();
        assertEq(timeRemaining, LOCK_DURATION);

        // Fast forward 2 minutes
        vm.warp(block.timestamp + 2 minutes);
        timeRemaining = vault.getTimeUntilUnlock();
        assertEq(timeRemaining, LOCK_DURATION - 2 minutes);
    }

    function test_GetTimeUntilUnlock_ReturnsZeroAfterUnlock() public {
        vm.warp(unlockTime);
        assertEq(vault.getTimeUntilUnlock(), 0);

        vm.warp(unlockTime + 100 days);
        assertEq(vault.getTimeUntilUnlock(), 0);
    }

    // ============ Fuzz Tests ============

    function testFuzz_Deposit_AcceptsAnyAmount(uint96 amount) public {
        vm.assume(amount > 0);

        vm.deal(user, amount);
        vm.prank(user);
        vault.deposit{value: amount}();

        assertEq(address(vault).balance, amount);
    }

    function testFuzz_ExtendLock_AcceptsAnyFutureTime(uint256 additionalTime) public {
        vm.assume(additionalTime > 0 && additionalTime < 365 days);

        uint256 newUnlockTime = unlockTime + additionalTime;

        vm.prank(owner);
        vault.extendLock(newUnlockTime);

        assertEq(vault.unlockTime(), newUnlockTime);
    }

    // ============ Integration Tests ============

    function test_FullCycle_DepositExtendWithdraw() public {
        // Deposit
        uint256 depositAmount = 10 ether;
        vm.deal(owner, depositAmount);
        vm.prank(owner);
        vault.deposit{value: depositAmount}();

        // Extend lock
        uint256 newUnlockTime = unlockTime + 1 hours;
        vm.prank(owner);
        vault.extendLock(newUnlockTime);

        // Wait until new unlock time
        vm.warp(newUnlockTime);

        // Withdraw
        uint256 ownerBalanceBefore = owner.balance;
        vm.prank(owner);
        vault.withdraw();

        assertEq(owner.balance, ownerBalanceBefore + depositAmount);
        assertEq(address(vault).balance, 0);
    }
}

