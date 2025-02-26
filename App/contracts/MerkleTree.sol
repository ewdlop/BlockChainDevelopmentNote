// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MerkleTree {
    bytes32 public root;
    
    // Verify a Merkle proof - proves that a leaf is part of the tree
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf,
        uint256 index
    ) public pure returns (bool) {
        bytes32 computedHash = leaf;
        
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            
            if (index % 2 == 0) {
                // Hash(current, proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(proof, current)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
            
            index = index / 2;
        }
        
        return computedHash == root;
    }
    
    // Helper function to compute a node hash
    function hashNode(bytes32 left, bytes32 right) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(left, right));
    }
    
    // Helper function to compute a leaf hash
    function hashLeaf(bytes calldata data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }
}
