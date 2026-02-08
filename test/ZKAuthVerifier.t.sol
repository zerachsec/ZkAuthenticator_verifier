// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ZKAuthVerifier.sol";

contract ZKAuthVerifierTest is Test {
    ZKAuthVerifier public zkAuth;
    address public owner;
    address public user1;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        zkAuth = new ZKAuthVerifier();
    }

    function testDeployment() public view {
        assertEq(zkAuth.owner(), owner);
        assertEq(zkAuth.AUTH_VALIDITY_PERIOD(), 24 hours);
    }

    function testNotAuthenticatedByDefault() public view {
        assertFalse(zkAuth.isAuthenticated(user1));
    }

    function testGetAuthDetailsForUnauthenticated() public view {
        (bool authenticated, uint256 timestamp, uint256 timeRemaining) = zkAuth.getAuthDetails(user1);

        assertFalse(authenticated);
        assertEq(timestamp, 0);
        assertEq(timeRemaining, 0);
    }
}
