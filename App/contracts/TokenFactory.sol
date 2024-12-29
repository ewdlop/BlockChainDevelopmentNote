```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

// This contract creates ERC20 tokens and manages user tokens.
contract TokenFactory {
    address public owner;
    mapping(address => address[]) public userTokens;

    event TokenCreated(address indexed creator, address tokenAddress);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to create a new ERC20 token
    function createToken(string memory name, string memory symbol, uint256 initialSupply) public {
        ERC20 newToken = new ERC20(name, symbol, initialSupply);
        userTokens[msg.sender].push(address(newToken));
        emit TokenCreated(msg.sender, address(newToken));
    }

    // Function to get the list of tokens created by a user
    function getUserTokens(address user) public view returns (address[] memory) {
        return userTokens[user];
    }
}
