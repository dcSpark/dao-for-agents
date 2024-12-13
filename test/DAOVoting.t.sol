// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DAOVoting} from "../src/DAOVoting.sol";

contract DAOVotingTest is Test {
    DAOVoting public dao;
    address public deployer;
    address public member1;
    address public member2;

    function setUp() public {
        deployer = address(this);
        member1 = makeAddr("member1");
        member2 = makeAddr("member2");
        dao = new DAOVoting();
    }

    function test_DeployerIsMember() public {
        assertTrue(dao.isMember(deployer));
        assertEq(dao.memberCount(), 1);
    }

    function test_SubmitProposal() public {
        string memory proposalText = "Test Proposal";
        uint256 proposalId = dao.submitProposal(proposalText);

        (string memory text,,,,, address proposedMember) = dao.getProposal(proposalId);
        assertEq(text, proposalText);
        assertEq(proposedMember, address(0));
        assertEq(dao.getProposalCount(), 1);
    }

    function test_SubmitMembershipProposal() public {
        uint256 proposalId = dao.submitMembershipProposal(member1);

        (,,,, bool isMembershipProposal, address proposedMember) = dao.getProposal(proposalId);
        assertTrue(isMembershipProposal);
        assertEq(proposedMember, member1);
    }

    function test_VoteAndExecuteProposal() public {
        // Submit proposal
        string memory proposalText = "Test Proposal";
        uint256 proposalId = dao.submitProposal(proposalText);

        // Vote yes (only deployer is member, so this is majority)
        dao.vote(proposalId, true);

        // Check proposal was executed
        (,,,bool executed,,) = dao.getProposal(proposalId);
        assertTrue(executed);
    }

    function test_AddNewMemberThroughVoting() public {
        // Submit membership proposal
        uint256 proposalId = dao.submitMembershipProposal(member1);

        // Vote yes (only deployer is member, so this is majority)
        dao.vote(proposalId, true);

        // Check member was added
        assertTrue(dao.isMember(member1));
        assertEq(dao.memberCount(), 2);
    }

    function testFail_NonMemberCannotSubmitProposal() public {
        vm.prank(member1);
        dao.submitProposal("Should Fail");
    }

    function testFail_NonMemberCannotVote() public {
        uint256 proposalId = dao.submitProposal("Test Proposal");

        vm.prank(member1);
        dao.vote(proposalId, true);
    }

    function testFail_CannotVoteTwice() public {
        uint256 proposalId = dao.submitProposal("Test Proposal");

        dao.vote(proposalId, true);
        dao.vote(proposalId, true); // Should fail
    }

    function testFail_CannotAddExistingMember() public {
        // First add member1
        uint256 proposalId = dao.submitMembershipProposal(member1);
        dao.vote(proposalId, true);

        // Try to add member1 again
        dao.submitMembershipProposal(member1);
    }
}