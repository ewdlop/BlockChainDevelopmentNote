```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract manages donations and fund allocations.
contract DonationManager {
    address public owner;
    uint256 public totalDonations;

    struct Donation {
        address donor;
        uint256 amount;
    }

    struct Allocation {
        address recipient;
        uint256 amount;
        string description;
    }

    Donation[] public donations;
    Allocation[] public allocations;

    event DonationReceived(address indexed donor, uint256 amount);
    event FundsAllocated(address indexed recipient, uint256 amount, string description);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to donate funds to the contract
    function donate() public payable {
        require(msg.value > 0, "Donation amount must be greater than zero.");

        donations.push(Donation({
            donor: msg.sender,
            amount: msg.value
        }));

        totalDonations += msg.value;

        emit DonationReceived(msg.sender, msg.value);
    }

    // Function to allocate funds to a recipient
    function allocateFunds(address recipient, uint256 amount, string memory description) public onlyOwner {
        require(amount > 0, "Allocation amount must be greater than zero.");
        require(address(this).balance >= amount, "Insufficient funds in contract.");

        payable(recipient).transfer(amount);

        allocations.push(Allocation({
            recipient: recipient,
            amount: amount,
            description: description
        }));

        emit FundsAllocated(recipient, amount, description);
    }

    // Function to get all donations
    function getDonations() public view returns (Donation[] memory) {
        return donations;
    }

    // Function to get all allocations
    function getAllocations() public view returns (Allocation[] memory) {
        return allocations;
    }
}
```
