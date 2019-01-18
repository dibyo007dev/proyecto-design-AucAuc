var AucSters = artifacts.require("../contracts/AucSters.sol");

contract("AucSters", function(accounts) {
  it("sets the total supply upon deployment", function() {
    return AucSters.deployed()
      .then(function(instance) {
        tokenInstance = instance;
        return tokenInstance.totalSupply();
      })
      .then(totalSupply => {
        assert.equal(
          totalSupply.toNumber(),
          1000000,
          "sets totalSupply to 1000000"
        );
        return tokenInstance.balanceOf(accounts[0]);
      })
      .then(adminBalance => {
        assert.equal(
          adminBalance.toNumber(),
          1000000,
          "allocates the totalSupply to the admin when deployed"
        );
      });
  });
});
