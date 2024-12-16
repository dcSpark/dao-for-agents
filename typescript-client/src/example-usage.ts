import { ethers } from 'ethers';
import { DAOUtils } from './dao-utils';

async function main() {
  // Replace with actual values when using in dapp
  const provider = ethers.getDefaultProvider('http://localhost:8545');
  const daoAddress = '0x...'; // Get from contract deployment

  const daoUtils = new DAOUtils(daoAddress, provider);
  const acceptedProposals = await daoUtils.getAcceptedProposals();

  console.log('Accepted Proposals:', acceptedProposals);
}

main().catch(console.error);
