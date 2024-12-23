// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExperimentalData {
    address public owner;

    struct DataEntry {
        uint256 timestamp;
        string data;
    }

    DataEntry[] public dataEntries;

    event DataAdded(uint256 timestamp, string data);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addData(string memory data) public onlyOwner {
        uint256 timestamp = block.timestamp;
        dataEntries.push(DataEntry(timestamp, data));
        emit DataAdded(timestamp, data);
    }

    function getDataEntries() public view returns (DataEntry[] memory) {
        return dataEntries;
    }

    function getDataEntry(uint256 index) public view returns (uint256, string memory) {
        require(index < dataEntries.length, "Index out of bounds.");
        DataEntry storage entry = dataEntries[index];
        return (entry.timestamp, entry.data);
    }
}
