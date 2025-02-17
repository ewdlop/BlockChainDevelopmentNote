// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title EnhancedCatCoin
 * @dev Enhanced CAT COIN with additional feline features
 */
contract EnhancedCatCoin is ERC20, ERC721, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // Extended Cat Breeds
    enum CatBreed {
        PERSIAN,     // Luxury variant
        SIAMESE,     // Speed demon
        MAINE_COON,  // Heavy lifter
        SPHYNX,      // Minimalist
        RAGDOLL,     // Adaptable
        BENGAL,      // Aggressive
        MUNCHKIN,    // Micro specialist
        SCOTTISH_FOLD, // Governance expert
        RUSSIAN_BLUE,  // Privacy master
        BRITISH_SHORTHAIR, // Stability focused
        ABYSSINIAN,    // Explorer/Scout
        BIRMAN        // Wisdom keeper
    }

    // Catnip Staking Tiers
    enum CatnipTier {
        KITTEN,      // Basic tier
        ADULT,       // Medium tier
        ELDER,       // High tier
        LEGENDARY    // Maximum tier
    }

    struct CatAttributes {
        CatBreed breed;
        uint256 level;
        uint256 lives;        // Max 9 lives
        uint256 catnipStaked;
        CatnipTier tier;
        uint256 lastFed;      // Timestamp for catnip feeding
        uint256 miningPower;
        bool isAsleep;        // Cats need rest!
    }

    // NFT and Governance structures
    struct CatProposal {
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        mapping(address => bool) hasVoted;
        uint256 deadline;
    }

    // State variables
    mapping(uint256 => CatAttributes) public catAttributes;
    mapping(address => uint256[]) public userCats;
    mapping(address => uint256) public catnipBalance;
    mapping(uint256 => CatProposal) public proposals;
    
    uint256 public totalCatnipStaked;
    uint256 public proposalCount;
    uint256 private nftCounter;
    
    // Constants
    uint256 public constant MAX_LIVES = 9;
    uint256 public constant CATNIP_STAKE_MINIMUM = 100 * 10**18;
    uint256 public constant CAT_NAP_DURATION = 4 hours;
    uint256 public constant PROPOSAL_DURATION = 3 days;

    // Events
    event CatBorn(uint256 indexed tokenId, CatBreed breed, address owner);
    event CatnipStaked(address indexed staker, uint256 amount, CatnipTier tier);
    event CatNapStarted(uint256 indexed tokenId, uint256 napStart);
    event CatNapEnded(uint256 indexed tokenId, uint256 napEnd);
    event LifeLost(uint256 indexed tokenId, uint256 remainingLives);
    event LifeRegained(uint256 indexed tokenId, uint256 newLives);
    event ProposalCreated(uint256 indexed proposalId, string description);
    event ProposalVoted(uint256 indexed proposalId, address voter, bool support);

    constructor() ERC20("Enhanced CAT COIN", "ECAT") ERC721("CatNFT", "CNFT") {
        // Initialize with first cat
        _mintCat(msg.sender, CatBreed.PERSIAN);
    }

    /**
     * @dev Mint a new Cat NFT
     */
    function _mintCat(address to, CatBreed breed) internal returns (uint256) {
        nftCounter++;
        _mint(to, nftCounter);
        
        CatAttributes memory newCat = CatAttributes({
            breed: breed,
            level: 1,
            lives: MAX_LIVES,
            catnipStaked: 0,
            tier: CatnipTier.KITTEN,
            lastFed: block.timestamp,
            miningPower: uint256(breed) * 10 + 100,
            isAsleep: false
        });
        
        catAttributes[nftCounter] = newCat;
        userCats[to].push(nftCounter);
        
        emit CatBorn(nftCounter, breed, to);
        return nftCounter;
    }

    /**
     * @dev Stake Catnip to boost mining power
     */
    function stakeCatnip(uint256 tokenId, uint256 amount) external nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "Not the cat owner");
        require(amount >= CATNIP_STAKE_MINIMUM, "Below minimum stake");
        
        _transfer(msg.sender, address(this), amount);
        
        CatAttributes storage cat = catAttributes[tokenId];
        cat.catnipStaked = cat.catnipStaked.add(amount);
        totalCatnipStaked = totalCatnipStaked.add(amount);
        
        // Update tier based on total stake
        if (cat.catnipStaked >= 10000 * 10**18) {
            cat.tier = CatnipTier.LEGENDARY;
        } else if (cat.catnipStaked >= 5000 * 10**18) {
            cat.tier = CatnipTier.ELDER;
        } else if (cat.catnipStaked >= 1000 * 10**18) {
            cat.tier = CatnipTier.ADULT;
        }
        
        // Boost mining power based on tier
        cat.miningPower = cat.miningPower.mul(uint256(cat.tier) + 1);
        
        emit CatnipStaked(msg.sender, amount, cat.tier);
    }

    /**
     * @dev Start cat nap to regenerate mining power
     */
    function startCatNap(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the cat owner");
        
        CatAttributes storage cat = catAttributes[tokenId];
        require(!cat.isAsleep, "Cat already napping");
        
        cat.isAsleep = true;
        emit CatNapStarted(tokenId, block.timestamp);
    }

    /**
     * @dev End cat nap and collect benefits
     */
    function endCatNap(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the cat owner");
        
        CatAttributes storage cat = catAttributes[tokenId];
        require(cat.isAsleep, "Cat not napping");
        require(block.timestamp >= cat.lastFed + CAT_NAP_DURATION, "Cat needs more sleep");
        
        cat.isAsleep = false;
        cat.miningPower = cat.miningPower.mul(12).div(10); // 20% boost
        
        if (cat.lives < MAX_LIVES) {
            cat.lives = cat.lives.add(1);
            emit LifeRegained(tokenId, cat.lives);
        }
        
        emit CatNapEnded(tokenId, block.timestamp);
    }

    /**
     * @dev Create a governance proposal
     */
    function createProposal(string calldata description) external returns (uint256) {
        require(balanceOf(msg.sender) >= 1000 * 10**18, "Insufficient tokens to propose");
        
        proposalCount++;
        CatProposal storage proposal = proposals[proposalCount];
        proposal.description = description;
        proposal.deadline = block.timestamp + PROPOSAL_DURATION;
        
        emit ProposalCreated(proposalCount, description);
        return proposalCount;
    }

    /**
     * @dev Vote on a proposal
     */
    function vote(uint256 proposalId, bool support) external {
        CatProposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");
        
        uint256 votingPower = balanceOf(msg.sender);
        require(votingPower > 0, "No voting power");
        
        proposal.hasVoted[msg.sender] = true;
        
        if (support) {
            proposal.forVotes = proposal.forVotes.add(votingPower);
        } else {
            proposal.againstVotes = proposal.againstVotes.add(votingPower);
        }
        
        emit ProposalVoted(proposalId, msg.sender, support);
    }

    /**
     * @dev Mine with a cat
     */
    function mineCatCoin(uint256 tokenId, uint256 nonce) external nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "Not the cat owner");
        
        CatAttributes storage cat = catAttributes[tokenId];
        require(!cat.isAsleep, "Cat is napping");
        require(cat.lives > 0, "Cat has no lives left");
        
        // Verify mining attempt
        bytes32 hash = keccak256(abi.encodePacked(
            msg.sender,
            tokenId,
            block.number,
            nonce
        ));
        
        uint256 difficulty = 2**256 - 1;
        difficulty = difficulty.div(cat.miningPower);
        
        if (uint256(hash) > difficulty) {
            cat.lives = cat.lives.sub(1);
            emit LifeLost(tokenId, cat.lives);
            return;
        }
        
        // Calculate reward based on cat attributes
        uint256 reward = calculateMiningReward(cat);
        _mint(msg.sender, reward);
        
        // Cat gets tired after mining
        cat.miningPower = cat.miningPower.mul(9).div(10); // 10% decrease
    }

    /**
     * @dev Calculate mining reward based on cat attributes
     */
    function calculateMiningReward(CatAttributes memory cat) internal pure returns (uint256) {
        uint256 baseReward = 100 * 10**18; // 100 tokens base reward
        
        // Adjust based on breed
        uint256 breedBonus = uint256(cat.breed) * 5; // 5% bonus per breed level
        
        // Adjust based on tier
        uint256 tierBonus = uint256(cat.tier) * 25; // 25% bonus per tier
        
        // Calculate total bonus
        uint256 totalBonus = baseReward.mul(100 + breedBonus + tierBonus).div(100);
        
        return totalBonus;
    }

    /**
     * @dev Get all cats owned by an address
     */
    function getCatsByOwner(address owner) external view returns (uint256[] memory) {
        return userCats[owner];
    }

    /**
     * @dev Breed two cats to create a new one
     */
    function breedCats(uint256 cat1Id, uint256 cat2Id) external nonReentrant {
        require(ownerOf(cat1Id) == msg.sender && ownerOf(cat2Id) == msg.sender, "Must own both cats");
        
        CatAttributes storage cat1 = catAttributes[cat1Id];
        CatAttributes storage cat2 = catAttributes[cat2Id];
        
        // Determine new breed based on parents
        CatBreed newBreed = CatBreed(uint256(cat1.breed) + uint256(cat2.breed) % 12);
        
        // Create new cat with inherited traits
        uint256 newCatId = _mintCat(msg.sender, newBreed);
        CatAttributes storage newCat = catAttributes[newCatId];
        
        // Inherit some traits from parents
        newCat.miningPower = (cat1.miningPower + cat2.miningPower) / 2;
        newCat.level = (cat1.level + cat2.level) / 2;
    }
}
