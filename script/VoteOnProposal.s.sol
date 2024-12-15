// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {DAOVoting} from "../src/DAOVoting.sol";

contract VoteOnProposalScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address daoAddress = vm.envAddress("DAO_ADDRESS");
        uint256 proposalId = vm.envUint("PROPOSAL_ID");
        bool support = vm.envBool("SUPPORT");

        vm.startBroadcast(deployerPrivateKey);

        DAOVoting dao = DAOVoting(daoAddress);
        dao.vote(proposalId, support);

        vm.stopBroadcast();

        console2.log("Vote cast for proposal:", proposalId);
        console2.log("Support:", support);
    }
}
