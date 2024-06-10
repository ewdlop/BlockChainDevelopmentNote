// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {
    // Define events
    event LogMessage(string message);
    event LogNumber(uint256 number);

    // Function to emit events
    function logSomething(string memory message, uint256 number) public {
        emit LogMessage(message);
        emit LogNumber(number);
    }
}
