// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ConsistentHashing {
    // Virtual nodes increase distribution
    uint256 public constant VIRTUAL_NODES = 100;
    
    // Maps hash positions to node addresses
    mapping(uint256 => address) public ring;
    uint256[] public sortedPositions;
    
    // Add a node to the hash ring
    function addNode(address node) public {
        for (uint256 i = 0; i < VIRTUAL_NODES; i++) {
            // Create a unique hash for each virtual node
            uint256 position = uint256(keccak256(abi.encodePacked(node, i)));
            ring[position] = node;
            
            // Insert position into sorted array
            _insertSorted(position);
        }
    }
    
    // Helper to insert a position into the sorted array
    function _insertSorted(uint256 position) private {
        // Simple insertion sort
        sortedPositions.push(position);
        uint256 j = sortedPositions.length - 1;
        
        while (j > 0 && sortedPositions[j - 1] > position) {
            sortedPositions[j] = sortedPositions[j - 1];
            j--;
        }
        
        sortedPositions[j] = position;
    }
    
    // Find the node responsible for a key
    function getNode(bytes calldata key) public view returns (address) {
        require(sortedPositions.length > 0, "No nodes available");
        
        uint256 keyHash = uint256(keccak256(key));
        
        // Binary search to find the first position >= keyHash
        uint256 left = 0;
        uint256 right = sortedPositions.length - 1;
        
        while (left < right) {
            uint256 mid = (left + right) / 2;
            if (sortedPositions[mid] < keyHash) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }
        
        // If we went past the end, wrap around to the first node
        uint256 position;
        if (left == sortedPositions.length - 1 && sortedPositions[left] < keyHash) {
            position = sortedPositions[0];
        } else {
            position = sortedPositions[left];
        }
        
        return ring[position];
    }
}
