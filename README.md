# BlockChainDevelopmentNote

## DApp

https://en.wikipedia.org/wiki/Decentralized_application

## Not mine
https://roadmap.sh/blockchain

## Javascript

Play with BlockChain related stuff

https://soliditylang.org/

https://archive.trufflesuite.com/docs/truffle/

https://archive.trufflesuite.com/docs/ganache/

https://archive.trufflesuite.com/docs/vscode-ext/

Integrating Web3 functionality into React applications is streamlined by utilizing specialized hooks that manage blockchain interactions efficiently. Here are some notable React hooks and libraries designed for Web3 integration:

:::contextList

### **web3-react**  
A popular framework for building Ethereum dApps in React. It offers a set of hooks and tools to manage blockchain connections, including wallet integrations like MetaMask. Developed by Uniswap, it provides a maximally extensible, dependency-minimized framework for building modern Ethereum dApps. 
:::

:::contextList

### **Web3 Onboard React**  
Part of the Web3 Onboard suite, this package provides React hooks to connect EVM-compatible wallets, manage transactions, and sign contracts. It supports multiple wallets and offers customization options for styling and theming, enhancing the user onboarding experience. 
:::

:::contextList

### **react-use-web3**  
A React hook that facilitates the use of the Web3 object in decentralized applications (dApps). It simplifies interactions with the Ethereum blockchain by providing hooks to access Web3 functionalities within React components. 
:::

:::contextList

### **web3-react-hooks**  
A set of convenience hooks for Web3 actions in React, enabling interactions with Web3 systems like MetaMask. These hooks assist in managing blockchain connections and user accounts within React applications. 
:::

:::contextList

### **thirdweb React SDK**  
A comprehensive collection of React hooks designed for Web3 applications. It allows developers to connect wallets, interact with smart contracts, and manage blockchain data seamlessly within React apps. 
:::

When selecting a React hook or library for Web3 integration, consider factors such as the specific blockchain functionalities required, compatibility with existing tools, and the level of community support. Each of these libraries offers unique features that can cater to different development needs in the Web3 ecosystem. 

## Crypto Wallet

https://metamask.io/

### Metamask React Hook

https://docs.metamask.io/wallet/connect/metamask-sdk/javascript/react/

https://portfolio.metamask.io/

### Codes

Not production ready

## .Net
https://medium.com/codenx/building-a-blockchain-in-net-06f5e3481aab

2019*(learning experience)
https://learn.microsoft.com/en-us/archive/msdn-magazine/2019/november/blockchain-programming-smart-contracts-in-csharp

https://www.c-sharpcorner.com/article/building-a-blockchain-in-net/


## Python
https://www.geeksforgeeks.org/create-simple-blockchain-using-python/

## Smart Contracts

### Bond Contract

The `BondContract` allows users to issue and redeem bonds. Each bond has a principal amount, interest rate, and maturity date. The contract keeps track of issued bonds and allows bond owners to redeem them after maturity.

### Code Repository

The `CodeRepository` contract manages code commits. Users can add commits with a message and hash, and retrieve commit details.

### Code Review

The `CodeReview` contract handles code submissions and reviews. It allows users to submit code, approve or reject submissions, and manage the number of required approvals.

### Donation Manager

The `DonationManager` contract manages donations and fund allocations. Users can donate funds, and the owner can allocate funds to recipients.

### Election

The `Election` contract conducts elections. It allows the owner to add candidates, authorize voters, and cast votes. The contract also provides functions to end the election and get the results.

### Experimental Data

The `ExperimentalData` contract stores experimental data entries. The owner can add data entries, and users can retrieve all entries or specific entries by index.

### Gossip Platform

The `GossipPlatform` contract allows users to register, create posts, and manage reputations. Users can upvote or downvote others, and withdraw funds from the contract.

### MyNFT

The `MyNFT` contract is an ERC721 contract for minting NFTs. The owner can mint new NFTs and assign them to addresses.

### Option Contract

The `OptionContract` defines an option contract with functions to create and exercise options. Users can create call or put options, and exercise them before expiration.

### Rock-Paper-Scissors

The `RockPaperScissors` contract implements a Rock-Paper-Scissors game with betting and reveal mechanisms. Players can create and join games, reveal moves, and determine the winner.

### Secure Cryptographic Network

The `SecureCryptographicNetwork` contract manages public keys and provides encryption and decryption functions. Users can register public keys and encrypt or decrypt data.

### Secure Voting

The `SecureVoting` contract conducts secure voting. The chairperson can authorize voters, and users can cast votes for proposals. The contract provides functions to get the winning proposal and its name.

### Social Network

The `SocialNetwork` contract allows users to create and retrieve posts. Users can create new posts and get post details by ID.

### Stable Marriage

The `StableMarriage` contract implements the stable marriage algorithm. It finds a stable matching between participants based on their preferences.

### Stock

The `Stock` contract manages stocks with functions to create, transfer, and get balances. Users can create new stocks, transfer stocks, and check balances.

## Deployment Methods

### Deploying MyNFT Contract

To deploy the `MyNFT` contract, use the `App/migrations/2_deploy_contracts.js` script. This script deploys the `MyNFT` contract using the Truffle framework.

Example:
```bash
truffle migrate --network <network_name>
```

### Deploying SecureVoting Contract

To deploy the `SecureVoting` contract, use the `App/scripts/deploy.js` script. This script deploys the `SecureVoting` contract using Web3.js.

Example:
```bash
node App/scripts/deploy.js
```
