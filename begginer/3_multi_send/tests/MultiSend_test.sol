// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/Hello.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract TestSender {
    Sender sender;

    function beforeEach() public {
        // <instantiate contract>
        sender = new Sender();
    }

    function testAddAddress() public {
        address payable addr1 = payable(TestsAccounts.getAccount(1));
        sender.addAddress(addr1);
        try sender.addAddress(addr1){
            Assert.ok(false, "added wrongly");
        } catch Error(string memory reason) {
            Assert.equal(reason, 'address already exists', 'failed with unexpected reason');
        }

        assertAddressesLength(1);

        Assert.ok(addressExists(addr1), "address not found");

        address payable addr2 = payable(TestsAccounts.getAccount(2));

        sender.addAddress(addr2);
        try sender.addAddress(addr2){
            Assert.ok(false, "added wrongly");
        } catch Error(string memory reason) {
            Assert.equal(reason, 'address already exists', 'failed with unexpected reason');
        }

        assertAddressesLength(2);

        Assert.ok(addressExists(addr2), "address not found");
        Assert.ok(addressExists(addr1), "address not found");
    }

    function testRemoveAddress() public {
        address payable addr1 = payable(TestsAccounts.getAccount(1));
        try sender.removeAddress(addr1) {
            Assert.ok(false, "removed wrongly");
        } catch Error(string memory reason) {
            Assert.equal(reason, "address does not exist", "failed with unexpected reason");
        }

        sender.addAddress(addr1);
        assertAddressesLength(1);
        Assert.ok(addressExists(addr1), "address not found");

        sender.removeAddress(addr1);
        assertAddressesLength(0);
        Assert.ok(!addressExists(addr1), "address not found");
    }

    function testClearAddressess() public {
        assertAddressesLength(0);

        try sender.clearAddresses() {
            Assert.ok(false, "cleared wrongly");
        } catch Error(string memory reason) {
            Assert.equal(reason, "addresses not specified", "failed with unexpected reason");
        }

        address payable addr1 = payable(TestsAccounts.getAccount(1));
        address payable addr2 = payable(TestsAccounts.getAccount(2));

        sender.addAddress(addr1);
        sender.addAddress(addr2);

        assertAddressesLength(2);
        Assert.ok(addressExists(addr1), "address not added");
        Assert.ok(addressExists(addr2), "address not added");

        sender.clearAddresses();
        assertAddressesLength(0);
        Assert.ok(!addressExists(addr1), "address not deleted");
        Assert.ok(!addressExists(addr2), "address not deleted");
    }

    function testSend() public {
        sender.blockMoney();
        sender.send();
    }

    function assertAddressesLength(uint len) private {
        Assert.equal(sender.getAddresses().length, len, "invalid amount of stored addresses");
    }

    function addressExists(address payable _address) private view returns(bool) {
        address payable[] memory addrs = sender.getAddresses();
        for (uint i = 0; i < addrs.length; i++) {
            if (addrs[i] == _address) {
                return true;
            }
        }
        return false;
    }
}
