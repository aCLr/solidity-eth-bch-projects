const TimeLockWallet = artifacts.require("TimeLockWallet");

module.exports = function (deployer) {
  deployer.deploy(TimeLockWallet, 100);
};
