// migrations/2_deploy_contracts.js
const CodeRepository = artifacts.require("CodeRepository");

module.exports = function (deployer) {
    deployer.deploy(CodeRepository);
};
