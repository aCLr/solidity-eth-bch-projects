// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Sender is Ownable {
    address payable[] public addresses;

    function blockMoney() public payable {
    }

    modifier withAddresses() {
        require(addresses.length > 0, "addresses not specified");
        _;
    }

    function addAddress(address payable _address) public onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == _address) {
                revert("address already exists");
            }
        }
        addresses.push(_address);
    }

    function removeAddress(address _address) public onlyOwner {

        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == _address) {
                addresses[i] = addresses[addresses.length-1];
                addresses.pop();
                return;
            }
        }
        revert("address does not exist");
    }

    function clearAddresses() public onlyOwner withAddresses {

        delete addresses;
    }

    function send() public onlyOwner withAddresses {
        uint _e = address(this).balance;
        require(_e > 0, "contract balance is empty");
        uint each = _e / addresses.length;
        uint remain = _e % addresses.length;
        for (uint i = 0; i < addresses.length; i++) {
            address payable receiver = addresses[i];
            receiver.transfer(each);
        }
        if (remain > 0) {
            address payable r = addresses[addresses.length - 1];
            r.transfer(remain);
        }
    }

}