let web3;
let account;

const connectMetaMask = async () => {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        try {
            // Request account access
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            account = (await web3.eth.getAccounts())[0];
            document.getElementById('account').innerText = account;

            // Get the contract instance
            const contractData = await fetch('MyNFT.json').then(response => response.json());
            const networkId = await web3.eth.net.getId();
            const deployedNetwork = contractData.networks[networkId];
            const contract = new web3.eth.Contract(contractData.abi, deployedNetwork && deployedNetwork.address);

            document.getElementById('walletInfo').style.display = 'block';

            document.getElementById('mintButton').addEventListener('click', async () => {
                try {
                    await contract.methods.mintNFT(account).send({ from: account });
                    alert('NFT Minted!');
                } catch (error) {
                    console.error('Minting failed:', error);
                }
            });
        } catch (error) {
            console.error('User denied account access:', error);
        }
    } else {
        console.error('MetaMask is not installed');
    }
};

async function addCommit() {
    if (contract && account) {
        const commitMessage = 'Initial commit';
        const commitHash = 'hash-of-the-commit';
        try {
            const receipt = await contract.methods.addCommit(commitMessage, commitHash).send({ from: account });
            console.log('Commit added:', receipt);
        } catch (error) {
            console.error('Error adding commit:', error);
        }
    } else {
        console.error('Connect MetaMask first');
    }
}


document.getElementById('connectButton').addEventListener('click', connectMetaMask);
document.getElementById('addCommitButton').addEventListener('click', addCommit);
