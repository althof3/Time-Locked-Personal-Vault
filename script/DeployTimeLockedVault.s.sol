// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TimeLockedVault} from "../src/TimeLockedVault.sol";

contract DeployTimeLockedVault is Script {
    uint256 public constant DEFAULT_LOCK_DURATION = 5 minutes;

    function run() external returns (TimeLockedVault) {
        uint256 unlockTime = block.timestamp + DEFAULT_LOCK_DURATION;

        console.log("Deploying TimeLockedVault...");
        console.log("Deployer address:", msg.sender);
        console.log("Current timestamp:", block.timestamp);
        console.log("Unlock time:", unlockTime);
        console.log("Lock duration (seconds):", DEFAULT_LOCK_DURATION);

        vm.startBroadcast();

        TimeLockedVault vault = new TimeLockedVault(unlockTime);

        console.log("TimeLockedVault deployed at:", address(vault));
        console.log("Owner:", vault.OWNER());
        console.log("Unlock time:", vault.unlockTime());

        vm.stopBroadcast();

        return vault;
    }

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
