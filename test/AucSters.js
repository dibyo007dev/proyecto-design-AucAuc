var AucSters = artifacts.require("../contracts/AucSters.sol");

contract("AucSters", function(accounts) {
  it("initializes the name symbol and standard", () => {
    return AucSters.deployed()
      .then(instance => {
        tokenInstance = instance;
        return tokenInstance.name();
      })
      .then(name => {
        assert.equal(name, "AucSters", "Sets name correctly");
        return tokenInstance.symbol();
      })
      .then(symbol => {
        assert.equal(symbol, "ASS", "Sets the symbol to ASS");
        return tokenInstance.standard();
      })
      .then(standard => {
        assert.equal(standard, "AucSters v0.1", "Standards set correctly");
      });
  });

  it("allocates the total supply upon deployment", function() {
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

  it("transfers the ownership of token", () => {
    return AucSters.deployed()
      .then(instance => {
        tokenInstance = instance;
        return tokenInstance.transfer.call(accounts[1], 9999999999999);
      })
      .then(assert.fail)
      .catch(err => {
        //console.log(err);
        assert(
          err.message.indexOf("revert") >= 0,
          "error msg must contain revert"
        );
        return tokenInstance.transfer.call(accounts[1], 250000, {
          from: accounts[0]
        });
      })
      .then(success => {
        assert.equal(success, true, "trasfer function returns true");

        return tokenInstance.transfer(accounts[1], 250000, {
          from: accounts[0]
        });
      })
      .then(reciept => {
        //console.log(reciept);
        assert.equal(reciept.logs.length, 1, "only one event must trigger");
        assert.equal(
          reciept.logs[0].event,
          "Transfer",
          "Transfer event must trigger"
        );
        assert.equal(
          reciept.logs[0].args._from,
          accounts[0],
          "debited from account[0]"
        );
        assert.equal(
          reciept.logs[0].args._to,
          accounts[1],
          "Added to recipients address"
        );
        assert.equal(
          reciept.logs[0].args._value,
          250000,
          "debited from account[0]"
        );

        return tokenInstance.balanceOf(accounts[1]);
      })
      .then(balance => {
        assert.equal(
          balance.toNumber(),
          250000,
          "adds the amount to the recipients account"
        );
        return tokenInstance.balanceOf(accounts[0]);
      })
      .then(balance => {
        assert.equal(
          balance.toNumber(),
          750000,
          "balance remaining should be checked"
        );
      });
  });
});
