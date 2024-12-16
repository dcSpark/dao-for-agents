// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DAOVoting} from "../src/DAOVoting.sol";

contract DAOVotingTypeScriptTest is Test {
    DAOVoting public dao;
    address public deployer;
    address public member1;
    string constant PROPOSAL_TEXT = "Test Proposal for TypeScript Integration";

    function setUp() public {
        deployer = address(this);
        member1 = makeAddr("member1");
        address[] memory initialMembers = new address[](1);
        initialMembers[0] = member1;
        dao = new DAOVoting(initialMembers);
    }

    function test_ProposalWorkflowForTypeScript() public {
        // Submit proposal
        uint256 proposalId = dao.submitProposal(PROPOSAL_TEXT);

        // Vote yes (need both deployer and member1 for majority)
        dao.vote(proposalId, true);
        vm.prank(member1);
        dao.vote(proposalId, true);

        // Verify proposal was executed
        (string memory text, uint256 yesVotes, uint256 noVotes, bool executed,,) = dao.getProposal(proposalId);
        assertTrue(executed, "Proposal should be executed");
        assertEq(text, PROPOSAL_TEXT, "Proposal text should match");
        assertEq(yesVotes, 2, "Should have 2 yes votes");
        assertEq(noVotes, 0, "Should have 0 no votes");

        // Log data for TypeScript integration
        console2.log("=== TypeScript Integration Data ===");
        console2.log("Contract Address:", address(dao));
        console2.log("Total Proposals:", dao.getProposalCount());
        console2.log("Proposal ID:", proposalId);
    }
}
