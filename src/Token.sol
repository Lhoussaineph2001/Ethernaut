// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/**

> Objective :

1. Gain more than 20 tokens

 */
 
contract Token {

    mapping(address => uint256) balances;
    uint256 public totalSupply;

    constructor(uint256 _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

    // @audit-issue vulnerable to arithmetic underflow.
    // @audit-info We start with 20 token

        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}