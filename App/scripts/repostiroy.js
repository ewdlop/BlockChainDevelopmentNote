const Web3 = require('web3');
const contract = require('@truffle/contract');
const CodeRepositoryArtifact = require('./build/contracts/CodeRepository.json');

// Connect to the private blockchain
const web3 = new Web3('http://localhost:8545');

// Get the contract instance
const CodeRepository = contract(CodeRepositoryArtifact);
CodeRepository.setProvider(web3.currentProvider);

const main = async () => {
    const accounts = await web3.eth.getAccounts();
    const repo = await CodeRepository.deployed();

    // Add a commit
    const commitMessage = 'Initial commit';
    const commitHash = 'hash-of-the-commit';
    await repo.addCommit(commitMessage, commitHash, { from: accounts[0] });

    // Get the number of commits
    const count = await repo.getCommitsCount();
    console.log('Number of commits:', count.toString());

    // Retrieve a commit
    const commit = await repo.getCommit(0);
    console.log('Commit 0:', {
        author: commit[0],
        message: commit[1],
        hash: commit[2],
        timestamp: new Date(commit[3] * 1000).toLocaleString(),
    });
};

main().catch(error => {
    console.error(error);
    process.exit(1);
});
