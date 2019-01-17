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
      });
  });
});
