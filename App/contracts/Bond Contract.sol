// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BondContract {
    // Define the structure to hold bond information
    struct Bond {
        address payable owner;
        uint256 principal;
        uint256 interestRate; // Interest rate in basis points (1% = 100 basis points)
        uint256 maturityDate;
        bool redeemed;
    }

    // Mapping from bond ID to Bond
    mapping(uint256 => Bond) public bonds;

    // Bond counter to assign unique IDs to bonds
    uint256 public bondCounter;

    // Event to be emitted when a new bond is issued
    event BondIssued(uint256 bondId, address owner, uint256 principal, uint256 interestRate, uint256 maturityDate);

    // Event to be emitted when a bond is redeemed
    event BondRedeemed(uint256 bondId, address owner, uint256 principal, uint256 interest);

    // Function to issue a new bond
    function issueBond(address payable owner, uint256 principal, uint256 interestRate, uint256 maturityDate) public {
        require(maturityDate > block.timestamp, "Maturity date must be in the future");

        // Increment the bond counter
        bondCounter++;

        // Create the bond
        bonds[bondCounter] = Bond({
            owner: owner,
            principal: principal,
            interestRate: interestRate,
            maturityDate: maturityDate,
            redeemed: false
        });

        emit BondIssued(bondCounter, owner, principal, interestRate, maturityDate);
    }

    // Function to redeem a bond
    function redeemBond(uint256 bondId) public {
        Bond storage bond = bonds[bondId];
        require(msg.sender == bond.owner, "Only the bond owner can redeem the bond");
        require(block.timestamp >= bond.maturityDate, "Bond has not matured yet");
        require(!bond.redeemed, "Bond already redeemed");

        // Calculate the interest to be paid
        uint256 interest = bond.principal * bond.interestRate / 10000; // 10000 basis points = 100%

        // Transfer the principal and interest to the bond owner
        bond.owner.transfer(bond.principal + interest);

        // Mark the bond as redeemed
        bond.redeemed = true;

        emit BondRedeemed(bondId, bond.owner, bond.principal, interest);
    }

    // Function to get bond details
    function getBondDetails(uint256 bondId) public view returns (address, uint256, uint256, uint256, bool) {
        Bond storage bond = bonds[bondId];
        return (
            bond.owner,
            bond.principal,
            bond.interestRate,
            bond.maturityDate,
            bond.redeemed
        );
    }
}
