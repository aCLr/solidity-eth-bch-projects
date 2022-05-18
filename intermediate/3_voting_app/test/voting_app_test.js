const VotingApp = artifacts.require("VotingApp");

const {expectRevert, expectEvent, time} = require('@openzeppelin/test-helpers');

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("VotingApp", ([owner, addr1, addr2, addr3, addr4]) => {

  describe('create voting', () => {
    it("should fail if no options", async () => {
      await expectRevert(VotingApp.new([], 60, {from: owner}), "need at least 2 options");
    });

    it("should fail if only one option", async () => {
      await expectRevert(VotingApp.new(["1"], 60, {from: owner}), "need at least 2 options");
    });

    it("should fail if not enough time", async () => {
      await expectRevert(VotingApp.new(["1", "2"], 59, {from: owner}), "60 seconds for voting is minimum");
    });
  });

  describe("voting", () => {
    let instance

    votesEqual = async(choice, amount) => {
      let votes = await instance.getVotes(choice);
      assert.equal(votes, amount, "invalid votes amount");
    }
    
    before(async () => {
      instance = await VotingApp.new(["1", "2", "3", "4"], 10000, {from: owner})
    })

    it('should fail if no option', async () => {
      await expectRevert(instance.vote("5", {from: addr1}), "not allowed choice");
    });

    it('should fail if already voted', async () => {
      await instance.vote("4", {from: addr1});
      await expectRevert(instance.vote("4", {from: addr1}), "already voted");
      await expectRevert(instance.vote("1", {from: addr1}), "already voted");

      await votesEqual("4", 1);
      await votesEqual("1", 0);
    });

    it('should vote same', async () => {
      await instance.vote("4", {from: addr2});
      await votesEqual("4", 2);
    });

    it('should vote another one', async () => {
      await instance.vote("2", {from: addr3});
      await votesEqual("2", 1);
      await votesEqual("4", 2);
    });

    it("should finish during voting if finished", async () => {
      await expectRevert(instance.getWinnersAmount(), "winners not defined");
      await expectRevert(instance.getOneOfWinners(1), "winners not defined");

      await time.increase(10000);
      assert.ok(await instance.votingFinished(), "not finished");

      const receipt = await instance.vote("3", {from: addr4});
      await votesEqual("3", 1);
      expectEvent(receipt, "VotingFinished", {winners: ["4"]});
    })

    it('should be one winner', async () => {
      assert.equal(await instance.getWinnersAmount(), 1, "unexpected winners amount");
      assert.equal(await instance.getOneOfWinners(0), "4", "unexpected winners amount");
    });

    it('should no vote because winners defined', async () => {
      await expectRevert(instance.vote("3", {from: owner}), "winners defined");
    });

    it('should no finish voting because winners defined', async () => {
      await expectRevert(instance.finishVoting(), "winners defined");
    });

    it('several winners', async () => {
      let instance = await VotingApp.new(["1", "2", "3", "4"], 10000, {from: owner})
      await instance.vote("3", {from: addr1});
      await instance.vote("1", {from: addr2});

      await time.increase(10000);
      const receipt = await instance.finishVoting();
      expectEvent(receipt, "VotingFinished", {winners: ["1", "3"]});
      assert.equal(await instance.getWinnersAmount(), 2, "unexpected winners amount");
      assert.equal(await instance.getOneOfWinners(0), "1", "unexpected winners amount");
      assert.equal(await instance.getOneOfWinners(1), "3", "unexpected winners amount");
    });

  });
});
