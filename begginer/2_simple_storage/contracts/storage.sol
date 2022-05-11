// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title Storage
*/
contract Storage is Ownable {
    int public val = 0;

    function increment() public {
        val += 1;
    }

    function decrement() public {
        val -= 1;
    }

    function reset() public onlyOwner {
        val = 0;
    }
}