// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {DAOVoting} from "../src/DAOVoting.sol";

contract DAOVotingScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract
        DAOVoting dao = new DAOVoting();

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log the deployed contract address
        console2.log("DAOVoting deployed to:", address(dao));
    }
}
