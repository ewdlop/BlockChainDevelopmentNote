const Web3 = require('web3');
const contractABI = [/* ABI from the compiled contract */];
const contractAddress = 'YOUR_CONTRACT_ADDRESS';
const web3 = new Web3('http://localhost:8545'); // Replace with your Ethereum node URL

const simulationContract = new web3.eth.Contract(contractABI, contractAddress);

async function addObject(x, y, vx, vy) {
    const accounts = await web3.eth.getAccounts();
    await simulationContract.methods.addObject(x, y, vx, vy).send({ from: accounts[0] });
}

async function updateObject(objectId, x, y, vx, vy) {
    const accounts = await web3.eth.getAccounts();
    await simulationContract.methods.updateObject(objectId, x, y, vx, vy).send({ from: accounts[0] });
}

async function getObject(objectId) {
    const state = await simulationContract.methods.getObject(objectId).call();
    console.log(`Object ${objectId} - x: ${state[0]}, y: ${state[1]}, vx: ${state[2]}, vy: ${state[3]}`);
}

// Example usage:
addObject(0, 0, 1, 1);
updateObject(1, 10, 10, 1, 1);
getObject(1);
