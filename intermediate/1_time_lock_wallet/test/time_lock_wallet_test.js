const {expectRevert, expectEvent, time, balance} = require('@openzeppelin/test-helpers');

const TimeLockWallet = artifacts.require("TimeLockWallet");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("TimeLockWallet", function ([owner, acc1]) {
  let instance
  before(async () => {
    instance = await TimeLockWallet.new(600);
  })

  it("should lock with time", async() => {
    const value = web3.utils.toWei('0.01');
    let balanceTracker = await balance.tracker(instance.address);

    expectEvent(
        await instance.lockWithTime(value, 1, {from: owner}),
        "Locked", {amount: value});

    assert.equal(await instance.freeWei(), 0, "invalid free amount")
    assert.equal(await instance.lockedWei(), value, "invalid locked amount")
    assert.equal(await balanceTracker.delta(), value, "invalid initial balance");
  });

  it("received without lock if not from owner", async() => {
    const value = web3.utils.toWei('1');
    let contractBalanceTracker = await balance.tracker(instance.address);

    assert.equal(await instance.freeWei(), 0, "invalid initial free amount")
    await instance.sendTransaction({from: acc1, value: value})
    assert.equal(await instance.freeWei(), value, "invalid free amount")
    assert.equal(await instance.lockedWei(), 0, "invalid locked amount")
    assert.equal(await contractBalanceTracker.delta(), value, "invalid initial balance");
  });

  it("received with lock if from owner", async() => {
    const value = web3.utils.toWei('1.32')
    let contractBalanceTracker = await balance.tracker(instance.address);

    expectEvent(
        await instance.sendTransaction({from: owner, value: value}),
        "Locked", {amount: value});

    assert.equal(await instance.freeWei(), web3.utils.toWei('1'), "invalid free amount")
    assert.equal(await instance.lockedWei(), value, "invalid free amount")
    assert.equal(await contractBalanceTracker.delta(), value, "invalid balance");
  });

  it("can't send more than free value", async() => {
    let contractBalanceTracker = await balance.tracker(instance.address);
    let balanceTracker = await balance.tracker(acc1);

    let amount1 = web3.utils.toWei('1');
    assert.equal(await instance.freeWei(), amount1, "invalid free amount")
    await instance.send(acc1, amount1);
    assert.equal(await balanceTracker.delta(), amount1, "invalid received amount");
    assert.equal(await contractBalanceTracker.delta(), -amount1, "invalid subtracted from contract amount");

    assert.equal(await instance.freeWei(), 0, "invalid free money");
    await expectRevert(instance.send(acc1, amount1), "not enough free money");
  })

  it("should be unlocked during receive", async() => {
    const lockedValue = web3.utils.toWei('1.32');
    const value = web3.utils.toWei('0.5')

    await time.increase(10000);
    assert.equal(await instance.freeWei(), 0, "invalid free money");
    assert.equal(await instance.lockedWei(), lockedValue, "invalid free money");
    expectEvent(
        await instance.sendTransaction({from: acc1, value: value}),
        "Unlocked", {amount: lockedValue});

    assert.equal(await instance.lockedWei(), 0, "invalid locked money");
    assert.equal(await instance.freeWei(), value, "invalid free money");
  })

  it("should unlock during send", async() => {

  })
});
