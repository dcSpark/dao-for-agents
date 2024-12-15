// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {DAOVoting} from "../src/DAOVoting.sol";

contract ProposeMemberScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address daoAddress = vm.envAddress("DAO_ADDRESS");
        address proposedMember = vm.envAddress("PROPOSED_MEMBER");

        vm.startBroadcast(deployerPrivateKey);

        DAOVoting dao = DAOVoting(daoAddress);
        uint256 proposalId = dao.submitMembershipProposal(proposedMember);

        vm.stopBroadcast();

        console2.log("Member proposal created with ID:", proposalId);
    }
}
