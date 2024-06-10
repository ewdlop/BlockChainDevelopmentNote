// app.js
let web3;
let account;
let socialNetwork;

const connectMetaMask = async () => {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        account = (await web3.eth.getAccounts())[0];
        document.getElementById('account').innerText = account;

        const networkId = await web3.eth.net.getId();
        const deployedNetwork = SocialNetwork.networks[networkId];
        socialNetwork = new web3.eth.Contract(
            SocialNetwork.abi,
            deployedNetwork && deployedNetwork.address
        );

        document.getElementById('postButton').addEventListener('click', createPost);
    } else {
        console.error('MetaMask is not installed');
    }
};

const createPost = async () => {
    const content = document.getElementById('content').value;
    await socialNetwork.methods.createPost(content).send({ from: account });
    alert('Post created!');
};

document.getElementById('connectButton').addEventListener('click', connectMetaMask);
