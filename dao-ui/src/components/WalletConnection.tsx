import React from 'react';
import { useWeb3React } from '@web3-react/core';
import { Web3Provider } from '@ethersproject/providers';
import { injected } from '../services/wallet';
import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Wallet, LogOut } from 'lucide-react';

export function WalletConnection() {
  const { connector, library, chainId, account, activate, deactivate } = useWeb3React<Web3Provider>();
  const [error, setError] = React.useState<Error | undefined>();

  const handleConnect = async () => {
    setError(undefined);
    try {
      await activate(injected);
    } catch (err) {
      console.error('Failed to connect:', err);
      setError(err instanceof Error ? err : new Error('Failed to connect'));
    }
  };

  const handleDisconnect = () => {
    try {
      deactivate();
    } catch (err) {
      console.error('Failed to disconnect:', err);
    }
  };

  const isConnected = typeof account === 'string' && !!library;

  return (
    <Card className="mb-6">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Wallet className="w-6 h-6" />
          Wallet Connection
        </CardTitle>
        <CardDescription>
          Connect your wallet to interact with the DAO
        </CardDescription>
      </CardHeader>
      <CardContent>
        {error ? (
          <div className="text-red-500 mb-4">
            Error: {error.message}
          </div>
        ) : null}

        {isConnected ? (
          <div className="space-y-4">
            <p className="text-sm">
              Connected Account: {account}
            </p>
            {chainId && (
              <p className="text-sm">
                Network ID: {chainId}
              </p>
            )}
            <Button
              variant="destructive"
              onClick={handleDisconnect}
              className="flex items-center gap-2"
            >
              <LogOut className="w-4 h-4" />
              Disconnect Wallet
            </Button>
          </div>
        ) : (
          <Button
            onClick={handleConnect}
            className="flex items-center gap-2"
          >
            <Wallet className="w-4 h-4" />
            Connect Wallet
          </Button>
        )}
      </CardContent>
    </Card>
  );
}
