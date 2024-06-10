const Web3 = require('web3');
//const MyNFT = require('../build/contracts/MyNFT.json');
require('dotenv').config(); // To use environment variables

const web3 = new Web3('http://localhost:8545'); // Connect to Ganache

//const contractAddress = MyNFT.networks['5777'].address; // Replace with your network ID if different
//const contract = new web3.eth.Contract(MyNFT.abi, contractAddress);

const account = process.env.ACCOUNT_ADDRESS; // Use environment variable for account

console.log(account)

// async function mintNFT() {
//     try {
//         const tx = await contract.methods.mintNFT(account).send({ from: account });
//         console.log('Transaction:', tx);
//     } catch (error) {
//         console.error('Error minting NFT:', error);
//     }
// }

// mintNFT();
