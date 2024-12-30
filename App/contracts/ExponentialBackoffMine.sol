// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExponentialBackoffMine {
    address public owner;
    uint256 public rewardPerMine; // Reward per successful mine
    uint256 public maxSupply;    // Maximum tokens to mine
    uint256 public totalMined;   // Total tokens mined

    mapping(address => uint256) public lastMineTime;
    mapping(address => uint256) public backoffFactor;

    event Mined(address indexed miner, uint256 reward, uint256 nextAllowedTime);

    constructor(uint256 _rewardPerMine, uint256 _maxSupply) {
        owner = msg.sender;
        rewardPerMine = _rewardPerMine;
        maxSupply = _maxSupply;
    }

    function mine() public {
        require(totalMined + rewardPerMine <= maxSupply, "Max supply reached");
        
        // Get the current time
        uint256 currentTime = block.timestamp;
        
        // Check the miner's last mine time and apply backoff
        uint256 nextAllowedTime = lastMineTime[msg.sender] + (2 ** backoffFactor[msg.sender]);
        require(currentTime >= nextAllowedTime, "Exponential backoff: Too soon to mine again");

        // Update the mining state
        lastMineTime[msg.sender] = currentTime;
        backoffFactor[msg.sender] += 1; // Increase backoff exponentially
        totalMined += rewardPerMine;

        emit Mined(msg.sender, rewardPerMine, nextAllowedTime);
    }

    function resetBackoff(address miner) public {
        require(msg.sender == owner, "Only owner can reset backoff");
        backoffFactor[miner] = 0;
    }

    function checkNextAllowedTime(address miner) public view returns (uint256) {
        return lastMineTime[miner] + (2 ** backoffFactor[miner]);
    }
}
