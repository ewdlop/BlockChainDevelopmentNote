// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title BitcoinMinter
 * @dev Simulates Bitcoin mining mechanics on Ethereum with PoW simulation
 */
contract BitcoinMinter is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // Mining parameters
    uint256 public blockReward;
    uint256 public difficulty;
    uint256 public epochBlock;
    uint256 public constant BLOCKS_PER_EPOCH = 2016;
    uint256 public constant TARGET_TIME_PER_BLOCK = 10 minutes;
    uint256 public lastRewardBlock;
    uint256 public totalHashPower;

    // Halving parameters
    uint256 public constant HALVING_INTERVAL = 210000;
    uint256 public halvingCount;

    // Mining pool tracking
    struct Miner {
        uint256 hashPower;
        uint256 lastMinedBlock;
        uint256 totalMined;
    }
    
    mapping(address => Miner) public miners;
    address[] public activeMinersList;

    // Events
    event BlockMined(address indexed miner, uint256 reward, uint256 blockNumber);
    event DifficultyAdjusted(uint256 newDifficulty);
    event HashPowerUpdated(address indexed miner, uint256 hashPower);
    event RewardHalved(uint256 newReward, uint256 halvingCount);

    constructor() ERC20("Bitcoin Simulation", "BTCSim") {
        blockReward = 50 * 10**decimals(); // Initial reward: 50 BTC
        difficulty = 1;
        epochBlock = block.number;
        lastRewardBlock = block.number;
        halvingCount = 0;
    }

    /**
     * @dev Allows miners to register or update their hash power
     * @param hashPower Amount of mining power to commit
     */
    function registerHashPower(uint256 hashPower) external {
        require(hashPower > 0, "Hash power must be positive");
        
        if (miners[msg.sender].hashPower == 0) {
            activeMinersList.push(msg.sender);
        }
        
        totalHashPower = totalHashPower.sub(miners[msg.sender].hashPower).add(hashPower);
        miners[msg.sender].hashPower = hashPower;
        
        emit HashPowerUpdated(msg.sender, hashPower);
    }

    /**
     * @dev Simulates the mining process
     * @param nonce Random value for mining simulation
     */
    function mine(uint256 nonce) external nonReentrant {
        require(miners[msg.sender].hashPower > 0, "Must register hash power first");
        require(block.number > lastRewardBlock, "Block already mined");

        // Simulate PoW using miner's hash power and difficulty
        uint256 miningProbability = calculateMiningProbability(msg.sender);
        require(simulatePoW(nonce, miningProbability), "Mining attempt failed");

        // Update miner stats
        miners[msg.sender].lastMinedBlock = block.number;
        miners[msg.sender].totalMined = miners[msg.sender].totalMined.add(1);
        lastRewardBlock = block.number;

        // Process block rewards
        processBlockReward();

        // Check for difficulty adjustment
        if ((block.number - epochBlock) >= BLOCKS_PER_EPOCH) {
            adjustDifficulty();
        }

        emit BlockMined(msg.sender, blockReward, block.number);
    }

    /**
     * @dev Calculates mining probability based on hash power and difficulty
     */
    function calculateMiningProbability(address miner) public view returns (uint256) {
        return miners[miner].hashPower.mul(1e18).div(totalHashPower.mul(difficulty));
    }

    /**
     * @dev Simulates Proof of Work verification
     */
    function simulatePoW(uint256 nonce, uint256 probability) internal view returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(
            msg.sender,
            block.number,
            block.timestamp,
            nonce
        ));
        
        uint256 hashValue = uint256(hash);
        return hashValue <= probability;
    }

    /**
     * @dev Processes block reward and handles halvings
     */
    function processBlockReward() internal {
        uint256 currentBlock = block.number.sub(lastRewardBlock);
        uint256 halvings = currentBlock.div(HALVING_INTERVAL);
        
        if (halvings > halvingCount) {
            halvingCount = halvings;
            blockReward = blockReward.div(2);
            emit RewardHalved(blockReward, halvingCount);
        }

        _mint(msg.sender, blockReward);
    }

    /**
     * @dev Adjusts mining difficulty based on block time
     */
    function adjustDifficulty() internal {
        uint256 timeElapsed = block.timestamp.sub(epochBlock);
        uint256 targetTime = BLOCKS_PER_EPOCH.mul(TARGET_TIME_PER_BLOCK);
        
        if (timeElapsed < targetTime.mul(4).div(5)) {
            // Too fast - increase difficulty
            difficulty = difficulty.mul(11).div(10);
        } else if (timeElapsed > targetTime.mul(6).div(5)) {
            // Too slow - decrease difficulty
            difficulty = difficulty.mul(9).div(10);
        }
        
        epochBlock = block.number;
        emit DifficultyAdjusted(difficulty);
    }

    /**
     * @dev View function to get miner statistics
     */
    function getMinerStats(address miner) external view returns (
        uint256 hashPower,
        uint256 lastMinedBlock,
        uint256 totalMined,
        uint256 miningProbability
    ) {
        Miner memory minerData = miners[miner];
        return (
            minerData.hashPower,
            minerData.lastMinedBlock,
            minerData.totalMined,
            calculateMiningProbability(miner)
        );
    }

    /**
     * @dev View function to get current network statistics
     */
    function getNetworkStats() external view returns (
        uint256 currentDifficulty,
        uint256 currentBlockReward,
        uint256 totalNetworkHashPower,
        uint256 activeMinerCount
    ) {
        return (
            difficulty,
            blockReward,
            totalHashPower,
            activeMinersList.length
        );
    }

    /**
     * @dev Emergency function to adjust difficulty (owner only)
     */
    function emergencyDifficultyAdjustment(uint256 newDifficulty) external onlyOwner {
        require(newDifficulty > 0, "Invalid difficulty");
        difficulty = newDifficulty;
        emit DifficultyAdjusted(difficulty);
    }
}
