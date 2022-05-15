// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract EthWallet is Ownable {
  event Received(address, uint);

  receive() external payable onlyOwner {
    emit Received(msg.sender, msg.value);
  }

  function send(address payable _addr, uint64 value) external onlyOwner {
    require(address(this).balance > value, 'insufficient funds');
    _addr.transfer(value);
  }

  function getBalance() public view returns (uint) {
    return address(this).balance;
  }


}
