// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test , console} from "forge-std/Test.sol";

import {Telephone} from "../src/Telephone.sol";

contract TelephoneTest is Test {

    Telephone tel;

    attackContract attack;

    address newOwner = makeAddr("NOw");

    function setUp() public {

        tel = new Telephone();
        
        attack = new attackContract();

    }

    function testToBreakOwnership() public {
        
        address prevOwner = tel.owner();

        vm.startPrank(address(attack));
        tel.changeOwner(newOwner);
        vm.stopPrank();
        address currentOwner = tel.owner();

        assert(currentOwner == newOwner);
        assert(currentOwner != prevOwner);

    }
}



contract attackContract {

    constructor(){}

}