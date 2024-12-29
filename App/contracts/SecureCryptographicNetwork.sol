```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract manages public keys and provides encryption and decryption functions.
contract SecureCryptographicNetwork {
    mapping(address => bytes32) public publicKeys;
    address public owner;

    event PublicKeyRegistered(address indexed participant, bytes32 publicKey);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to register a public key for the sender
    function register(bytes32 publicKey) public {
        publicKeys[msg.sender] = publicKey;
        emit PublicKeyRegistered(msg.sender, publicKey);
    }

    // Function to encrypt data using a public key
    function encrypt(bytes32 data, bytes32 publicKey) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data, publicKey));
    }

    // Function to decrypt data using a private key
    function decrypt(bytes32 encryptedData, bytes32 privateKey) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(encryptedData, privateKey));
    }
}
