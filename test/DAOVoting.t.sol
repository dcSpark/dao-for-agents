// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DAOVoting} from "../src/DAOVoting.sol";

contract DAOVotingTest is Test {
    DAOVoting public dao;
    address public deployer;
    address public member1;
    address public member2;
    address public initialMember; // Store initial member address

    function setUp() public {
        deployer = address(this);
        member1 = makeAddr("member1");
        member2 = makeAddr("member2");
        initialMember = makeAddr("initial_member");
        address[] memory initialMembers = new address[](1);
        initialMembers[0] = initialMember;
        dao = new DAOVoting(initialMembers);
    }

    function test_DeployerIsMember() public {
        assertTrue(dao.isMember(deployer));
        assertEq(dao.memberCount(), 2);
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

        // Vote yes (need both deployer and initial member for majority)
        dao.vote(proposalId, true);
        vm.prank(initialMember);
        dao.vote(proposalId, true);

        // Check proposal was executed
        (,,, bool executed,,) = dao.getProposal(proposalId);
        assertTrue(executed);
    }

    function test_AddNewMemberThroughVoting() public {
        // Submit membership proposal
        uint256 proposalId = dao.submitMembershipProposal(member1);

        // Vote yes (need both deployer and initial member for majority)
        dao.vote(proposalId, true);
        vm.prank(initialMember);
        dao.vote(proposalId, true);

        // Check member was added
        assertTrue(dao.isMember(member1));
        assertEq(dao.memberCount(), 3);
    }

    function testFail_NonMemberCannotSubmitProposal() public {
        vm.prank(member2); // Use a non-member address
        dao.submitProposal("Should Fail");
    }

    function testFail_NonMemberCannotVote() public {
        uint256 proposalId = dao.submitProposal("Test Proposal");

        vm.prank(member2); // Use a non-member address
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

    function test_IntegrationProposalWorkflow() public {
        // Create a new proposal
        string memory proposalText = "Integration Test Proposal";
        uint256 proposalId = dao.submitProposal(proposalText);

        // Verify proposal was created correctly
        (string memory text, uint256 yesVotes, uint256 noVotes, bool executed,,) = dao.getProposal(proposalId);
        assertEq(text, proposalText);
        assertEq(yesVotes, 0);
        assertEq(noVotes, 0);
        assertFalse(executed);

        // Vote on the proposal (need both deployer and initial member for majority)
        dao.vote(proposalId, true);
        vm.prank(initialMember);
        dao.vote(proposalId, true);

        // Verify vote was counted and proposal was executed
        (, yesVotes, noVotes, executed,,) = dao.getProposal(proposalId);
        assertEq(yesVotes, 2);
        assertEq(noVotes, 0);
        assertTrue(executed);
    }

    function test_AddMultipleMembersWithSimpleMajority() public {
        address[] memory newMembers = new address[](3);
        newMembers[0] = member1;
        newMembers[1] = member2;
        newMembers[2] = makeAddr("member3");

        // Add first member (need both deployer and initial member for majority)
        uint256 proposal1 = dao.submitMembershipProposal(newMembers[0]);
        dao.vote(proposal1, true);
        vm.prank(initialMember);
        dao.vote(proposal1, true);
        assertTrue(dao.isMember(newMembers[0]));
        assertEq(dao.memberCount(), 3);

        // Add second member (need 2 out of 3 votes)
        uint256 proposal2 = dao.submitMembershipProposal(newMembers[1]);
        dao.vote(proposal2, true);
        vm.prank(initialMember);
        dao.vote(proposal2, true);
        assertTrue(dao.isMember(newMembers[1]));
        assertEq(dao.memberCount(), 4);

        // Add third member (need 3 out of 4 votes)
        uint256 proposal3 = dao.submitMembershipProposal(newMembers[2]);
        dao.vote(proposal3, true);
        vm.prank(initialMember);
        dao.vote(proposal3, true);
        vm.prank(newMembers[0]);
        dao.vote(proposal3, true);
        assertTrue(dao.isMember(newMembers[2]));
        assertEq(dao.memberCount(), 5);
    }

    function test_DeployWithInitialMembers() public {
        address[] memory initialMembers = new address[](2);
        initialMembers[0] = member1;
        initialMembers[1] = member2;

        DAOVoting newDao = new DAOVoting(initialMembers);

        // Check deployer is member
        assertTrue(newDao.isMember(address(this)));

        // Check initial members were added
        assertTrue(newDao.isMember(member1));
        assertTrue(newDao.isMember(member2));
        assertEq(newDao.memberCount(), 3); // deployer + 2 initial members
    }

    function testFail_DeployWithDuplicateMembers() public {
        address[] memory initialMembers = new address[](2);
        initialMembers[0] = member1;
        initialMembers[1] = member1; // Duplicate

        new DAOVoting(initialMembers); // Should fail
    }

    function testFail_DeployWithZeroAddress() public {
        address[] memory initialMembers = new address[](1);
        initialMembers[0] = address(0);

        new DAOVoting(initialMembers); // Should fail
    }

    function testFail_DeployWithNoMembers() public {
        address[] memory initialMembers = new address[](0);
        new DAOVoting(initialMembers); // Should fail when no members are specified
    }
}
