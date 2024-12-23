const Web3 = require('web3');
const { abi } = require('./compile')('HL7Exchange');

const web3 = new Web3('http://localhost:8545'); // Replace with your Ethereum node URL

const contractAddress = 'YOUR_DEPLOYED_CONTRACT_ADDRESS'; // Replace with your deployed contract address

const main = async () => {
    const accounts = await web3.eth.getAccounts();
    const hl7Exchange = new web3.eth.Contract(abi, contractAddress);

    // Adding an HL7 message
    await hl7Exchange.methods.addMessage("HL7 Message Content").send({ from: accounts[0] });
    console.log('Message added by:', accounts[0]);

    // Retrieving all messages
    const allMessages = await hl7Exchange.methods.getMessages().call();
    console.log('All messages:', allMessages);

    // Retrieving a specific message by index
    const message = await hl7Exchange.methods.getMessage(0).call();
    console.log('Message 0:', message);
};

main();
