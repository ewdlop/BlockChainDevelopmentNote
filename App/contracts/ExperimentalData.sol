```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract stores experimental data entries with functions to add and retrieve data.
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

    // Function to add a new data entry
    function addData(string memory data) public onlyOwner {
        uint256 timestamp = block.timestamp;
        dataEntries.push(DataEntry(timestamp, data));
        emit DataAdded(timestamp, data);
    }

    // Function to get all data entries
    function getDataEntries() public view returns (DataEntry[] memory) {
        return dataEntries;
    }

    // Function to get a specific data entry by index
    function getDataEntry(uint256 index) public view returns (uint256, string memory) {
        require(index < dataEntries.length, "Index out of bounds.");
        DataEntry storage entry = dataEntries[index];
        return (entry.timestamp, entry.data);
    }
}
```
