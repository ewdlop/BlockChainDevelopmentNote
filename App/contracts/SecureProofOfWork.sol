// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureProofOfWork {
    bytes32 public hash;
    uint256 public nonce;
    uint256 public difficulty;
    address public owner;

    event ProofOfWorkCompleted(address indexed miner, uint256 nonce, bytes32 hash);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    constructor(uint256 _difficulty) {
        owner = msg.sender;
        difficulty = _difficulty;
        hash = keccak256(abi.encodePacked(block.timestamp, block.difficulty));
    }

    function mine(uint256 _nonce) public {
        bytes32 newHash = keccak256(abi.encodePacked(_nonce));
        require(uint256(newHash) < difficulty, "Proof of work not valid");
        nonce = _nonce;
        hash = newHash;
        emit ProofOfWorkCompleted(msg.sender, nonce, hash);
    }

    function adjustDifficulty(uint256 _difficulty) public onlyOwner {
        difficulty = _difficulty;
    }
}
