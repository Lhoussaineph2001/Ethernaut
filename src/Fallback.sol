// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

/**
> Objectives :

1 . Claim ownership
2 . Drain it's ETH

*/

 contract Fallback { 
    
    mapping(address => uint256) public contributions;
     address public owner; 
     
    constructor() {

         owner = msg.sender; 
         contributions[msg.sender] = 1000 * (1 ether); 
         
    }
    
 modifier onlyOwner() { 
        
        require(msg.sender == owner, "caller is not the owner"); 
        
        _;
        
 }
     
function contribute() public payable {
        
         require(msg.value < 0.001 ether); 
         
         contributions[msg.sender] += msg.value;
         
          if (contributions[msg.sender] > contributions[owner]) { 
            
            owner = msg.sender; 
            }
            
         }
         
         
     function getContribution() public view returns (uint256) {
        
         return contributions[msg.sender];
         
         }
         
     function withdraw() public onlyOwner {
        
         payable(owner).transfer(address(this).balance);
         
          }
          
     receive() external payable {
        
        //@audit-high an attacker can be an owner and withdrow all the money just send money to this contract 
        // first with an ABI
        // secound out of an ABI

         require(msg.value > 0 && contributions[msg.sender] > 0);
         
          owner = msg.sender;

     }

     }