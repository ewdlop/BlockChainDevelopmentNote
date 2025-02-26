// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DistributedSystems
 * @dev Library containing implementations of common distributed systems concepts
 */
library DistributedSystems {
    //----------------------------------------
    // Merkle Tree Implementation
    //----------------------------------------
    struct MerkleProof {
        bytes32[] siblings;
        uint256 index;
    }

    /**
     * @dev Verifies a Merkle proof
     * @param root The Merkle root
     * @param leaf The leaf node
     * @param proof The proof containing sibling hashes and index
     * @return True if the proof is valid
     */
    function verifyMerkleProof(
        bytes32 root,
        bytes32 leaf,
        MerkleProof memory proof
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        uint256 index = proof.index;

        for (uint256 i = 0; i < proof.siblings.length; i++) {
            bytes32 sibling = proof.siblings[i];

            if (index % 2 == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, sibling));
            } else {
                computedHash = keccak256(abi.encodePacked(sibling, computedHash));
            }

            index = index / 2;
        }

        return computedHash == root;
    }

    /**
     * @dev Compute a leaf hash for a Merkle tree
     * @param data The leaf data
     * @return The computed hash
     */
    function hashLeaf(bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    /**
     * @dev Compute a node hash for a Merkle tree
     * @param left The left child hash
     * @param right The right child hash
     * @return The computed hash
     */
    function hashNode(bytes32 left, bytes32 right) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(left, right));
    }

    //----------------------------------------
    // Bloom Filter Implementation
    //----------------------------------------
    struct BloomFilter {
        uint256 bits;
        uint8 hashFunctions;
    }

    /**
     * @dev Initialize a new Bloom filter
     * @param hashFunctions Number of hash functions to use
     * @return A new Bloom filter
     */
    function createBloomFilter(uint8 hashFunctions) internal pure returns (BloomFilter memory) {
        return BloomFilter({
            bits: 0,
            hashFunctions: hashFunctions
        });
    }

    /**
     * @dev Add an item to the Bloom filter
     * @param filter The Bloom filter
     * @param item The item to add
     */
    function addToBloomFilter(BloomFilter memory filter, bytes memory item) internal pure returns (BloomFilter memory) {
        filter.bits = filter.bits | computeBloomMask(filter.hashFunctions, item);
        return filter;
    }

    /**
     * @dev Check if an item might be in the set
     * @param filter The Bloom filter
     * @param item The item to check
     * @return True if the item might be in the set
     */
    function mightContain(BloomFilter memory filter, bytes memory item) internal pure returns (bool) {
        uint256 mask = computeBloomMask(filter.hashFunctions, item);
        return (filter.bits & mask) == mask;
    }

    /**
     * @dev Compute a bit mask for the Bloom filter
     * @param hashFunctions Number of hash functions
     * @param item The item to hash
     * @return The computed bit mask
     */
    function computeBloomMask(uint8 hashFunctions, bytes memory item) internal pure returns (uint256) {
        uint256 mask = 0;
        bytes32 hash = keccak256(item);
        
        for (uint8 i = 0; i < hashFunctions; i++) {
            // Use different bytes from the hash for each position
            uint8 bytePos = i * 4;
            uint256 bitPosition = uint8(hash[bytePos]) % 256;
            
            mask = mask | (1 << bitPosition);
        }
        
        return mask;
    }

    //----------------------------------------
    // Consistent Hashing Implementation
    //----------------------------------------
    struct HashRing {
        mapping(uint256 => address) nodes;
        uint256[] positions;
    }

    /**
     * @dev Add a node to the hash ring
     * @param positions Array of positions
     * @param nodePosition Position to add
     */
    function addPositionSorted(uint256[] storage positions, uint256 nodePosition) internal {
        positions.push(nodePosition);
        uint256 j = positions.length - 1;
        
        while (j > 0 && positions[j - 1] > nodePosition) {
            positions[j] = positions[j - 1];
            j--;
        }
        
        positions[j] = nodePosition;
    }

    /**
     * @dev Find the position on the ring for a key
     * @param positions Sorted positions array
     * @param key The key to map
     * @return The position index in the ring
     */
    function findPosition(uint256[] storage positions, bytes memory key) internal view returns (uint256) {
        require(positions.length > 0, "Hash ring is empty");
        
        uint256 keyHash = uint256(keccak256(key));
        
        // Binary search to find the first position >= keyHash
        uint256 left = 0;
        uint256 right = positions.length - 1;
        
        while (left < right) {
            uint256 mid = (left + right) / 2;
            if (positions[mid] < keyHash) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }
        
        // If we went past the end, wrap around to the first position
        if (left == positions.length - 1 && positions[left] < keyHash) {
            return 0;
        } else {
            return left;
        }
    }

    //----------------------------------------
    // Versioned Data for Read Repair
    //----------------------------------------
    struct VersionedData {
        bytes data;
        uint256 version;
        uint256 timestamp;
    }

    /**
     * @dev Find the most recent version of the data
     * @param versions Array of versioned data
     * @return Index of the most recent version
     */
    function findMostRecent(VersionedData[] memory versions) internal pure returns (uint256) {
        uint256 mostRecentIdx = 0;
        
        for (uint256 i = 1; i < versions.length; i++) {
            if (versions[i].version > versions[mostRecentIdx].version) {
                mostRecentIdx = i;
            }
        }
        
        return mostRecentIdx;
    }

    //----------------------------------------
    // Utilities for CAP/PACELC concepts
    //----------------------------------------
    enum ConsistencyStrategy {
        STRONG_CONSISTENCY,
        EVENTUAL_CONSISTENCY
    }
    
    enum LatencyStrategy {
        LOW_LATENCY,
        HIGH_CONSISTENCY
    }
    
    /**
     * @dev Determine if a read/write should succeed based on partition status and strategy
     * @param isPartitioned Whether the system is partitioned
     * @param strategy The consistency strategy
     * @return Whether the operation should succeed
     */
    function shouldOperationSucceed(
        bool isPartitioned,
        ConsistencyStrategy strategy
    ) internal pure returns (bool) {
        // If partitioned and requiring strong consistency, operation must fail
        return !(isPartitioned && strategy == ConsistencyStrategy.STRONG_CONSISTENCY);
    }
    
    /**
     * @dev Determine if a operation should check multiple replicas
     * @param isPartitioned Whether the system is partitioned
     * @param consistencyStrategy The partition consistency strategy
     * @param latencyStrategy The normal operation latency strategy
     * @return Whether to check multiple replicas
     */
    function shouldCheckMultipleReplicas(
        bool isPartitioned,
        ConsistencyStrategy consistencyStrategy,
        LatencyStrategy latencyStrategy
    ) internal pure returns (bool) {
        if (isPartitioned) {
            // When partitioned, we can only use one replica if allowing eventual consistency
            return false;
        } else {
            // When not partitioned, it depends on the latency vs consistency preference
            return latencyStrategy == LatencyStrategy.HIGH_CONSISTENCY;
        }
    }

    //----------------------------------------
    // Heartbeat and Failure Detection
    //----------------------------------------
    struct NodeState {
        uint256 lastHeartbeat;
        uint256 heartbeatCounter;
        bool isActive;
    }
    
    /**
     * @dev Check if a node should be considered failed
     * @param state The node state
     * @param timeout The timeout duration
     * @param currentTime The current time
     * @return Whether the node is considered failed
     */
    function isNodeFailed(
        NodeState memory state,
        uint256 timeout,
        uint256 currentTime
    ) internal pure returns (bool) {
        return currentTime - state.lastHeartbeat > timeout;
    }
}
