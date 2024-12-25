// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OptionContract {
    // Define the type of option: Call or Put
    enum OptionType { Call, Put }

    // Define a structure to hold option information
    struct Option {
        address payable buyer;
        address payable seller;
        uint256 strikePrice;
        uint256 premium;
        uint256 expiration;
        OptionType optionType;
        bool exercised;
    }

    // Mapping from option ID to Option
    mapping(uint256 => Option) public options;

    // Option counter to assign unique IDs to options
    uint256 public optionCounter;

    // Event to be emitted when a new option is created
    event OptionCreated(uint256 optionId, address buyer, address seller, uint256 strikePrice, uint256 premium, uint256 expiration, OptionType optionType);

    // Event to be emitted when an option is exercised
    event OptionExercised(uint256 optionId);

    // Function to create a new option
    function createOption(address payable buyer, address payable seller, uint256 strikePrice, uint256 premium, uint256 expiration, OptionType optionType) public {
        require(expiration > block.timestamp, "Expiration must be in the future");

        // Increment the option counter
        optionCounter++;

        // Create the option
        options[optionCounter] = Option({
            buyer: buyer,
            seller: seller,
            strikePrice: strikePrice,
            premium: premium,
            expiration: expiration,
            optionType: optionType,
            exercised: false
        });

        emit OptionCreated(optionCounter, buyer, seller, strikePrice, premium, expiration, optionType);
    }

    // Function to exercise an option
    function exerciseOption(uint256 optionId) public payable {
        Option storage option = options[optionId];
        require(option.expiration > block.timestamp, "Option has expired");
        require(!option.exercised, "Option already exercised");

        if (option.optionType == OptionType.Call) {
            // For call option, buyer can buy the asset at strike price
            require(msg.sender == option.buyer, "Only buyer can exercise the call option");
            require(msg.value == option.strikePrice, "Incorrect value sent");

            // Transfer the strike price to the seller
            option.seller.transfer(msg.value);
        } else if (option.optionType == OptionType.Put) {
            // For put option, buyer can sell the asset at strike price
            require(msg.sender == option.seller, "Only seller can exercise the put option");

            // Transfer the strike price to the buyer
            option.buyer.transfer(option.strikePrice);
        }

        // Mark the option as exercised
        option.exercised = true;

        emit OptionExercised(optionId);
    }

    // Function to get option details
    function getOptionDetails(uint256 optionId) public view returns (address, address, uint256, uint256, uint256, OptionType, bool) {
        Option storage option = options[optionId];
        return (
            option.buyer,
            option.seller,
            option.strikePrice,
            option.premium,
            option.expiration,
            option.optionType,
            option.exercised
        );
    }
}
