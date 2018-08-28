let Attrition = artifacts.require("./Attrition.sol");

let attritionInstance;

contract('Attrition', function(accounts) {
  const value = 1; // means a successful execution
  // accounts[0] is the default account

  // Positive cases

  // Test case 1
  it("Contract deployment", function() {
    //Fetching the contract instance of the smart contract
    return Attrition.deployed().then(function (instance) {
      // Save the instance in a global variable and all smart contract functions are called using it
      attritionInstance = instance;
      assert(attritionInstance !== undefined, "Attrition contract should be defined");
    });
  });

  // Test case 2
  // The owner should pause the contract in the case an emergency stop is required.
  it("Owner should pause contract", function() {
    return attritionInstance.pause({from: accounts[0]}).then(function (result) {
      assert.equal(value, result.receipt.status, 'Contract paused');
    });
  });

  // Test case 3
  // The owner should unpause the contract when the emergency stop is not required.
  it("Owner should unpause contract", function() {
    return attritionInstance.unpause({from: accounts[0]}).then(function (result) {
      assert.equal(value, result.receipt.status, 'Contract unpaused');
    });
  });

  // Test case 4
  // A new player (a new address account) should purchase a ticket to the game
  // if the player pays at least the minimum value of the ticket (10e+16 wei).
  it("Player should purchase ticket", function() {
    return attritionInstance.buyNewTicket({value: 25e+16, from: accounts[1]}).then(function (result) {
      assert.equal(value, result.receipt.status, 'Purchase is valid');
    });
  });

  // Test case 5
  // The owner if required should transfer the ownership of the Attrition.sol smart contract to another address.
  it("Owner should transfer ownership.", function() {
    return attritionInstance.transferOwnership(accounts[1],{from: accounts[0]}).then(function (result) {
      assert.equal(value, result.receipt.status, 'Ownership transferred.');
    });
  });

  // Test case 6
  // The players and the owner should withdraw funds from their own balance.
  it("Players and owner should withdraw funds from their balance.", function() {
    return attritionInstance.withdraw({from: accounts[0]}).then(function (result) {
      assert.equal(value, result.receipt.status, 'Withdrawal of funds.');
    });
  });

  // Negative cases

  // Test case 7
  // A player can not stop the game/contract, only the owner.
  it("Player should NOT pause the contract.", function() {
    return attritionInstance.pause({from: accounts[2]}).then(function (instance) {
      /* We are testing for a negative condition and hence this particular block will not have executed if our test case was correct
      If this part is executed then we throw an error and catch the error to assert false
      */
      throw("Failed to check.");
    }).catch(function (e) {
      if(e === "Failed to check.") {
        assert(false)
      } else {
        assert(true)
      }
    })
  });

  // Test case 8
  // A player can not unpause the game/contract, only the owner.
  it("Player should NOT unpause the contract.", function() {
    return attritionInstance.unpause({from: accounts[1]}).then(function (instance) {
      /* We are testing for a negative condition and hence this particular block will not have executed if our test case was correct
      If this part is executed then we throw an error and catch the error to assert false
      */
      throw("Failed to check.");
    }).catch(function (e) {
      if(e === "Failed to check.") {
        assert(false)
      } else {
        assert(true)
      }
    })
  });

  // Test case 9
  // A player should not buy a ticket at a lower price than
  // the value of the ticket which is 0.10 ether.
  it("Player should NOT purchase a ticket at a lower price than 0.10 ether.", function() {
    return attritionInstance.buyNewTicket({value: 2e+16, from: accounts[2]}).then(function (result) {
      throw("Failed to check.");
    }).catch(function (e) {
      if (e === "Failed to check.") {
        assert(false);
      } else {
        assert(true);
      }
    })
  });


  // Test case 10
  // A player using a returning address should not buy a ticket.
  // The game rules state that only one ticket per address is permitted.
  // If a player wants to keep inventing funds in the game must use different addresses for each purchase.
  it("Returning player should NOT purchase a ticket - Only one ticket per address.", function() {
    return attritionInstance.buyNewTicket({value: 25e+16, from: accounts[1]}).then(function (result) {
      throw("Failed to check.");
    }).catch(function (e) {
      if (e === "Failed to check.") {
        assert(false);
      } else {
        assert(true);
      }
    })
  });

});
