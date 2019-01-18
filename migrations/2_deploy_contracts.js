var AucSters = artifacts.require("./AucSters.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = function(deployer) {
  deployer.deploy(AucSters, 1000000);
  deployer.deploy(SafeMath);
};
