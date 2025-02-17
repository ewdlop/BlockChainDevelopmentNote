// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title CatCoinGenerator
 * @dev Creates different types of CAT COIN variants with feline-themed properties
 */
contract CatCoinGenerator is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // Cat breed types for variant characteristics
    enum CatBreed {
        PERSIAN,     // Luxury variant with high value
        SIAMESE,     // Fast transactions
        MAINE_COON,  // Large block size
        SPHYNX,      // Minimal/lightweight
        RAGDOLL,     // Flexible/adaptable
        BENGAL,      // High performance/aggressive mining
        MUNCHKIN     // Small but mighty (micro transactions)
    }

    struct CatCoinVariant {
        address tokenAddress;
        string name;
        string symbol;
        uint256 maxSupply;
        uint256 blockReward;
        uint256 halvingInterval;
        uint256 difficulty;
        bool isPrivate;
        bool hasStaking;
        CatBreed breed;
        string catPowerFeature;  // Special feature based on cat breed
    }

    CatCoinVariant[] public catCoins;
    mapping(address => CatCoinVariant[]) public creatorCoins;
    mapping(CatBreed => uint256) public breedMiningBonus;

    event CatCoinCreated(
        address indexed tokenAddress,
        string name,
        CatBreed breed,
        address indexed creator
    );

    event CatPowerActivated(
        address indexed tokenAddress,
        string catPowerFeature,
        uint256 timestamp
    );

    constructor() {
        // Initialize breed mining bonuses
        breedMiningBonus[CatBreed.PERSIAN] = 20;    // 20% bonus
        breedMiningBonus[CatBreed.SIAMESE] = 15;    // 15% bonus
        breedMiningBonus[CatBreed.MAINE_COON] = 25; // 25% bonus
        breedMiningBonus[CatBreed.SPHYNX] = 10;     // 10% bonus
        breedMiningBonus[CatBreed.RAGDOLL] = 18;    // 18% bonus
        breedMiningBonus[CatBreed.BENGAL] = 30;     // 30% bonus
        breedMiningBonus[CatBreed.MUNCHKIN] = 12;   // 12% bonus
    }

    contract CatCoinToken is ERC20, Ownable, ReentrancyGuard {
        using SafeMath for uint256;

        uint256 public maxSupply;
        uint256 public currentSupply;
        uint256 public blockReward;
        uint256 public halvingInterval;
        uint256 public difficulty;
        uint256 public lastHalvingBlock;
        bool public isPrivate;
        bool public hasStaking;
        CatBreed public breed;
        
        // Staking variables
        mapping(address => uint256) public stakedAmount;
        mapping(address => uint256) public stakingStart;
        uint256 public totalStaked;
        uint256 public stakingRewardRate = 5; // 5% annual return

        // Cat Power special features
        uint256 public catPowerCooldown;
        mapping(address => uint256) public lastCatPowerUse;

        constructor(
            string memory _name,
            string memory _symbol,
            uint256 _maxSupply,
            uint256 _blockReward,
            uint256 _halvingInterval,
            uint256 _difficulty,
            bool _isPrivate,
            bool _hasStaking,
            CatBreed _breed
        ) ERC20(_name, _symbol) {
            maxSupply = _maxSupply;
            blockReward = _blockReward;
            halvingInterval = _halvingInterval;
            difficulty = _difficulty;
            isPrivate = _isPrivate;
            hasStaking = _hasStaking;
            breed = _breed;
            lastHalvingBlock = block.number;
            
            // Set Cat Power cooldown based on breed
            if (breed == CatBreed.SIAMESE) {
                catPowerCooldown = 1 hours;
            } else if (breed == CatBreed.BENGAL) {
                catPowerCooldown = 4 hours;
            } else {
                catPowerCooldown = 12 hours;
            }
        }

        // Staking functions
        function stake(uint256 amount) external nonReentrant {
            require(hasStaking, "Staking not enabled");
            require(amount > 0, "Cannot stake 0");
            require(balanceOf(msg.sender) >= amount, "Insufficient balance");

            if (stakedAmount[msg.sender] > 0) {
                claimStakingRewards();
            }

            _transfer(msg.sender, address(this), amount);
            stakedAmount[msg.sender] = stakedAmount[msg.sender].add(amount);
            stakingStart[msg.sender] = block.timestamp;
            totalStaked = totalStaked.add(amount);
        }

        function unstake() external nonReentrant {
            require(stakedAmount[msg.sender] > 0, "No stakes found");
            
            claimStakingRewards();
            uint256 amount = stakedAmount[msg.sender];
            stakedAmount[msg.sender] = 0;
            totalStaked = totalStaked.sub(amount);
            _transfer(address(this), msg.sender, amount);
        }

        function claimStakingRewards() public {
            require(stakedAmount[msg.sender] > 0, "No stakes found");
            
            uint256 reward = calculateStakingReward(msg.sender);
            if (reward > 0) {
                _mint(msg.sender, reward);
                stakingStart[msg.sender] = block.timestamp;
            }
        }

        function calculateStakingReward(address staker) public view returns (uint256) {
            uint256 stakingDuration = block.timestamp.sub(stakingStart[staker]);
            return stakedAmount[staker]
                .mul(stakingRewardRate)
                .mul(stakingDuration)
                .div(365 days)
                .div(100);
        }

        // Cat Power special abilities based on breed
        function activateCatPower() external nonReentrant {
            require(block.timestamp >= lastCatPowerUse[msg.sender].add(catPowerCooldown), 
                    "Cat Power in cooldown");
            
            if (breed == CatBreed.PERSIAN) {
                // Luxury bonus: Temporary increase in mining rewards
                blockReward = blockReward.mul(2);
                // Reset after 1 hour
                blockReward = blockReward.div(2);
            } 
            else if (breed == CatBreed.BENGAL) {
                // Aggressive mining: Temporary difficulty reduction
                difficulty = difficulty.mul(7).div(10);
                // Reset after 30 minutes
                difficulty = difficulty.mul(10).div(7);
            }
            else if (breed == CatBreed.MAINE_COON) {
                // Large block bonus: Double transactions per block temporarily
                // Implementation would depend on specific requirements
            }

            lastCatPowerUse[msg.sender] = block.timestamp;
        }

        // Mining with breed bonus
        function mine(uint256 nonce) external nonReentrant {
            require(currentSupply < maxSupply, "Max supply reached");
            require(verifyPoW(nonce), "Invalid proof of work");
            
            uint256 reward = calculateReward();
            
            // Apply breed bonus
            reward = reward.mul(100 + breedMiningBonus[breed]).div(100);
            
            require(currentSupply.add(reward) <= maxSupply, "Would exceed max supply");
            _mint(msg.sender, reward);
            currentSupply = currentSupply.add(reward);
            
            adjustDifficulty();
        }

        // Additional helper functions remain the same as in the previous implementation
        // ... (verifyPoW, calculateReward, adjustDifficulty)
    }

    function createCatCoin(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 blockReward,
        uint256 halvingInterval,
        uint256 initialDifficulty,
        bool isPrivate,
        bool hasStaking,
        CatBreed breed
    ) external nonReentrant returns (address) {
        string memory catPowerFeature = getCatPowerFeature(breed);
        
        CatCoinToken newToken = new CatCoinToken(
            name,
            symbol,
            maxSupply,
            blockReward,
            halvingInterval,
            initialDifficulty,
            isPrivate,
            hasStaking,
            breed
        );

        CatCoinVariant memory variant = CatCoinVariant({
            tokenAddress: address(newToken),
            name: name,
            symbol: symbol,
            maxSupply: maxSupply,
            blockReward: blockReward,
            halvingInterval: halvingInterval,
            difficulty: initialDifficulty,
            isPrivate: isPrivate,
            hasStaking: hasStaking,
            breed: breed,
            catPowerFeature: catPowerFeature
        });

        catCoins.push(variant);
        creatorCoins[msg.sender].push(variant);

        emit CatCoinCreated(address(newToken), name, breed, msg.sender);
        return address(newToken);
    }

    // Predefined CAT COIN variants
    function createPersianCatCoin() external returns (address) {
        return createCatCoin(
            "Persian CAT COIN",
            "PCAT",
            21000000 * 10**18,
            100 * 10**18,
            210000,
            1,
            true,
            true,
            CatBreed.PERSIAN
        );
    }

    function createBengalCatCoin() external returns (address) {
        return createCatCoin(
            "Bengal CAT COIN",
            "BCAT",
            50000000 * 10**18,
            200 * 10**18,
            100000,
            1,
            false,
            true,
            CatBreed.BENGAL
        );
    }

    function createSiameseCatCoin() external returns (address) {
        return createCatCoin(
            "Siamese CAT COIN",
            "SCAT",
            30000000 * 10**18,
            150 * 10**18,
            150000,
            1,
            false,
            true,
            CatBreed.SIAMESE
        );
    }

    function getCatPowerFeature(CatBreed breed) internal pure returns (string memory) {
        if (breed == CatBreed.PERSIAN) return "Luxury Mining Bonus";
        if (breed == CatBreed.SIAMESE) return "Speed Boost";
        if (breed == CatBreed.MAINE_COON) return "Block Size Increase";
        if (breed == CatBreed.SPHYNX) return "Lightweight Transactions";
        if (breed == CatBreed.RAGDOLL) return "Adaptive Difficulty";
        if (breed == CatBreed.BENGAL) return "Aggressive Mining";
        if (breed == CatBreed.MUNCHKIN) return "Micro Transaction Boost";
        return "Standard Cat Power";
    }

    // View functions
    function getTotalCatCoins() external view returns (uint256) {
        return catCoins.length;
    }

    function getCreatorCatCoins(address creator) external view returns (CatCoinVariant[] memory) {
        return creatorCoins[creator];
    }
}
