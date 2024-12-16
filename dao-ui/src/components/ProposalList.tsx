import React from 'react';
import { useWeb3React } from '@web3-react/core';
import { Web3Provider } from '@ethersproject/providers';
import { DAOService } from '../services/dao';
import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { ThumbsUp, ThumbsDown, Check } from 'lucide-react';

interface Proposal {
  text: string;
  yesVotes: number;
  noVotes: number;
  executed: boolean;
  isMembershipProposal: boolean;
  proposedMember: string;
}

export function ProposalList() {
  const { library, account } = useWeb3React<Web3Provider>();
  const [proposals, setProposals] = React.useState<Proposal[]>([]);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<string>();

  const daoService = React.useMemo(() => {
    if (library) {
      return new DAOService(import.meta.env.VITE_DAO_CONTRACT_ADDRESS || '', library);
    }
    return null;
  }, [library]);

  const loadProposals = React.useCallback(async () => {
    if (!daoService) return;

    try {
      setLoading(true);
      const count = await daoService.getProposalCount();
      const proposalPromises = Array.from({ length: count }, (_, i) =>
        daoService.getProposal(i)
      );
      const loadedProposals = await Promise.all(proposalPromises);
      setProposals(loadedProposals);
      setError(undefined);
    } catch (err) {
      console.error('Failed to load proposals:', err);
      setError('Failed to load proposals');
    } finally {
      setLoading(false);
    }
  }, [daoService]);

  React.useEffect(() => {
    loadProposals();
  }, [loadProposals]);

  const handleVote = async (proposalId: number, support: boolean) => {
    if (!daoService || !account) return;

    try {
      await daoService.vote(proposalId, support);
      await loadProposals(); // Reload after voting
    } catch (err) {
      console.error('Failed to vote:', err);
      setError('Failed to vote on proposal');
    }
  };

  if (!library) {
    return (
      <Card className="mb-6">
        <CardHeader>
          <CardTitle>Proposals</CardTitle>
          <CardDescription>Connect your wallet to view and vote on proposals</CardDescription>
        </CardHeader>
      </Card>
    );
  }

  return (
    <Card className="mb-6">
      <CardHeader>
        <CardTitle>Proposals</CardTitle>
        <CardDescription>View and vote on active proposals</CardDescription>
      </CardHeader>
      <CardContent>
        {error && (
          <div className="text-red-500 mb-4">
            Error: {error}
          </div>
        )}

        {loading ? (
          <div className="text-center py-4">Loading proposals...</div>
        ) : proposals.length === 0 ? (
          <div className="text-center py-4">No proposals found</div>
        ) : (
          <div className="space-y-4">
            {proposals.map((proposal, index) => (
              <Card key={index} className="p-4">
                <div className="flex justify-between items-start">
                  <div className="space-y-2">
                    <h3 className="font-medium">
                      {proposal.isMembershipProposal ? 'Membership Proposal' : 'General Proposal'}
                    </h3>
                    <p className="text-sm">{proposal.text}</p>
                    {proposal.isMembershipProposal && (
                      <p className="text-sm text-gray-500">
                        Proposed Member: {proposal.proposedMember}
                      </p>
                    )}
                    <div className="flex gap-4 text-sm text-gray-500">
                      <span>Yes: {proposal.yesVotes}</span>
                      <span>No: {proposal.noVotes}</span>
                    </div>
                  </div>
                  {proposal.executed ? (
                    <div className="flex items-center text-green-500">
                      <Check className="w-4 h-4 mr-1" />
                      <span className="text-sm">Executed</span>
                    </div>
                  ) : (
                    <div className="flex gap-2">
                      <Button
                        size="sm"
                        variant="outline"
                        className="flex items-center gap-1"
                        onClick={() => handleVote(index, true)}
                      >
                        <ThumbsUp className="w-4 h-4" />
                        Yes
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="flex items-center gap-1"
                        onClick={() => handleVote(index, false)}
                      >
                        <ThumbsDown className="w-4 h-4" />
                        No
                      </Button>
                    </div>
                  )}
                </div>
              </Card>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
