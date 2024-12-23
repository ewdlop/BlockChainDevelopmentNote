const Web3 = require('web3');
const { abi } = require('./compile')('SecureVoting');

const web3 = new Web3('http://localhost:8545'); // Replace with your Ethereum node URL

const contractAddress = 'YOUR_DEPLOYED_CONTRACT_ADDRESS'; // Replace with your deployed contract address

const main = async () => {
    const accounts = await web3.eth.getAccounts();
    const secureVoting = new web3.eth.Contract(abi, contractAddress);

    // Authorize a voter
    await secureVoting.methods.authorizeVoter(accounts[1]).send({ from: accounts[0] });
    console.log('Voter authorized:', accounts[1]);

    // Cast a vote
    await secureVoting.methods.vote(0).send({ from: accounts[1] });
    console.log('Vote cast by:', accounts[1]);

    // Get voting results
    const results = await secureVoting.methods.getResults().call();
    console.log('Voting results:', results);
};

main();
