const Web3 = require('web3');
const { abi } = require('./compile')('ExperimentalData');

const web3 = new Web3('http://localhost:8545'); // Replace with your Ethereum node URL

const contractAddress = 'YOUR_DEPLOYED_CONTRACT_ADDRESS'; // Replace with your deployed contract address

const main = async () => {
    const accounts = await web3.eth.getAccounts();
    const experimentalData = new web3.eth.Contract(abi, contractAddress);

    // Adding data
    await experimentalData.methods.addData("Experiment 1 data").send({ from: accounts[0] });
    console.log('Data added by:', accounts[0]);

    // Retrieving all data entries
    const dataEntries = await experimentalData.methods.getDataEntries().call();
    console.log('Data entries:', dataEntries);

    // Retrieving a specific data entry by index
    const dataEntry = await experimentalData.methods.getDataEntry(0).call();
    console.log('Data entry 0:', dataEntry);
};

main();
