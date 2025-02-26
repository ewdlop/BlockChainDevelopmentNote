// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract demonstrates CAP/PACELC concepts in a simplified form
contract DistributedDataStore {
    enum ConsistencyMode {
        // CAP: Choose C over A when partitioned
        STRONG_CONSISTENCY,
        
        // CAP: Choose A over C when partitioned
        EVENTUAL_CONSISTENCY
    }
    
    enum LatencyMode {
        // PACELC: Choose L over C when normal
        LOW_LATENCY,
        
        // PACELC: Choose C over L when normal
        HIGH_CONSISTENCY
    }
    
    struct DataItem {
        bytes value;
        uint256 version;
    }
    
    // Mode configurations
    ConsistencyMode public partitionMode;
    LatencyMode public normalMode;
    
    // Simulated partition flag (would be set by an oracle in a real system)
    bool public isPartitioned;
    
    // Data storage
    mapping(bytes32 => DataItem) private mainData;
    mapping(bytes32 => DataItem) private replicaData;
    
    // Events
    event DataWritten(bytes32 key, uint256 version);
    event PartitionStatusChanged(bool isPartitioned);
    
    constructor(ConsistencyMode _partitionMode, LatencyMode _normalMode) {
        partitionMode = _partitionMode;
        normalMode = _normalMode;
    }
    
    // Simulate a network partition
    function setPartitionStatus(bool _isPartitioned) public {
        isPartitioned = _isPartitioned;
        emit PartitionStatusChanged(_isPartitioned);
    }
    
    // Write data according to the configured modes
    function write(bytes32 key, bytes calldata value) public returns (bool) {
        uint256 newVersion = block.timestamp;
        
        if (isPartitioned) {
            if (partitionMode == ConsistencyMode.STRONG_CONSISTENCY) {
                // Cannot guarantee consistency, so refuse the write
                revert("Write rejected during partition with strong consistency mode");
            } else {
                // Accept write to available replica, will reconcile later
                mainData[key] = DataItem(value, newVersion);
                emit DataWritten(key, newVersion);
            }
        } else {
            // No partition, write to both copies
            mainData[key] = DataItem(value, newVersion);
            replicaData[key] = DataItem(value, newVersion);
            emit DataWritten(key, newVersion);
        }
        
        return true;
    }
    
    // Read data according to the configured modes
    function read(bytes32 key) public view returns (bytes memory, uint256) {
        if (isPartitioned) {
            if (partitionMode == ConsistencyMode.STRONG_CONSISTENCY) {
                // Cannot guarantee consistency, so refuse the read
                revert("Read rejected during partition with strong consistency mode");
            } else {
                // Return available data, might be stale
                return (mainData[key].value, mainData[key].version);
            }
        } else {
            if (normalMode == LatencyMode.LOW_LATENCY) {
                // Just read from one replica for lower latency
                return (mainData[key].value, mainData[key].version);
            } else {
                // In a real system, we would check both replicas and return the newest
                // Here we simulate this by comparing versions
                DataItem memory main = mainData[key];
                DataItem memory replica = replicaData[key];
                
                if (main.version >= replica.version) {
                    return (main.value, main.version);
                } else {
                    return (replica.value, replica.version);
                }
            }
        }
    }
    
    // Simulate reconciliation after partition heals
    function reconcile() public {
        // In a real system, this would involve complex sync logic
        // For this demo, we just pick the newer version for each key
        // (Not implemented here as we'd need a way to enumerate keys)
    }
}
