import { ethers } from 'ethers';

// ABI fragment for the view functions we need
const DAO_ABI = [
  "function getProposalCount() external view returns (uint256)",
  "function getProposal(uint256 _proposalId) external view returns (string memory text, uint256 yesVotes, uint256 noVotes, bool executed, bool isMembershipProposal, address proposedMember)"
];

export interface Proposal {
  text: string;
  yesVotes: number;
  noVotes: number;
  executed: boolean;
  isMembershipProposal: boolean;
  proposedMember: string;
}

export class DAOUtils {
  private contract: ethers.Contract;

  constructor(contractAddress: string, provider: ethers.providers.Provider) {
    this.contract = new ethers.Contract(contractAddress, DAO_ABI, provider);
  }

  async getAcceptedProposals(): Promise<Proposal[]> {
    const count = await this.contract.getProposalCount();
    const proposals: Proposal[] = [];

    for (let i = 0; i < count; i++) {
      const [text, yesVotes, noVotes, executed, isMembershipProposal, proposedMember] =
        await this.contract.getProposal(i);

      if (executed) {
        proposals.push({
          text,
          yesVotes: yesVotes.toNumber(),
          noVotes: noVotes.toNumber(),
          executed,
          isMembershipProposal,
          proposedMember
        });
      }
    }

    return proposals;
  }
}
