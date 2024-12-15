// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract DAOVoting {
    // State variables
    mapping(address => bool) public members;
    uint256 public memberCount;

    struct Proposal {
        string text;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        bool isMembershipProposal;
        address proposedMember;
        mapping(address => bool) hasVoted;
    }

    Proposal[] public proposals;

    // Events
    event ProposalSubmitted(uint256 indexed proposalId, string text);
    event MembershipProposalSubmitted(uint256 indexed proposalId, address proposedMember);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed proposalId);
    event MemberAdded(address indexed member);
    event MemberRemoved(address indexed member);

    constructor(address[] memory _initialMembers) {
        // Add contract deployer as the first member
        members[msg.sender] = true;
        memberCount = 1;

        // Add initial members if provided
        for (uint256 i = 0; i < _initialMembers.length; i++) {
            address member = _initialMembers[i];
            require(member != address(0), "Invalid member address");
            require(!members[member], "Duplicate member");
            members[member] = true;
            memberCount++;
            emit MemberAdded(member);
        }
    }

    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }

    function submitProposal(string memory _text) external onlyMember returns (uint256) {
        uint256 proposalId = proposals.length;
        Proposal storage newProposal = proposals.push();
        newProposal.text = _text;
        newProposal.executed = false;
        newProposal.isMembershipProposal = false;

        emit ProposalSubmitted(proposalId, _text);
        return proposalId;
    }

    function submitMembershipProposal(address _proposedMember) external onlyMember returns (uint256) {
        require(_proposedMember != address(0), "Invalid address");
        require(!members[_proposedMember], "Already a member");

        uint256 proposalId = proposals.length;
        Proposal storage newProposal = proposals.push();
        newProposal.text = string(abi.encodePacked("Add member: ", addressToString(_proposedMember)));
        newProposal.executed = false;
        newProposal.isMembershipProposal = true;
        newProposal.proposedMember = _proposedMember;

        emit MembershipProposalSubmitted(proposalId, _proposedMember);
        return proposalId;
    }

    function vote(uint256 _proposalId, bool _support) external onlyMember {
        require(_proposalId < proposals.length, "Invalid proposal");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Already executed");
        require(!proposal.hasVoted[msg.sender], "Already voted");

        proposal.hasVoted[msg.sender] = true;
        if (_support) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }

        emit Voted(_proposalId, msg.sender, _support);

        // Check if majority is reached
        if (proposal.yesVotes > memberCount / 2) {
            executeProposal(_proposalId);
        }
    }

    function executeProposal(uint256 _proposalId) internal {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Already executed");
        require(proposal.yesVotes > memberCount / 2, "Majority not reached");

        proposal.executed = true;

        if (proposal.isMembershipProposal) {
            members[proposal.proposedMember] = true;
            memberCount++;
            emit MemberAdded(proposal.proposedMember);
        }

        emit ProposalExecuted(_proposalId);
    }

    // Helper function to convert address to string
    function addressToString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    // View functions
    function getProposal(uint256 _proposalId)
        external
        view
        returns (
            string memory text,
            uint256 yesVotes,
            uint256 noVotes,
            bool executed,
            bool isMembershipProposal,
            address proposedMember
        )
    {
        require(_proposalId < proposals.length, "Invalid proposal");
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.text,
            proposal.yesVotes,
            proposal.noVotes,
            proposal.executed,
            proposal.isMembershipProposal,
            proposal.proposedMember
        );
    }

    function isMember(address _address) external view returns (bool) {
        return members[_address];
    }

    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }
}
