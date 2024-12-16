import { Web3ReactProvider } from '@web3-react/core';
import { ethers } from 'ethers';
import { WalletConnection } from './components/WalletConnection';
import { ProposalList } from './components/ProposalList';
import { CreateProposal } from './components/CreateProposal';
import { MembershipProposal } from './components/MembershipProposal';

function getLibrary(provider: any): ethers.providers.Web3Provider {
  const library = new ethers.providers.Web3Provider(provider, 'any');
  library.pollingInterval = 12000;
  return library;
}

function App() {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <div className="min-h-screen bg-gray-50">
        <header className="bg-white shadow">
          <div className="container mx-auto px-4 py-6">
            <h1 className="text-3xl font-bold text-gray-900">DAO Governance</h1>
          </div>
        </header>
        <main className="container mx-auto px-4 py-8">
          <div className="max-w-4xl mx-auto space-y-6">
            <WalletConnection />
            <div className="grid gap-6">
              <CreateProposal />
              <MembershipProposal />
              <ProposalList />
            </div>
          </div>
        </main>
      </div>
    </Web3ReactProvider>
  );
}

export default App;
