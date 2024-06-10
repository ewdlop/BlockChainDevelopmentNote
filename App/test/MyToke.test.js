// test/MyToken.test.js
const MyToken = artifacts.require("MyToken");

contract("MyToken", accounts => {
    it("should put 1,000,000 MyToken in the first account", async () => {
        const instance = await MyToken.deployed();
        const balance = await instance.balanceOf(accounts[0]);
        assert.equal(balance.toString(), web3.utils.toWei('1000000', 'ether'));
    });

    it("should transfer tokens correctly", async () => {
        const instance = await MyToken.deployed();
        await instance.transfer(accounts[1], web3.utils.toWei('100', 'ether'), { from: accounts[0] });

        const balance0 = await instance.balanceOf(accounts[0]);
        const balance1 = await instance.balanceOf(accounts[1]);

        assert.equal(balance0.toString(), web3.utils.toWei('999900', 'ether'));
        assert.equal(balance1.toString(), web3.utils.toWei('100', 'ether'));
    });
});
