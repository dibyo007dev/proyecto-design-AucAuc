var AucSters = artifacts.require("./AucSters.sol");

module.exports = function(deployer) {
  deployer.deploy(AucSters, 1000000);
};
