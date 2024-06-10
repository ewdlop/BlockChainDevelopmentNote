// migrations/2_deploy_contracts.js
const MyToken = artifacts.require("MyToken");

module.exports = function (deployer) {
    const initialSupply = 1000000 * 10**18; // 1 million tokens with 18 decimals
    deployer.deploy(MyToken, initialSupply);
};
