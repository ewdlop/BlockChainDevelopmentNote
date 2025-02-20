const Web3 = require('web3');
require('dotenv').config();
const log4js = require('log4js');

// Configure log4js
log4js.configure({
  appenders: {
    console: { type: 'console' }, // Logs to the console
    file: { type: 'file', filename: 'nft.log' }, // Logs to a file
    // Add more appenders as needed (e.g., for different log levels)
  },
  categories: {
    default: { appenders: ['console', 'file'], level: 'info' }, // Default category
    // You can create different categories for different parts of your app
    // nft: { appenders: ['file'], level: 'debug' }  For more detailed NFT logs
  },
});

const logger = log4js.getLogger(); // Get the default logger
// const logger = log4js.getLogger('nft'); // To use the 'nft' category


const web3 = new Web3('http://localhost:8545');

const account = process.env.ACCOUNT_ADDRESS;

function maskAccountAddress(address) {
  if (address && address.length > 10) {
    return address.substring(0, 6) + '...' + address.substring(address.length - 4);
  }
  return address;
}

logger.info(`Account address: ${maskAccountAddress(account)}`); // Log the masked account address

// Example usage of different log levels:
// logger.debug('This is a debug message.');
// logger.info('This is an info message.');
// logger.warn('This is a warning message.');
// logger.error('This is an error message.');


// const contractAddress = MyNFT.networks['5777'].address;
// const contract = new web3.eth.Contract(MyNFT.abi, contractAddress);

// async function mintNFT() {
//     try {
//         const tx = await contract.methods.mintNFT(account).send({ from: account });
//         logger.info('Transaction:', tx); // Log the transaction details
//     } catch (error) {
//         logger.error('Error minting NFT:', error); // Log the error
//     }
// }

// mintNFT();


// Example of logging Web3 connection status (you might put this in a function):
async function checkWeb3Connection() {
  try {
    const isConnected = await web3.eth.net.isListening();
    if (isConnected) {
      logger.info('Successfully connected to Ganache.');
      const networkId = await web3.eth.net.getId();
      logger.info(`Network ID: ${networkId}`);

    } else {
        logger.error('Failed to connect to Ganache.');
    }
  } catch (error) {
    logger.error('Error checking Web3 connection:', error);
  }
}

checkWeb3Connection();
