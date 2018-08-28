pragma solidity ^0.4.24;

// Importing contracts: Pausable.sol inherits from Ownable.sol
// Attrition.sol inherits from Pausable.sol
// Importing library: SafeMath.sol
import "./SafeMath.sol";
import "./Pausable.sol";

/**
  * @title Attrition
  * @dev The Attrition contract has an owner address, and provides the
  * functions for the game
  */
contract Attrition is Pausable {

  // Using SafeMath library
  using SafeMath for uint;

  // Array of addresses from players
  address[] public player;

  // This stores balance per address
  mapping (address => uint) public balances;

  // This stores player id per address
  mapping (address => uint) public playerId;

  // It will represent a single player
  struct Player {
    address playerAddress;
    uint playerSince;
  }

  // Array of structs of players
  Player[] public players;

  uint public id;

  // Prize for the last ticket purchased by a player
  // The winner!
  uint public jackpot;
  // Prize for the first ticket purchased after
  // the winner. The the runner-up
  uint public jackpotRunnerUp;
  // A piggy for the next round prize
  uint public jackpotNextRound;
  // Dividens per player
  uint public playerDividends;
  // Last time of new ticket purchased
  uint public lastTimeOfNewTicket;
  uint public round;

  // The ticket price in wei units
  uint public constant TICKET_PRICE = 10 * 10**16;

  // Times are either absolute unix timestamps (seconds since 1970-01-01)
  // or time periods in seconds
  uint public constant TIME_CAP = 300;
  // Avoiding timestamp miner attacks
  uint public constant TIME_WINDOW = 30;

  uint public gameRoundTime;
  uint public gameRoundWindow;

  // Emits player's address and timestamp
  event LogPlayer(address addr, uint sinceTimestamp);

  // Events that will be fired when ending/starting rounds.
  event LogGameRoundEnded(address winner, uint prize);
  event LogGameRoundStarted(address runnerUp, uint runnerUpPrize);

  // A convenient way to validate if it is
  // a returning address
  modifier onlyNewPlayers {
    require(playerId[msg.sender] == 0, "Only one ticket per address.");
    _;
  }


  /**
    * @dev Constructor mounts a way
    * to identify returning players and initializes some variables
    */
  constructor() public payable {
    owner = msg.sender;

    // It's necessary to add an empty first player to identify returning players
    _addPlayer(0);
    // Adding the owner
    _addPlayer(owner);

    player.push(owner);
    balances[owner] = 0;

    lastTimeOfNewTicket = now;
    gameRoundTime = lastTimeOfNewTicket.add(TIME_CAP);
    gameRoundWindow = gameRoundTime.sub(TIME_WINDOW);

    jackpot = msg.value;
    round = 1;
  }


  /**
    * @dev Fallback function checking data length helps
    * player to notice that the contract is used incorrectly
    * and function that do not exist is called.
    */
  function() external payable {
    require(msg.data.length == 0);
  }


  /**
    * @dev Adds a player
    * making `targetPlayer a player`
    * if it is not a returning player
    *
    * @param _targetPlayer address of a player to be added
    */
  function _addPlayer(address _targetPlayer) private {
    id = playerId[_targetPlayer];

    if (id == 0) {
      playerId[_targetPlayer] = players.length;
      id = players.length++;
    }
    players[id] = Player({playerAddress: _targetPlayer, playerSince: now});
    emit LogPlayer(_targetPlayer, now);
  }


  /**
    * @dev This function is callable only for new players (addresses)
    * paying at least the minimum price of the ticket
    * when the contract is not paused
    *
    */
  function buyNewTicket() public payable onlyNewPlayers whenNotPaused {
    require((now >= gameRoundTime) || (now < gameRoundWindow), "30 seconds time window");
    require(msg.value >= TICKET_PRICE, "You must pay at least 0.10 ether to play.");
    _addPlayer(msg.sender);
    player.push(msg.sender);
    balances[msg.sender] = 0;
    lastTimeOfNewTicket = now;
    _returnOnInvestment(msg.value);
  }


  /**
    * @dev Accounting and distribution of the funds
    * deposited per player.
    * Control of the time of the game.
    */
  function _returnOnInvestment(uint _amount) private {
    // Check if the round already ended.
    // If for 5 minutes no new player purchases a ticket then the round ends.
    // Fives minutes is = 5 x 60 seconds. This is TIME_CAP
    if(lastTimeOfNewTicket >= gameRoundTime) {
      // Sends all jackpot to the previous player
      balances[player[id.sub(2)]] = balances[player[id.sub(2)]].add(jackpot);
      emit LogGameRoundEnded(player[id.sub(2)], jackpot);
      jackpot = 0;
      // Player is rewarded with jackpotRunnerUp for ending round
      balances[player[id.sub(1)]] = balances[player[id.sub(1)]].add(jackpotRunnerUp);
      emit LogGameRoundStarted(player[id.sub(1)], jackpotRunnerUp);
      // jackpot is now jackpotNextRound
      jackpot = jackpot.add(jackpotNextRound);
      jackpotNextRound = 0;
      jackpotRunnerUp = 0;
      round = round.add(1);
    }

    gameRoundTime = lastTimeOfNewTicket.add(TIME_CAP);
    gameRoundWindow = gameRoundTime.sub(TIME_WINDOW);
    // Contribution to the current jackpot
    jackpot = jackpot.add((_amount/100).mul(35));
    // Contribution to next round jackpot
    jackpotNextRound = jackpotNextRound.add((_amount/100).mul(5));
    // Reward to player who will close the current round and start
    // a new round
    jackpotRunnerUp = jackpotRunnerUp.add((_amount/100).mul(7));
    // Reward to the creator of the game
    balances[owner] = balances[owner].add((_amount/100).mul(3));

    // Return on investment to current players and owner
    // The last player will start to earn dividends with
    // the next ticket purchased by a new player
    playerDividends =  ( (_amount/100).mul(50))/ (id.sub(1));
    for (uint i = 0; i < (player.length - 1) ; i = i.add(1)) {
      balances[player[i]] = balances[player[i]].add(playerDividends);
    }
  }


  /**
    * @dev Players and owner can withdraw their own funds from balances
    */
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


  /**
    * @dev Calls to `kill` only have an effect if
    * they are made by the owner.
    * Remove the contract from the blockchain
    */
  function kill() public onlyOwner {
    selfdestruct(owner);
  }
}
