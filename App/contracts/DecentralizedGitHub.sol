// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DecentralizedGitHub {
    struct Commit {
        string commitHash;
        string message;
        string timestamp;
        address author;
        string fileChanges; // IPFS hash containing file changes
    }
    
    struct Repository {
        string name;
        address owner;
        string description;
        bool isPrivate;
        string[] branches;
        mapping(string => Commit[]) branchCommits; // branch name => commits
        mapping(address => bool) collaborators;
    }

    mapping(string => Repository) public repositories;
    mapping(address => string[]) public userRepositories;

    event RepositoryCreated(string name, address owner);
    event CommitPushed(string repoName, string branch, string commitHash);
    event CollaboratorAdded(string repoName, address collaborator);
    event BranchCreated(string repoName, string branchName);

    modifier onlyRepoOwner(string memory repoName) {
        require(repositories[repoName].owner == msg.sender, "Not repository owner");
        _;
    }

    modifier onlyCollaborator(string memory repoName) {
        require(
            repositories[repoName].owner == msg.sender || 
            repositories[repoName].collaborators[msg.sender],
            "Not authorized"
        );
        _;
    }

    function createRepository(
        string memory name,
        string memory description,
        bool isPrivate
    ) external {
        require(bytes(repositories[name].name).length == 0, "Repository already exists");
        
        Repository storage newRepo = repositories[name];
        newRepo.name = name;
        newRepo.owner = msg.sender;
        newRepo.description = description;
        newRepo.isPrivate = isPrivate;
        
        // Initialize main branch
        newRepo.branches.push("main");
        
        userRepositories[msg.sender].push(name);
        
        emit RepositoryCreated(name, msg.sender);
    }

    function pushCommit(
        string memory repoName,
        string memory branch,
        string memory commitHash,
        string memory message,
        string memory timestamp,
        string memory fileChanges
    ) external onlyCollaborator(repoName) {
        bool branchExists;
        for (uint i = 0; i < repositories[repoName].branches.length; i++) {
            if (keccak256(bytes(repositories[repoName].branches[i])) == keccak256(bytes(branch))) {
                branchExists = true;
                break;
            }
        }
        require(branchExists, "Branch does not exist");

        Commit memory newCommit = Commit({
            commitHash: commitHash,
            message: message,
            timestamp: timestamp,
            author: msg.sender,
            fileChanges: fileChanges
        });

        repositories[repoName].branchCommits[branch].push(newCommit);
        emit CommitPushed(repoName, branch, commitHash);
    }

    function createBranch(
        string memory repoName,
        string memory branchName
    ) external onlyCollaborator(repoName) {
        for (uint i = 0; i < repositories[repoName].branches.length; i++) {
            require(
                keccak256(bytes(repositories[repoName].branches[i])) != keccak256(bytes(branchName)),
                "Branch already exists"
            );
        }
        
        repositories[repoName].branches.push(branchName);
        emit BranchCreated(repoName, branchName);
    }

    function addCollaborator(
        string memory repoName,
        address collaborator
    ) external onlyRepoOwner(repoName) {
        repositories[repoName].collaborators[collaborator] = true;
        emit CollaboratorAdded(repoName, collaborator);
    }

    function getCommits(
        string memory repoName,
        string memory branch
    ) external view returns (Commit[] memory) {
        return repositories[repoName].branchCommits[branch];
    }

    function getBranches(
        string memory repoName
    ) external view returns (string[] memory) {
        return repositories[repoName].branches;
    }
}
