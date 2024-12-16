import React from 'react';
import { useWeb3React } from '@web3-react/core';
import { Web3Provider } from '@ethersproject/providers';
import { DAOService } from '../services/dao';
import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Input } from './ui/input';
import { FileText } from 'lucide-react';

export function CreateProposal() {
  const { library, account } = useWeb3React<Web3Provider>();
  const [proposalText, setProposalText] = React.useState('');
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState<string>();

  const daoService = React.useMemo(() => {
    if (library) {
      return new DAOService(import.meta.env.VITE_DAO_CONTRACT_ADDRESS || '', library);
    }
    return null;
  }, [library]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!daoService || !account || !proposalText.trim()) return;

    try {
      setLoading(true);
      setError(undefined);
      await daoService.createProposal(proposalText.trim());
      setProposalText('');
    } catch (err) {
      console.error('Failed to create proposal:', err);
      setError('Failed to create proposal');
    } finally {
      setLoading(false);
    }
  };

  if (!library) {
    return null;
  }

  return (
    <Card className="mb-6">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <FileText className="w-6 h-6" />
          Create Proposal
        </CardTitle>
        <CardDescription>
          Submit a new proposal for the DAO
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="text-red-500">
              Error: {error}
            </div>
          )}
          <Input
            placeholder="Enter your proposal text"
            value={proposalText}
            onChange={(e) => setProposalText(e.target.value)}
            disabled={loading}
          />
          <Button
            type="submit"
            disabled={loading || !proposalText.trim()}
            className="w-full"
          >
            {loading ? 'Creating...' : 'Submit Proposal'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
