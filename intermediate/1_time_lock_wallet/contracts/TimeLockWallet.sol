// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TimeLockWallet is Ownable {


  uint[] freeTimes;
  uint lockTime;
  uint public nextFreeTime;

  struct lockedMoney {
    uint idx;
    uint amount;
  }

  mapping(uint => lockedMoney) public unlockMoments;

  uint public freeWei;
  uint public lockedWei;

  event Locked(uint amount);
  event Unlocked(uint amount);

  constructor(uint64 _lockTime) {
    lockTime = _lockTime;
  }

  receive() external payable {
    unlockIfNeeds();
    if (msg.sender == owner()) {
      lockReceived();
    } else {
      freeWei += msg.value;
    }
  }

  function lockReceived() internal onlyOwner {
    uint256 n = block.timestamp + lockTime;
    if (n < nextFreeTime) {
      nextFreeTime = n;
    }
    freeTimes.push(n);
    unlockMoments[n] = lockedMoney(freeTimes.length - 1, msg.value);
    lockedWei += msg.value;
    emit Locked(msg.value);
  }

  function send(address payable _addr, uint64 value) external onlyOwner {
    unlockIfNeeds();
    require(freeWei >= value, "not enough free money");
    require(address(this).balance >= value, 'insufficient funds');
    freeWei -= value;
    _addr.transfer(value);
  }

  function unlockIfNeeds() internal {
    if (block.timestamp < nextFreeTime || freeTimes.length == 0) {
      return;
    }
    lockedMoney memory u = unlockMoments[nextFreeTime];
    delete unlockMoments[nextFreeTime];
    freeWei += u.amount;
    lockedWei -= u.amount;

    if (freeTimes.length > 1) {
      freeTimes[u.idx] = freeTimes[freeTimes.length-1];
    }
    freeTimes.pop();
    emit Unlocked(u.amount);
    nextFreeTime =  freeTimes[freeTimes.length-1];
  }
}
