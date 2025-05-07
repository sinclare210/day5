// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {AdminOnly} from "../src/AdminOnly.sol";

contract AdminOlnyScript is Script {
    AdminOnly public adminOnly;

    function run() public {
        vm.startBroadcast();

        adminOnly = new AdminOnly();

        vm.stopBroadcast();
    }

    function setUp() public {}
}
