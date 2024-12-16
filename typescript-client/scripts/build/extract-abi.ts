import { promises as fs } from 'fs';
import path from 'path';

async function extractABI() {
  try {
    // Read the Forge output file
    const artifactPath = path.join(__dirname, '../../../out/DAOVoting.sol/DAOVoting.json');
    const artifact = JSON.parse(await fs.readFile(artifactPath, 'utf8'));

    // Extract the ABI
    const abi = artifact.metadata.output.abi;

    // Create the output directory and file
    const abiPath = path.join(__dirname, '../../src/abi/dao-voting.json');
    await fs.mkdir(path.dirname(abiPath), { recursive: true });
    await fs.writeFile(abiPath, JSON.stringify(abi, null, 2));

    console.log('ABI extracted successfully to', abiPath);
  } catch (error) {
    console.error('Error extracting ABI:', error);
    process.exit(1);
  }
}

// Run the extraction
extractABI();
