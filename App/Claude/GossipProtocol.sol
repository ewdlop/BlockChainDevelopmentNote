// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Note: A full gossip protocol requires node-to-node communication
// which isn't directly possible in Solidity. This is a simplified
// centralized simulation.

contract GossipProtocol {
    struct NodeState {
        uint256 heartbeat;
        uint256 timestamp;
        bool isAlive;
    }
    
    // Node registry
    mapping(address => NodeState) public nodeStates;
    address[] public nodes;
    
    // Event for state updates
    event StateUpdated(address node, uint256 heartbeat, uint256 timestamp);
    
    // Register as a node
    function register() public {
        if (!isRegistered(msg.sender)) {
            nodes.push(msg.sender);
        }
        
        nodeStates[msg.sender] = NodeState({
            heartbeat: 0,
            timestamp: block.timestamp,
            isAlive: true
        });
    }
    
    // Update own state (increment heartbeat)
    function updateState() public {
        require(isRegistered(msg.sender), "Node not registered");
        
        NodeState storage state = nodeStates[msg.sender];
        state.heartbeat += 1;
        state.timestamp = block.timestamp;
        
        emit StateUpdated(msg.sender, state.heartbeat, state.timestamp);
    }
    
    // Gossip about another node's state
    function gossip(address aboutNode, uint256 heartbeat, uint256 timestamp) public {
        require(isRegistered(msg.sender), "Gossiper not registered");
        require(isRegistered(aboutNode), "Subject node not registered");
        
        NodeState storage knownState = nodeStates[aboutNode];
        
        // Only update if the gossip has newer information
        if (heartbeat > knownState.heartbeat) {
            knownState.heartbeat = heartbeat;
            knownState.timestamp = timestamp;
            
            emit StateUpdated(aboutNode, heartbeat, timestamp);
        }
    }
    
    // Check if a node is registered
    function isRegistered(address node) public view returns (bool) {
        return nodeStates[node].timestamp > 0;
    }
    
    // Get the state of all known nodes
    function getAllNodeStates() public view returns (address[] memory, uint256[] memory, bool[] memory) {
        uint256[] memory heartbeats = new uint256[](nodes.length);
        bool[] memory alive = new bool[](nodes.length);
        
        for (uint256 i = 0; i < nodes.length; i++) {
            NodeState memory state = nodeStates[nodes[i]];
            heartbeats[i] = state.heartbeat;
            
            // Mark as not alive if no updates in the last 5 minutes
            alive[i] = (block.timestamp - state.timestamp) < 5 minutes;
        }
        
        return (nodes, heartbeats, alive);
    }
}
