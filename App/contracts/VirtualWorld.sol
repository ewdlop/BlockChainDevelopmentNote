// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VirtualWorld {
    // Struct to store location metadata
    struct Location {
        string name;
        string description;
        address owner;
    }

    // Mapping of location IDs to Location data
    mapping(uint256 => Location) public locations;

    // Event to track new locations
    event LocationAdded(uint256 locationId, string name, string description, address owner);

    // Event to track ownership transfers
    event OwnershipTransferred(uint256 locationId, address oldOwner, address newOwner);

    // Modifier to ensure only the owner can perform certain actions
    modifier onlyOwner(uint256 locationId) {
        require(msg.sender == locations[locationId].owner, "You are not the owner of this location");
        _;
    }

    // Function to add a new location to the virtual world
    function addLocation(
        uint256 locationId,
        string memory name,
        string memory description
    ) public {
        require(locations[locationId].owner == address(0), "Location already exists");

        locations[locationId] = Location({
            name: name,
            description: description,
            owner: msg.sender
        });

        emit LocationAdded(locationId, name, description, msg.sender);
    }

    // Function to get location details
    function getLocation(uint256 locationId)
        public
        view
        returns (string memory, string memory, address)
    {
        Location memory loc = locations[locationId];
        return (loc.name, loc.description, loc.owner);
    }

    // Function to transfer ownership of a location
    function transferOwnership(uint256 locationId, address newOwner) public onlyOwner(locationId) {
        require(newOwner != address(0), "New owner cannot be the zero address");

        address oldOwner = locations[locationId].owner;
        locations[locationId].owner = newOwner;

        emit OwnershipTransferred(locationId, oldOwner, newOwner);
    }
}
