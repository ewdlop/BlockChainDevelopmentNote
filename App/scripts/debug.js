const Web3 = require('web3');
const contractABI = [/* ABI from your compiled contract */];
const contractAddress = 'DEPLOYED_CONTRACT_ADDRESS'; // Replace with your deployed contract address
const web3 = new Web3('http://localhost:8545');

const contract = new web3.eth.Contract(contractABI, contractAddress);

contract.events.LogMessage({}, (error, event) => {
    if (error) {
        console.error(error);
    } else {
        console.log('LogMessage:', event.returnValues.message);
    }
});

contract.events.LogNumber({}, (error, event) => {
    if (error) {
        console.error(error);
    } else {
        console.log('LogNumber:', event.returnValues.number);
    }
});