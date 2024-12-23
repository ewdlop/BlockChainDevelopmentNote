// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    function register(bytes32 publicKey) public {
        publicKeys[msg.sender] = publicKey;
        emit PublicKeyRegistered(msg.sender, publicKey);
    }

    function encrypt(bytes32 data, bytes32 publicKey) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data, publicKey));
    }

    function decrypt(bytes32 encryptedData, bytes32 privateKey) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(encryptedData, privateKey));
    }
}
