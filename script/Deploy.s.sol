// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ZKAuthVerifier.sol";

/**
 * @title Deploy Script for ZKAuthVerifier
 * @author VISHAAL S
 * @notice Foundry script to deploy ZKAuthVerifier to ZK testnets
 */
contract DeployZKAuth is Script {
    function run() external {
        // Load private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy ZKAuthVerifier
        ZKAuthVerifier zkAuthVerifier = new ZKAuthVerifier();

        console.log("===========================================");
        console.log("ZKAuthVerifier Deployment Complete");
        console.log("===========================================");
        console.log("Contract Address:", address(zkAuthVerifier));
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("Chain ID:", block.chainid);
        console.log("Auth Validity:", zkAuthVerifier.AUTH_VALIDITY_PERIOD(), "seconds (24 hours)");
        console.log("===========================================");

        // Stop broadcasting
        vm.stopBroadcast();

        // Log verification command
        console.log("\nTo verify contract, run:");
        console.log(
            "forge verify-contract --chain-id",
            block.chainid,
            address(zkAuthVerifier),
            "src/ZKAuthVerifier.sol:ZKAuthVerifier"
        );
    }
}
