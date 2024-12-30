// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Honeypot {
    mapping(address => uint256) public balances;

    // Accept deposits
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Misleading withdrawal function
    function withdraw(uint256 amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance");
        require(address(this).balance >= amount, "Contract balance too low");

        // Misleading condition: Always fails for specific addresses
        if (msg.sender == address(0x123)) {
            revert("Access denied for this address");
        }

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");

        balances[msg.sender] -= amount;
    }

    // Fallback function to accept Ether
    fallback() external payable {}
    receive() external payable {}
}
