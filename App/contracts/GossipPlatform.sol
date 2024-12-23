// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIPFS {
    function storeContent(string memory content) external returns (string memory);
}

contract GossipPlatform {
    struct User {
        string username;
        uint256 reputation;
        bool registered;
    }

    struct Post {
        address author;
        string ipfsHash;
        uint256 timestamp;
    }

    mapping(address => User) public users;
    Post[] public posts;
    mapping(address => uint256) public balances;

    IIPFS public ipfs;

    event UserRegistered(address indexed user, string username);
    event PostCreated(address indexed author, uint256 postId, string ipfsHash);
    event ReputationUpdated(address indexed user, uint256 newReputation);
    event FundsWithdrawn(address indexed user, uint256 amount);

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }

    constructor(address _ipfs) {
        ipfs = IIPFS(_ipfs);
    }

    // Register a new user with a username
    function registerUser(string memory _username) external {
        require(!users[msg.sender].registered, "User already registered");

        users[msg.sender] = User({
            username: _username,
            reputation: 1, // Initial reputation
            registered: true
        });

        emit UserRegistered(msg.sender, _username);
    }

    // Create a new post and store the content on IPFS
    function createPost(string memory _content) external onlyRegistered {
        string memory ipfsHash = ipfs.storeContent(_content);

        posts.push(Post({
            author: msg.sender,
            ipfsHash: ipfsHash,
            timestamp: block.timestamp
        }));

        emit PostCreated(msg.sender, posts.length - 1, ipfsHash);
    }

    // Upvote a user to increase their reputation
    function upvoteUser(address _user) external onlyRegistered {
        require(users[_user].registered, "User not registered");
        users[_user].reputation += 1;

        emit ReputationUpdated(_user, users[_user].reputation);
    }

    // Downvote a user to decrease their reputation
    function downvoteUser(address _user) external onlyRegistered {
        require(users[_user].registered, "User not registered");
        require(users[_user].reputation > 0, "Reputation cannot be negative");
        users[_user].reputation -= 1;

        emit ReputationUpdated(_user, users[_user].reputation);
    }

    // Get all posts
    function getPosts() external view returns (Post[] memory) {
        return posts;
    }

    // Get user information by address
    function getUser(address _user) external view returns (User memory) {
        return users[_user];
    }

    // Withdraw funds from the contract
    function withdrawFunds() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit FundsWithdrawn(msg.sender, amount);
    }

    // Fallback function to receive Ether
    receive() external payable {
        balances[msg.sender] += msg.value;
    }
}
