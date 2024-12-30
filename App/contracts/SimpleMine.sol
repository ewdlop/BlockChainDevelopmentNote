// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleMine {
    address public owner;
    uint256 public rewardPerBlock; // Tokens rewarded per block
    uint256 public totalMined;    // Total tokens mined
    uint256 public maxSupply;     // Maximum tokens that can be mined
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lastMined;

    event Mined(address indexed miner, uint256 amount);

    constructor(uint256 _rewardPerBlock, uint256 _maxSupply) {
        owner = msg.sender;
        rewardPerBlock = _rewardPerBlock;
        maxSupply = _maxSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    function mine() public {
        require(totalMined + rewardPerBlock <= maxSupply, "Max supply reached");
        require(block.number > lastMined[msg.sender], "Already mined this block");

        // Reward the miner
        balances[msg.sender] += rewardPerBlock;
        totalMined += rewardPerBlock;
        lastMined[msg.sender] = block.number;

        emit Mined(msg.sender, rewardPerBlock);
    }

    function checkBalance(address _miner) public view returns (uint256) {
        return balances[_miner];
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;

        // Here, instead of transferring native Ether, you can implement token transfer
        payable(msg.sender).transfer(amount);
    }

    // Owner-only functions
    function adjustReward(uint256 _newReward) public onlyOwner {
        rewardPerBlock = _newReward;
    }
}
