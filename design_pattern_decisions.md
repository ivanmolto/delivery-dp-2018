# Design Pattern Decisions
This document explains why I chose to use the design patterns that I did.

As an introduction, I want to mention that I have worked on reducing unnecessary code execution and ensure the smart contracts workflow is simple. I have also reused audited code as is the case of smart contracts `Ownable.sol` and `Pausable.sol` and the library `SafeMath.sol` from [Zeppelin Solidity](https://github.com/OpenZeppelin/openzeppelin-solidity). It is an interesting framework to build secure smart contracts on Ethereum.

These are the design patterns I have implemented and the reasons why:
* Ownership pattern.
* Circuit breaker pattern.
* Withdrawal pattern.
* Lifetime pattern.
* Fallback function simple.
* Integer arithmetic under/overflow.
* Avoiding players may drop offline.


## Ownership pattern
Attrition.sol inherits from Pausable.sol which inherits from Ownable.sol.
Using the `onlyOwner()` modifier helps to limit access to certain functions to only the owner of the smart contract. 
Please see following functions:
```
function kill() public onlyOwner {...}
function pause() public onlyOwner whenNotPaused {...}
function unpause() public onlyOwner whenPaused {...}
```

## Circuit breaker pattern
Importing the Pausable.sol smart contract allows the owner to pause or unpause different functionalities of the Attrition.sol smart contract in case of an emergency stop is required when things are going wrong (bugs discovery or attack).
Please see the following modifiers and functions in Pausable.sol:
```
modifier whenNotPaused() {...}
modifier whenPaused() {...}
function pause() public onlyOwner whenNotPaused {...}
function unpause() public onlyOwner whenPaused {...}
```
As I consider `function withdraw() public returns (bool) {...}` a critical feature for players, the players can still get their money from their balances in case of an emergency stop.
I decided to stop players from purchasing tickets(depositing more funds into the contract) but still allowing accounts with
balances to withdraw their funds.

## Withdrawal pattern
Each external call has been isolated into its own transaction which is relevant for payments. 
I considered that is better to let players withdraw funds rather than push funds to them automatically.
With this pattern I reduce potential problems with the gas limit and re-entrancy attack.
Please see implementation below:

```
function withdraw() public returns (bool) {
    uint total = balances[msg.sender];
    if (total > 0) {
      // It is important to set this to zero because the recipient
      // can call this function again as part of the receiving call
      // before 'send' returns.
      balances[msg.sender] = 0;
      if (!msg.sender.send(total)) {
        // No need to call throw here, just reset the amount owing
        balances[msg.sender] = total;
        return false;
      }
    }
    return true;
  }
```


## Lifetime pattern
I applied the following code to control the destruction of the Attrition.sol smart contract.
As it is an irreversible action I have restricted access to this function only to the owner.
No other contract calls this contract so no worries about it.
```
 function kill() public onlyOwner {
    selfdestruct(owner);
  }
  ```
Sometimes these kind of games based on Game Theory and Economic Behavior can be considered also a Ponzi/Pyramid scheme. 
Depending on the future of blockchain and gambling regulations/laws may be necessary to kill the contract to be compliant.
Please note that this function sends all the funds in the contract to the owner's address and so a malicious owner could use it as an exit scam. 
You can read on Internet different opinions about similar games (FOMO3D, etc,...).


## Fallback function simple
In the Attrition.sol smart contract the fallback function has been marked payable because I need that the contract can receive Ether through regular transactions.
With the gas limit there is only a check of data length. Please see below:
```
function() external payable {
    require(msg.data.length == 0);
  }
```
Checking data length helps any honest player notice that the contract is used incorrectly and 
that a function that does not exist has been called.


## Integer arithmetic under/overflow
I have decided to use SafeMath library from Open Zeppelin to avoid problems with arithmetic operations.
```
using SafeMath for uin256;
```

## Avoiding players may drop "offline"
Games have the problem that players may "drop offline" and not return.
Engagement and loyalty is critical for games.
I provide a way to enhance engagement by adding additional economic incentives.
The game provides dividends to players, a jackpot for the runner up that closes a round and start a new one.
And of course a great jackpot.

