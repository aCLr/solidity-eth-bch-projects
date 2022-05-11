// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiSend is Ownable {
  address[] public accounts;

  event AccountAdded(address account);
  event AccountRemoved(address account);
  event Broadcasted(uint accountsAmount);

  modifier withAccounts() {
    require(accounts.length > 0, "accounts not specified");
    _;
  }

  receive() external payable {}

  function accountsAmount() public view returns (uint) {
    return accounts.length;
  }

  function accountExists(address _acc) public view returns (bool) {
    for (uint i = 0; i < accounts.length; i++) {
      if (accounts[i] == _acc) {
        return true;
      }
    }
    return false;
  }

  function addAccount(address _acc) public onlyOwner {
    if (accountExists(_acc)) {
        revert("account already exists");
    }
    accounts.push(_acc);
    emit AccountAdded(_acc);
  }

  function removeAccount(address _acc) public onlyOwner {

    for (uint i = 0; i < accounts.length; i++) {
      if (accounts[i] == _acc) {
        accounts[i] = accounts[accounts.length-1];
        accounts.pop();
        emit AccountRemoved(_acc);
        return;
      }
    }
    revert("account does not exist");
  }

  function clearAccounts() public onlyOwner withAccounts {

    delete accounts;
  }

  function broadcastSend() public onlyOwner withAccounts {
    uint _e = address(this).balance;
    require(_e > 0, "contract balance is empty");
    uint each = _e / accounts.length;
    uint remain = _e % accounts.length;
    for (uint i = 0; i < accounts.length; i++) {
      address payable receiver = payable(accounts[i]);
      receiver.transfer(each);
    }
    if (remain > 0) {
      address payable r = payable(accounts[accounts.length - 1]);
      r.transfer(remain);
    }
    emit Broadcasted(accounts.length);
  }
}
