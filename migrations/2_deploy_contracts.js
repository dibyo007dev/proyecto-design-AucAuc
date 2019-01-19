var AucSters = artifacts.require("./AucSters.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, AucSters);
  deployer.deploy(AucSters, 1000000);
};
