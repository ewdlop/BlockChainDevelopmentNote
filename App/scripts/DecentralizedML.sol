// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title ModelUpdate
 * @dev Structure for model weight updates
 */
struct ModelUpdate {
    address validator;
    bytes32 weightsHash;
    uint256 timestamp;
    bytes32 previousHash;
    uint256 validationScore;
    bool isValid;
}

/**
 * @title ConsensusBlock
 * @dev Structure for consensus blocks containing approved updates
 */
struct ConsensusBlock {
    bytes32[] updateHashes;
    uint256 timestamp;
    bytes32 blockHash;
    address[] validators;
    bool finalized;
}

/**
 * @title DecentralizedML
 * @dev Main contract for decentralized machine learning
 */
contract DecentralizedML is Ownable, ReentrancyGuard, Pausable {
    // State variables
    uint256 public constant MIN_VALIDATORS = 3;
    uint256 public constant MAX_VALIDATORS = 10;
    uint256 public constant VALIDATION_THRESHOLD = 7000; // 70%
    uint256 public constant UPDATE_EXPIRY = 1 hours;
    
    mapping(address => bool) public validators;
    mapping(bytes32 => ModelUpdate) public modelUpdates;
    mapping(bytes32 => ConsensusBlock) public consensusBlocks;
    mapping(address => uint256) public validatorStakes;
    
    bytes32[] public updateQueue;
    bytes32[] public consensusChain;
    
    uint256 public totalStaked;
    uint256 public epochNumber;
    
    // Events
    event ValidatorRegistered(address indexed validator, uint256 stake);
    event ModelUpdateSubmitted(bytes32 indexed updateHash, address indexed validator);
    event ConsensusBlockCreated(bytes32 indexed blockHash, uint256 indexed epoch);
    event ConsensusReached(bytes32 indexed blockHash, uint256 timestamp);
    event ValidationPerformed(bytes32 indexed updateHash, address indexed validator, uint256 score);
    
    // Modifiers
    modifier onlyValidator() {
        require(validators[msg.sender], "Not a registered validator");
        _;
    }
    
    modifier updateExists(bytes32 updateHash) {
        require(modelUpdates[updateHash].timestamp > 0, "Update does not exist");
        _;
    }
    
    modifier notExpired(bytes32 updateHash) {
        require(
            block.timestamp - modelUpdates[updateHash].timestamp <= UPDATE_EXPIRY,
            "Update expired"
        );
        _;
    }

    /**
     * @dev Constructor
     */
    constructor() {
        epochNumber = 0;
    }

    /**
     * @dev Register as a validator with stake
     */
    function registerValidator() external payable nonReentrant {
        require(!validators[msg.sender], "Already registered");
        require(msg.value >= 1 ether, "Minimum stake required");
        
        validators[msg.sender] = true;
        validatorStakes[msg.sender] = msg.value;
        totalStaked += msg.value;
        
        emit ValidatorRegistered(msg.sender, msg.value);
    }

    /**
     * @dev Submit model update
     * @param weightsHash Hash of model weights
     * @param previousHash Hash of previous update
     * @param validationScore Initial validation score
     */
    function submitModelUpdate(
        bytes32 weightsHash,
        bytes32 previousHash,
        uint256 validationScore
    ) 
        external 
        onlyValidator 
        whenNotPaused 
    {
        require(validationScore <= 10000, "Invalid score range"); // Max 100.00%
        
        bytes32 updateHash = keccak256(
            abi.encodePacked(
                weightsHash,
                previousHash,
                block.timestamp,
                msg.sender
            )
        );
        
        ModelUpdate memory update = ModelUpdate({
            validator: msg.sender,
            weightsHash: weightsHash,
            timestamp: block.timestamp,
            previousHash: previousHash,
            validationScore: validationScore,
            isValid: false
        });
        
        modelUpdates[updateHash] = update;
        updateQueue.push(updateHash);
        
        emit ModelUpdateSubmitted(updateHash, msg.sender);
    }

    /**
     * @dev Validate model update
     * @param updateHash Hash of update to validate
     * @param validationScore Validator's score for update
     */
    function validateUpdate(bytes32 updateHash, uint256 validationScore)
        external
        onlyValidator
        updateExists(updateHash)
        notExpired(updateHash)
        nonReentrant
    {
        require(validationScore <= 10000, "Invalid score range");
        
        ModelUpdate storage update = modelUpdates[updateHash];
        require(!update.isValid, "Already validated");
        require(update.validator != msg.sender, "Cannot self-validate");
        
        // Update validation score with weighted average
        uint256 validatorStake = validatorStakes[msg.sender];
        uint256 weight = (validatorStake * 10000) / totalStaked;
        
        update.validationScore = (
            (update.validationScore * (10000 - weight)) + 
            (validationScore * weight)
        ) / 10000;
        
        if (update.validationScore >= VALIDATION_THRESHOLD) {
            update.isValid = true;
        }
        
        emit ValidationPerformed(updateHash, msg.sender, validationScore);
    }

    /**
     * @dev Create consensus block from validated updates
     */
    function createConsensusBlock() 
        external 
        onlyValidator 
        whenNotPaused 
        nonReentrant 
    {
        require(updateQueue.length >= MIN_VALIDATORS, "Insufficient updates");
        
        bytes32[] memory validUpdates = new bytes32[](updateQueue.length);
        uint256 validCount = 0;
        
        // Collect valid updates
        for (uint256 i = 0; i < updateQueue.length; i++) {
            bytes32 updateHash = updateQueue[i];
            ModelUpdate memory update = modelUpdates[updateHash];
            
            if (update.isValid && 
                block.timestamp - update.timestamp <= UPDATE_EXPIRY) {
                validUpdates[validCount] = updateHash;
                validCount++;
            }
        }
        
        require(validCount >= MIN_VALIDATORS, "Insufficient valid updates");
        
        // Create consensus block
        bytes32 blockHash = keccak256(
            abi.encodePacked(
                validUpdates,
                block.timestamp,
                epochNumber
            )
        );
        
        address[] memory initialValidators = new address[](1);
        initialValidators[0] = msg.sender;
        
        ConsensusBlock memory consensusBlock = ConsensusBlock({
            updateHashes: validUpdates,
            timestamp: block.timestamp,
            blockHash: blockHash,
            validators: initialValidators,
            finalized: false
        });
        
        consensusBlocks[blockHash] = consensusBlock;
        
        emit ConsensusBlockCreated(blockHash, epochNumber);
    }

    /**
     * @dev Sign consensus block
     * @param blockHash Hash of consensus block to sign
     */
    function signConsensusBlock(bytes32 blockHash)
        external
        onlyValidator
        nonReentrant
    {
        ConsensusBlock storage consensusBlock = consensusBlocks[blockHash];
        require(consensusBlock.timestamp > 0, "Block does not exist");
        require(!consensusBlock.finalized, "Block already finalized");
        
        // Check if validator already signed
        for (uint256 i = 0; i < consensusBlock.validators.length; i++) {
            require(consensusBlock.validators[i] != msg.sender, "Already signed");
        }
        
        consensusBlock.validators.push(msg.sender);
        
        // Check if consensus reached
        if (consensusBlock.validators.length >= MIN_VALIDATORS) {
            consensusBlock.finalized = true;
            consensusChain.push(blockHash);
            epochNumber++;
            
            // Clear update queue
            delete updateQueue;
            
            emit ConsensusReached(blockHash, block.timestamp);
        }
    }

    /**
     * @dev Get latest consensus block
     */
    function getLatestConsensus() external view returns (
        bytes32 blockHash,
        uint256 timestamp,
        uint256 numUpdates,
        uint256 numValidators,
        bool finalized
    ) {
        require(consensusChain.length > 0, "No consensus yet");
        
        blockHash = consensusChain[consensusChain.length - 1];
        ConsensusBlock memory block = consensusBlocks[blockHash];
        
        return (
            blockHash,
            block.timestamp,
            block.updateHashes.length,
            block.validators.length,
            block.finalized
        );
    }

    /**
     * @dev Emergency pause
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Resume from pause
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
