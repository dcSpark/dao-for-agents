import { ethers } from 'ethers';
import { Web3Provider } from '@ethersproject/providers';
import DAO_ABI from './abi/dao-voting.json';

export interface Proposal {
  text: string;
  yesVotes: number;
  noVotes: number;
  executed: boolean;
  isMembershipProposal: boolean;
  proposedMember: string;
}

export class DAOService {
  private daoContract: ethers.Contract;
  private web3Provider: Web3Provider;

  constructor(contractAddress: string, provider: Web3Provider) {
    this.web3Provider = provider;
    this.daoContract = new ethers.Contract(contractAddress, DAO_ABI, provider);
  }

  async createProposal(text: string) {
    const signer = this.web3Provider.getSigner();
    const signedContract = this.daoContract.connect(signer);
    return await signedContract.submitProposal(text);
  }

  async createMembershipProposal(address: string) {
    const signer = this.web3Provider.getSigner();
    const signedContract = this.daoContract.connect(signer);
    return await signedContract.submitMembershipProposal(address);
  }

  async vote(proposalId: number, support: boolean) {
    const signer = this.web3Provider.getSigner();
    const signedContract = this.daoContract.connect(signer);
    return await signedContract.vote(proposalId, support);
  }

  async isMember(address: string): Promise<boolean> {
    return await this.daoContract.isMember(address);
  }

  async getProposalCount(): Promise<number> {
    return (await this.daoContract.getProposalCount()).toNumber();
  }

  async getProposal(proposalId: number): Promise<Proposal> {
    const [text, yesVotes, noVotes, executed, isMembershipProposal, proposedMember] =
      await this.daoContract.getProposal(proposalId);

    return {
      text,
      yesVotes: yesVotes.toNumber(),
      noVotes: noVotes.toNumber(),
      executed,
      isMembershipProposal,
      proposedMember
    };
  }

  async getAcceptedProposals(): Promise<Proposal[]> {
    const count = await this.getProposalCount();
    const proposals: Proposal[] = [];

    for (let i = 0; i < count; i++) {
      const proposal = await this.getProposal(i);
      if (proposal.executed) {
        proposals.push(proposal);
      }
    }

    return proposals;
  }
}
