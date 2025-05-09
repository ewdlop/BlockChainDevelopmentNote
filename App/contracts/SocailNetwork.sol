```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// This contract allows users to create and retrieve posts.
contract SocialNetwork {
    struct Post {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
    }

    Post[] public posts;
    uint256 public nextPostId;

    // Function to create a new post
    function createPost(string memory content) public {
        posts.push(Post(nextPostId, msg.sender, content, block.timestamp));
        nextPostId++;
    }

    // Function to get a post by its ID
    function getPost(uint256 id) public view returns (Post memory) {
        require(id < nextPostId, "Post does not exist");
        return posts[id];
    }
}
```
