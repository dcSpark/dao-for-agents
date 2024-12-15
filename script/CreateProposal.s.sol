// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {DAOVoting} from "../src/DAOVoting.sol";

contract CreateProposalScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address daoAddress = vm.envAddress("DAO_ADDRESS");
        string memory proposalText = vm.envString("PROPOSAL_TEXT");

        vm.startBroadcast(deployerPrivateKey);

        DAOVoting dao = DAOVoting(daoAddress);
        uint256 proposalId = dao.submitProposal(proposalText);

        vm.stopBroadcast();

        console2.log("Proposal created with ID:", proposalId);
    }
}
