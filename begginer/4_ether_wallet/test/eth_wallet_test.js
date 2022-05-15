const EthWalletTest = artifacts.require("EthWalletTest");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("EthWalletTest", function (/* accounts */) {
  it("should assert true", async function () {
    await EthWalletTest.deployed();
    return assert.isTrue(true);
  });
});
