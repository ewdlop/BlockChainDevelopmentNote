// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeartbeatSystem {
    struct NodeStatus {
        uint256 lastHeartbeat;
        bool isActive;
    }
    
    // Mapping of node address to their status
    mapping(address => NodeStatus) public nodeStatus;
    
    // List of all registered nodes
    address[] public nodes;
    
    // Heartbeat timeout (in seconds)
    uint256 public heartbeatTimeout = 5 minutes;
    
    // Events
    event HeartbeatReceived(address indexed node, uint256 timestamp);
    event NodeRegistered(address indexed node, uint256 timestamp);
    event NodeBecameInactive(address indexed node, uint256 timestamp);
    
    // Register as a node
    function register() public {
        if (nodeStatus[msg.sender].lastHeartbeat == 0) {
            nodes.push(msg.sender);
            emit NodeRegistered(msg.sender, block.timestamp);
        }
        
        // Register and send first heartbeat
        _recordHeartbeat(msg.sender);
    }
    
    // Send a heartbeat
    function heartbeat() public {
        require(nodeStatus[msg.sender].lastHeartbeat > 0, "Node not registered");
        _recordHeartbeat(msg.sender);
    }
    
    // Internal function to record a heartbeat
    function _recordHeartbeat(address node) private {
        nodeStatus[node] = NodeStatus({
            lastHeartbeat: block.timestamp,
            isActive: true
        });
        
        emit HeartbeatReceived(node, block.timestamp);
    }
    
    // Check if nodes are still active
    function checkNodes() public {
        for (uint256 i = 0; i < nodes.length; i++) {
            address node = nodes[i];
            NodeStatus storage status = nodeStatus[node];
            
            // If the node was active but hasn't sent a heartbeat recently
            if (status.isActive && block.timestamp - status.lastHeartbeat > heartbeatTimeout) {
                status.isActive = false;
                emit NodeBecameInactive(node, block.timestamp);
            }
        }
    }
    
    // Get active node count
    function getActiveNodeCount() public view returns (uint256 count) {
        for (uint256 i = 0; i < nodes.length; i++) {
            if (nodeStatus[nodes[i]].isActive) {
                count++;
            }
        }
    }
    
    // Set the heartbeat timeout
    function setHeartbeatTimeout(uint256 newTimeout) public {
        heartbeatTimeout = newTimeout;
    }
}
