var Ownable = artifacts.require("Ownable");
var Pausable = artifacts.require("Pausable");
var SafeMath = artifacts.require("SafeMath");
var Attrition = artifacts.require("Attrition");

module.exports = function(deployer) {
  deployer.deploy(Ownable);
  deployer.deploy(Pausable);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, Attrition);
  deployer.deploy(Attrition);
};
