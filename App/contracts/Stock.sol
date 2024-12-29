```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract manages stocks with functions to create, transfer, and get balances.
contract Stock {
    // Define a structure to hold stock information
    struct StockInfo {
        string name;
        uint256 totalSupply;
        uint256 price;
    }

    // Mapping from stock symbol to StockInfo
    mapping(string => StockInfo) public stocks;

    // Mapping from stock symbol to owner balances
    mapping(string => mapping(address => uint256)) public balances;

    // Event to be emitted when a stock is created
    event StockCreated(string symbol, string name, uint256 totalSupply, uint256 price);

    // Event to be emitted when stocks are transferred
    event Transfer(address from, address to, string symbol, uint256 amount);

    // Function to create a new stock
    function createStock(string memory symbol, string memory name, uint256 totalSupply, uint256 price) public {
        require(stocks[symbol].totalSupply == 0, "Stock already exists");

        // Create the stock and set the total supply and price
        stocks[symbol] = StockInfo(name, totalSupply, price);

        // Assign all the stocks to the creator
        balances[symbol][msg.sender] = totalSupply;

        emit StockCreated(symbol, name, totalSupply, price);
    }

    // Function to transfer stocks from one account to another
    function transferStock(string memory symbol, address to, uint256 amount) public {
        require(balances[symbol][msg.sender] >= amount, "Insufficient balance");

        // Transfer the stocks
        balances[symbol][msg.sender] -= amount;
        balances[symbol][to] += amount;

        emit Transfer(msg.sender, to, symbol, amount);
    }

    // Function to get the balance of stocks for an account
    function getBalance(string memory symbol, address account) public view returns (uint256) {
        return balances[symbol][account];
    }
}
```
