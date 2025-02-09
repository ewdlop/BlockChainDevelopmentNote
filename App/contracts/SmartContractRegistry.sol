// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SmartContractRegistry {
    struct Contract {
        string name;
        string version;
        address owner;
        string sourceCode;
        string documentation;
        bool isVerified;
        uint256 creationTime;
        ContractStatus status;
        address[] authorizedUsers;
        uint256 lastUpdateTime;
    }

    struct ContractVersion {
        string version;
        string sourceCode;
        uint256 deploymentTime;
        string changeLog;
    }

    enum ContractStatus {
        Draft,
        UnderReview,
        Active,
        Deprecated,
        Paused
    }

    // State variables
    mapping(bytes32 => Contract) public contracts;
    mapping(bytes32 => ContractVersion[]) public contractVersions;
    mapping(address => bytes32[]) public userContracts;
    mapping(address => bool) public administrators;
    
    uint256 public totalContracts;
    address public owner;
    bool public paused;

    // Events
    event ContractCreated(bytes32 indexed contractId, string name, address owner);
    event ContractUpdated(bytes32 indexed contractId, string version);
    event ContractStatusChanged(bytes32 indexed contractId, ContractStatus newStatus);
    event UserAuthorized(bytes32 indexed contractId, address user);
    event UserRevoked(bytes32 indexed contractId, address user);
    event AdministratorAdded(address administrator);
    event AdministratorRemoved(address administrator);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyAdmin() {
        require(administrators[msg.sender], "Only administrators can call this function");
        _;
    }

    modifier contractExists(bytes32 contractId) {
        require(contracts[contractId].owner != address(0), "Contract does not exist");
        _;
    }

    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier onlyContractOwner(bytes32 contractId) {
        require(contracts[contractId].owner == msg.sender, "Only contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        administrators[msg.sender] = true;
        paused = false;
    }

    // Core functions
    function createContract(
        string memory name,
        string memory version,
        string memory sourceCode,
        string memory documentation
    ) external notPaused returns (bytes32) {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(version).length > 0, "Version cannot be empty");
        require(bytes(sourceCode).length > 0, "Source code cannot be empty");

        bytes32 contractId = keccak256(abi.encodePacked(name, msg.sender, block.timestamp));
        
        require(contracts[contractId].owner == address(0), "Contract ID already exists");

        Contract storage newContract = contracts[contractId];
        newContract.name = name;
        newContract.version = version;
        newContract.owner = msg.sender;
        newContract.sourceCode = sourceCode;
        newContract.documentation = documentation;
        newContract.isVerified = false;
        newContract.creationTime = block.timestamp;
        newContract.status = ContractStatus.Draft;
        newContract.lastUpdateTime = block.timestamp;

        // Add initial version
        ContractVersion memory initialVersion = ContractVersion({
            version: version,
            sourceCode: sourceCode,
            deploymentTime: block.timestamp,
            changeLog: "Initial version"
        });
        contractVersions[contractId].push(initialVersion);

        // Update user contracts
        userContracts[msg.sender].push(contractId);
        totalContracts++;

        emit ContractCreated(contractId, name, msg.sender);
        return contractId;
    }

    function updateContract(
        bytes32 contractId,
        string memory newVersion,
        string memory newSourceCode,
        string memory changeLog
    ) external contractExists(contractId) onlyContractOwner(contractId) notPaused {
        require(bytes(newVersion).length > 0, "Version cannot be empty");
        require(bytes(newSourceCode).length > 0, "Source code cannot be empty");

        Contract storage contractToUpdate = contracts[contractId];
        contractToUpdate.version = newVersion;
        contractToUpdate.sourceCode = newSourceCode;
        contractToUpdate.lastUpdateTime = block.timestamp;
        contractToUpdate.isVerified = false;

        // Add new version
        ContractVersion memory newContractVersion = ContractVersion({
            version: newVersion,
            sourceCode: newSourceCode,
            deploymentTime: block.timestamp,
            changeLog: changeLog
        });
        contractVersions[contractId].push(newContractVersion);

        emit ContractUpdated(contractId, newVersion);
    }

    function changeContractStatus(
        bytes32 contractId,
        ContractStatus newStatus
    ) external contractExists(contractId) onlyAdmin {
        contracts[contractId].status = newStatus;
        emit ContractStatusChanged(contractId, newStatus);
    }

    function authorizeUser(
        bytes32 contractId,
        address user
    ) external contractExists(contractId) onlyContractOwner(contractId) {
        require(user != address(0), "Invalid user address");
        require(!isUserAuthorized(contractId, user), "User already authorized");

        contracts[contractId].authorizedUsers.push(user);
        emit UserAuthorized(contractId, user);
    }

    function revokeUser(
        bytes32 contractId,
        address user
    ) external contractExists(contractId) onlyContractOwner(contractId) {
        require(isUserAuthorized(contractId, user), "User not authorized");

        Contract storage contractToUpdate = contracts[contractId];
        for (uint i = 0; i < contractToUpdate.authorizedUsers.length; i++) {
            if (contractToUpdate.authorizedUsers[i] == user) {
                // Remove user by replacing with last element and popping
                contractToUpdate.authorizedUsers[i] = contractToUpdate.authorizedUsers[contractToUpdate.authorizedUsers.length - 1];
                contractToUpdate.authorizedUsers.pop();
                break;
            }
        }

        emit UserRevoked(contractId, user);
    }

    // Admin functions
    function addAdministrator(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "Invalid administrator address");
        require(!administrators[newAdmin], "Already an administrator");
        
        administrators[newAdmin] = true;
        emit AdministratorAdded(newAdmin);
    }

    function removeAdministrator(address admin) external onlyOwner {
        require(admin != owner, "Cannot remove contract owner");
        require(administrators[admin], "Not an administrator");
        
        administrators[admin] = false;
        emit AdministratorRemoved(admin);
    }

    function togglePause() external onlyOwner {
        paused = !paused;
    }

    // View functions
    function getContract(bytes32 contractId) external view returns (
        string memory name,
        string memory version,
        address owner,
        bool isVerified,
        uint256 creationTime,
        ContractStatus status,
        uint256 lastUpdateTime
    ) {
        Contract storage contractData = contracts[contractId];
        require(contractData.owner != address(0), "Contract does not exist");
        
        return (
            contractData.name,
            contractData.version,
            contractData.owner,
            contractData.isVerified,
            contractData.creationTime,
            contractData.status,
            contractData.lastUpdateTime
        );
    }

    function getContractVersions(bytes32 contractId) external view returns (ContractVersion[] memory) {
        return contractVersions[contractId];
    }

    function getUserContracts(address user) external view returns (bytes32[] memory) {
        return userContracts[user];
    }

    function isUserAuthorized(bytes32 contractId, address user) public view returns (bool) {
        Contract storage contractData = contracts[contractId];
        if (contractData.owner == user) return true;
        
        for (uint i = 0; i < contractData.authorizedUsers.length; i++) {
            if (contractData.authorizedUsers[i] == user) return true;
        }
        return false;
    }

    function getContractCount() external view returns (uint256) {
        return totalContracts;
    }
}
