# Attrition Reimagined

## Introduction

This project is a game resembling: 
* A classic game in behavioral Game Theory called "The War of Attrition" 
* And a current game called FOMO3D.

My game starts with a timer counting down from 5 minutes (TIME_CAP), while users are prompted to buy tickets to extend the time and also get a stake every time a ticket is bought by future players.
ETH deposited in the smart contract in the form of a ticket purchase gets distributed in the round across players with dividends and different jackpots:
* Dividend for players gets 50%
* Jackpot gets 35%
* Jackpot Runner-Up gets 7%
* Jackpot Next Round gets 5%
* The owner is also rewarded getting 3%
* Hint: the owner can destroy the contract and exit with all the funds (including the modulus of the distribution ;))

The last player to buy a ticket before the timer hits zero gets the jackpot. This player is the winner.

The player purchasing a ticket after the winner is the runner-up. This player closes the round and opens a new one. This player gets rewarded with the Jackpot Runner-Up.

Each buy-in extends the clock for 5 minutes, with a cap of 5 minutes, too.
But as we don't want to be tricked by miners, I have introduced a 30-seconds time window (TIME_WINDOW).
No player can purchase a ticket while the TIME_WINDOW is active.

Players have the ability to buy in many times as they want but with different addresses.

At a difference of other games in the same style this is a fully transparent smart contract game.
But it is still focused on the idea of the greed of individuals.


## Setting up the project environment
Before starting, please install the following technical requirements:
#### Node.js
Node.js 8.11.4 LTS and npm 5.6.0 (recommended for most of the users). 
To install Node.js follow the instructions [here](https://nodejs.org/en/)

If Node.js is installed in your system, please check the version in your terminal/shell:
```
$ node -v
v8.11.4
``` 
You can also check the npm version in your terminal/shell:
```
$ npm -v
5.6.0
```
### Truffle
You can install Truffle framework by running the following command in your terminal/shell:
```
$ npm install -g truffle
```
#### Ganache-cli
You can install Ganache-cli by running the following command in your terminal/shell:
```
$ npm install -g ganache-cli
```
You can check ganache-cli version installed in your terminal/shell:
```
$ ganache-cli --version
Ganache CLI v6.1.8 (ganache-core: 2.2.1)
```

## Compilation
Once in the project folder, to compile please run the following command in the command line as root/administrator:
```
$ truffle compile
```

## Migration
To migrate, please run the following command in the command line as root/administrator with ganache-cli opened:
```
$ truffle migrate
```
Or
```
$ truffle migrate --reset
```

## Tests
For testing, please run the following command in the command line as root/administrator with ganache-cli opened:
```
$ truffle test
```

## Need help?
Do you need help evaluating the project?
The following links will help you to find where are located the key files for grading:
* design_pattern_decisions.md [here](www.)
* avoiding_common_attacks.md [here](www.)
* deployed_addresses.txt [here](www.)
* Information and comments on tests.md [here](www.)
* Information on circuit breaker on design_pattern_decisions.md [here](www.)
* Information and comments on library.md [here](www.)


Please feel free to reach me by email at ivanmolto@gmail.com or via the course ryver platform @ivanmolto.

Thank you!!


## License
Attrition Reimagined is Copyright (c) 2018 Ivan Molto Lopez Cepero.
The content of this repository is licensed under a [MIT License](https://github.com/ivanmolto/developer-program-consensys-2018/blob/master/LICENSE).
