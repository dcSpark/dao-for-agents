# DAO TypeScript Client

A TypeScript client library for interacting with the DAO smart contract. This library provides utilities for retrieving proposal information and interacting with the DAO contract.

## Installation

```bash
cd typescript-client
npm install
```

## Usage

```typescript
import { ethers } from 'ethers';
import { DAOUtils } from './dao-utils';

// Initialize the client
const provider = ethers.getDefaultProvider('YOUR_RPC_URL');
const daoAddress = 'YOUR_DAO_CONTRACT_ADDRESS';
const daoUtils = new DAOUtils(daoAddress, provider);

// Get all accepted proposals
const acceptedProposals = await daoUtils.getAcceptedProposals();
console.log('Accepted Proposals:', acceptedProposals);
```

## Development

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Run tests (when added)
npm test
```

## API Reference

### DAOUtils

The main class for interacting with the DAO contract.

#### Methods

- `getAcceptedProposals()`: Returns an array of all executed proposals
  - Returns: `Promise<Proposal[]>`
  - Each proposal contains:
    - `text`: The proposal text
    - `yesVotes`: Number of yes votes
    - `noVotes`: Number of no votes
    - `executed`: Whether the proposal was executed
    - `isMembershipProposal`: Whether it's a membership proposal
    - `proposedMember`: Address of proposed member (for membership proposals)
