import { ethers } from 'ethers';
import DAO_ABI from './abi/dao-voting.json';

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
