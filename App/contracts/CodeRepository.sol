```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract manages code commits with functions to add and retrieve commits.
contract CodeRepository {
    struct Commit {
        address author;
        string message;
        string hash;
        uint256 timestamp;
    }

    Commit[] public commits;

    event CommitAdded(address indexed author, string message, string hash, uint256 timestamp);

    // Function to add a new commit
    function addCommit(string memory message, string memory hash) public {
        Commit memory newCommit = Commit({
            author: msg.sender,
            message: message,
            hash: hash,
            timestamp: block.timestamp
        });

        commits.push(newCommit);

        emit CommitAdded(msg.sender, message, hash, block.timestamp);
    }

    // Function to get the total number of commits
    function getCommitsCount() public view returns (uint256) {
        return commits.length;
    }

    // Function to get the details of a specific commit by index
    function getCommit(uint256 index) public view returns (address, string memory, string memory, uint256) {
        require(index < commits.length, "Index out of bounds");
        Commit memory commit = commits[index];
        return (commit.author, commit.message, commit.hash, commit.timestamp);
    }
}
```
