# Avoiding Common Attacks

I have followed the Solidity coding standards and smart contract development best practices as a guideline for safety.
As all smart contracts are susceptible to have errors in them, I have worked and tried that the code in this repository is able to respond to common attacks and vulnerabilities.
I have focused my efforts on the following vulnerabilities, attacks, and patterns:

* Re-entrancy and Checks-Effects-Interactions pattern.
* Timestamp dependence.
* Circuit breaker pattern.
* Integer arithmetic under/overflow.

## Re-entrancy and Checks-Effects-Interactions pattern
The recommended method of sending funds after an effect is using the withdrawal pattern to avoid a potential security risk 
such as the re-entrancy attack. This pattern also avoids the Attrition.sol smart contract being stuck forever while the process of transfer funds.

Additionally, I have used `send()` instead of `call.value()` as it prevents any external code from being executed.
And using `send()` instead of `transfer` we can know when external calls fail.
Using send() will prevent re-entrancy but it is incompatible with any contract whose fallback function requires more than 2,300 gas.

A pull over push payments strategy has also been adopted, with accounting and sending funds in different functions:
```
function _returnOnInvestment(uint _amount) private {...}
function withdraw() public returns (bool) {...}
```
Please note that if something wrong happens the owner can still withdraw all the funds to the owner's address with a `selfdestruct()`.


## Timestamp dependence
The behavior of block miners with timestamps is a critical vulnerability of time dependent games as it is this project.
As we know `block.timestamp` and `now` are subject to manipulation by block miners in a 30 seconds window.
I decided to minimize this vulnerability with a gap of 30 seconds in between the last purchase permitted and the timer running out.
Please see variables TIME_CAP and TIME_WINDOW in the Attrition.sol smart contract.

With a 30 seconds gap, I am avoiding the following attacks: 
* An Ethereum miner censoring a block from going through, and allowing a desired address to win the jackpot.
Censoring a block allows to prevent other ticket purchases from being accepted before the timer runs out 
and a desired player/address to make away with the winnings.
* Other attack avoided is one from  an individual who takes a successful block stuffing an attack to end it.
But how much the attacker has to paid in gas fees to run out the clock? Glad to discuss with you.

One way to discover that something wrong happened is in the block immediately after the winning purchase ticket.
How many unsuccessful ticket purchases attempts were there? 
The thing is if one of these tickets had gone through, the game could still be going on with no winner at all.


## Circuit breaker pattern
An option to pause the contract when things are going wrong has been implemented ('circuit breaker').
Importing the Pausable.sol smart contract allows the owner to pause or unpause different functionalities of the Attrition.sol smart contract in case of an emergency stop is required (bugs discovery or attack).
Please see the following modifiers and functions in Pausable.sol:
```
modifier whenNotPaused() {...}
modifier whenPaused() {...}
function pause() public onlyOwner whenNotPaused {...}
function unpause() public onlyOwner whenPaused {...}
```
As I consider `function withdraw() public returns (bool) {...}` a critical feature for players, the players can still get their money from their balances in case of an emergency stop.
I decided to stop players from purchasing tickets (depositing more funds into the contract) but still allowing accounts with
balances to withdraw their funds.


## Integer arithmetic under/overflow
Integers in Solidity can generate problems when they become too large or too small causing an under/overflow.
I have used the SafeMath library from Open Zeppelin to avoid this problems that can cause some vulnerabilities from a malicious player. As if one player can modify state the Attrition.sol smart contract would be vulnerable.
```
using SafeMath for uint256;
```
