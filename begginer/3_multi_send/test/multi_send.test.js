const MultiSend = artifacts.require("MultiSend");
const {expectRevert} = require('@openzeppelin/test-helpers');

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("MultiSend", function ([owner, acc1, acc2, acc3]) {

  let instance
  before(async () => {
    instance = await MultiSend.deployed();
  })
  getAccBalance = async (acc) => {
    let b = await web3.eth.getBalance(acc);
    return web3.utils.fromWei(b, 'ether')
  }
  beforeEach(async function() {
    if (await instance.accountsAmount() > 0) {
      await instance.clearAccounts({from: owner});
    }
  })

  describe("operate accounts", () => {

    it("should failed with additional address", async () => {
      await instance.addAccount(acc1, {from: owner});
      await expectRevert(instance.addAccount(acc1, {from: owner}), 'account already exists');

      assert.equal(await instance.accountsAmount(), 1, "account added wrongly");
      assert.ok(await instance.accountExists(acc1), "account not exists");
    });

    it("should add multiple addresses", async () => {
      await instance.addAccount(acc1, {from: owner});
      await instance.addAccount(acc2, {from: owner});
      await instance.addAccount(acc3, {from: owner});

      assert.equal(await instance.accountsAmount(), 3, "account added wrongly");
      assert.ok(await instance.accountExists(acc1), "account not exists");
      assert.ok(await instance.accountExists(acc2), "account not exists");
      assert.ok(await instance.accountExists(acc3), "account not exists");
    })

    it("should failed when address removed again", async () => {
      await instance.addAccount(acc1, {from: owner});
      await instance.addAccount(acc2, {from: owner});
      await instance.removeAccount(acc1, {from: owner});
      await expectRevert(instance.removeAccount(acc1, {from: owner}), 'account does not exist');

      assert.equal(await instance.accountsAmount(), 1, "account added wrongly");
      assert.ok(!(await instance.accountExists(acc1)), "account exists");
      assert.ok(await instance.accountExists(acc2), "account not exists");
    });

    it("should clear addresses", async () => {
      await instance.addAccount(acc1, {from: owner});
      await instance.addAccount(acc2, {from: owner});
      assert.equal(await instance.accountsAmount(), 2, "wrong accounts amount");

      await instance.clearAccounts({from: owner});
      assert.equal(await instance.accountsAmount(), 0, "accounts not cleared");
      assert.ok(!(await instance.accountExists(acc1)), "account exists");
      assert.ok(!(await instance.accountExists(acc2)), "account exists");
    });
  })


  describe("operate balances", () => {
    let acc1InitialBalance, acc2InitialBalance, acc3InitialBalance

    beforeEach(async function() {
      // cleanup instance balance
      if ((await getAccBalance(instance.address)) > 0) {
        await instance.addAccount(acc1, {from: owner});
        await instance.broadcastSend({from: owner})
        await instance.removeAccount(acc1, {from: owner})
      }

      acc1InitialBalance = await getAccBalance(acc1);
      acc2InitialBalance = await getAccBalance(acc2);
      acc3InitialBalance = await getAccBalance(acc3);
    })

    it("should fail if balance is empty", async () => {
      await instance.addAccount(acc1, {from: owner});
      await expectRevert(instance.broadcastSend({from: owner}), "contract balance is empty");
    });

    it("should fail if not accounts", async () => {
      await instance.sendTransaction({from: owner, value: web3.utils.toWei('1')})
      await expectRevert(instance.broadcastSend({from: owner}), "accounts not specified");
    });

    it("should send all to one account", async () => {
      await instance.addAccount(acc1, {from: owner});

      await instance.sendTransaction({from: owner, value: web3.utils.toWei('1')})

      await instance.broadcastSend({from: owner});

      let acc1ResultBalance = await getAccBalance(acc1);

      assert.equal(acc1ResultBalance - acc1InitialBalance, '1', "invalid balance")
    });

    it("should fail if already sent", async () => {
      await instance.addAccount(acc1, {from: owner});

      await instance.sendTransaction({from: owner, value: web3.utils.toWei('1')})

      await instance.broadcastSend({from: owner});
      await expectRevert(instance.broadcastSend({from: owner}), "contract balance is empty");
    });

    it("should send equal part to each account", async () => {
      await instance.addAccount(acc1, {from: owner});
      await instance.addAccount(acc2, {from: owner});

      await instance.sendTransaction({from: owner, value: web3.utils.toWei('1')})

      await instance.broadcastSend({from: owner});

      let acc1ResultBalance = await getAccBalance(acc1);
      let acc2ResultBalance = await getAccBalance(acc2);

      assert.equal(acc1ResultBalance - acc1InitialBalance, '0.5', "invalid balance")
      assert.equal(acc2ResultBalance - acc2InitialBalance, '0.5', "invalid balance")
    });
  })


});
