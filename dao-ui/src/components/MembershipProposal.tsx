import React from 'react';
import { useWeb3React } from '@web3-react/core';
import { Web3Provider } from '@ethersproject/providers';
import { DAOService } from '../services/dao';
import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Input } from './ui/input';
import { UserPlus } from 'lucide-react';

export function MembershipProposal() {
  const { library, account } = useWeb3React<Web3Provider>();
  const [address, setAddress] = React.useState('');
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
    if (!daoService || !account || !address.trim()) return;

    try {
      setLoading(true);
      setError(undefined);
      await daoService.createMembershipProposal(address.trim());
      setAddress('');
    } catch (err) {
      console.error('Failed to create membership proposal:', err);
      setError('Failed to create membership proposal');
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
          <UserPlus className="w-6 h-6" />
          Propose New Member
        </CardTitle>
        <CardDescription>
          Submit a proposal to add a new DAO member
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
            placeholder="Enter member address (0x...)"
            value={address}
            onChange={(e) => setAddress(e.target.value)}
            disabled={loading}
            pattern="^0x[a-fA-F0-9]{40}$"
            title="Please enter a valid Ethereum address"
          />
          <Button
            type="submit"
            disabled={loading || !address.trim()}
            className="w-full"
          >
            {loading ? 'Creating...' : 'Submit Member Proposal'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
