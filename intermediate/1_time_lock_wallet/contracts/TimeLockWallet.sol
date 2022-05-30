// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TimeLockWallet is Ownable {


  uint[] public freeTimes;
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

  function lockReceived() external onlyOwner {
    lockWithTime(block.timestamp + lockTime, msg.value);
  }

  function lockWithTime(uint _value, uint _lockTime) external onlyOwner {
    if (_lockTime < nextFreeTime || nextFreeTime == 0) {
      nextFreeTime = _lockTime;
    }
    freeTimes.push(_lockTime);
    unlockMoments[_lockTime] = lockedMoney(freeTimes.length - 1, _value);
    lockedWei += _value;
    emit Locked(_value);
  }

  function moveToLocked(uint _value) external onlyOwner {
    require(freeWei >= _value, "not enough fre money");
    lockReceived(block.timestamp + lockTime, msg.value);
  }

  function send(address payable _addr, uint value) external onlyOwner {
    unlockIfNeeds();
    require(freeWei >= value, "not enough free money");
    require(address(this).balance >= value, 'insufficient funds');
    freeWei -= value;
    _addr.transfer(value);
  }

  function unlock() external onlyOwner {
    unlockIfNeeds();
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
      nextFreeTime = freeTimes[0];
    }
    freeTimes.pop();
    emit Unlocked(u.amount);

    for (uint i = 0; i < freeTimes.length; i++) {
      if (freeTimes[i] < nextFreeTime) {
        nextFreeTime = freeTimes[i];
      }
    }

    nextFreeTime = freeTimes[freeTimes.length-1];
    unlockIfNeeds();
  }
}
