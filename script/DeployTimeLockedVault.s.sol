// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TimeLockedVault} from "../src/TimeLockedVault.sol";

/**
 * @title DeployTimeLockedVault
 * @notice Deployment script for the TimeLockedVault contract
 * @dev Run with: forge script script/DeployTimeLockedVault.s.sol:DeployTimeLockedVault --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
 */
contract DeployTimeLockedVault is Script {
    // Default lock duration: 5 minutes
    uint256 public constant DEFAULT_LOCK_DURATION = 5 minutes;
    
    function run() external returns (TimeLockedVault) {
        // Get the unlock time (5 minutes from now)
        uint256 unlockTime = block.timestamp + DEFAULT_LOCK_DURATION;
        
        console.log("Deploying TimeLockedVault...");
        console.log("Deployer address:", msg.sender);
        console.log("Current timestamp:", block.timestamp);
        console.log("Unlock time:", unlockTime);
        console.log("Lock duration (seconds):", DEFAULT_LOCK_DURATION);
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Deploy the contract
        TimeLockedVault vault = new TimeLockedVault(unlockTime);
        
        console.log("TimeLockedVault deployed at:", address(vault));
        console.log("Owner:", vault.OWNER());
        console.log("Unlock time:", vault.unlockTime());
        
        vm.stopBroadcast();
        
        return vault;
    }
    
    /**
     * @notice Deploy with a custom lock duration
     * @param lockDuration The duration in seconds to lock the funds
     */
    function runWithCustomDuration(uint256 lockDuration) external returns (TimeLockedVault) {
        uint256 unlockTime = block.timestamp + lockDuration;
        
        console.log("Deploying TimeLockedVault with custom duration...");
        console.log("Deployer address:", msg.sender);
        console.log("Current timestamp:", block.timestamp);
        console.log("Unlock time:", unlockTime);
        console.log("Lock duration (seconds):", lockDuration);
        
        vm.startBroadcast();
        
        TimeLockedVault vault = new TimeLockedVault(unlockTime);
        
        console.log("TimeLockedVault deployed at:", address(vault));
        console.log("Owner:", vault.OWNER());
        console.log("Unlock time:", vault.unlockTime());
        
        vm.stopBroadcast();
        
        return vault;
    }
}

