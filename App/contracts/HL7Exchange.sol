// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HL7Exchange {
    address public owner;

    struct HL7Message {
        uint256 timestamp;
        string message;
    }

    HL7Message[] public messages;

    event MessageAdded(uint256 timestamp, string message);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addMessage(string memory message) public onlyOwner {
        uint256 timestamp = block.timestamp;
        messages.push(HL7Message(timestamp, message));
        emit MessageAdded(timestamp, message);
    }

    function getMessages() public view returns (HL7Message[] memory) {
        return messages;
    }

    function getMessage(uint256 index) public view returns (uint256, string memory) {
        require(index < messages.length, "Index out of bounds.");
        HL7Message storage msg = messages[index];
        return (msg.timestamp, msg.message);
    }
}
