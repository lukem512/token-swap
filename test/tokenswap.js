var TestToken = artifacts.require("./TestToken.sol");
var TokenSwap = artifacts.require("./TokenSwap.sol");

contract('TokenSwap', function(accounts) {
  var token;

  var buyer = accounts[0];
  var seller = accounts[1];

  var price = 10000000;
  var amount = 150;


  beforeEach(function() {
    return TestToken.new({ from: seller }).then(function(newToken) {
      token = newToken;
    });
  });

  it("seller should have tokens", function() {
    return token.INITIAL_SUPPLY.call().then(function(supply) {
      return token.balanceOf.call(seller).then(function(balance) {
        assert.equal(supply.toNumber(), balance.toNumber());
      });
    });
  });

  it("user can create new Swap", function() {
    return TokenSwap.deployed().then(function(instance) {
      ts = instance;

      return ts.create(token.address, amount, price, seller, buyer, {from: buyer});
    });
  });

  it("seller can approve TokenSwap contract", function() {
    return TokenSwap.deployed().then(function(instance) {
      ts = instance;

      return ts.create(token.address, amount, price, seller, buyer, {from: buyer});
    }).then(function() {
      return token.approve(ts.address, amount, {from: seller});
    });

    // TODO: test for Approval event
  });

  it("buyer can send Ether to TokenSwap contract", function() {
    return TokenSwap.deployed().then(function(instance) {
      ts = instance;

      return ts.create(token.address, amount, price, seller, buyer, {from: buyer});
    }).then(function() {
      return token.approve(ts.address, amount, {from: seller});
    }).then(function() {
      return ts.conclude({from: buyer, value: price});
    });
  });

  it("buyer should have correct amount of tokens", function() {
    return TokenSwap.deployed().then(function(instance) {
      ts = instance;

      return ts.create(token.address, amount, price, seller, buyer, {from: buyer});
    }).then(function() {
      return token.approve(ts.address, amount, {from: seller});
    }).then(function() {
      return ts.conclude({from: buyer, value: price});
    }).then(function() {
      return token.balanceOf.call(buyer);
    }).then(function(balance) {
      return assert.equal(amount, balance.toNumber());
    });
  });

  it("seller should have correct amount of Ether", function() {
    var oldBalance, newBalance;

    return TokenSwap.deployed().then(function(instance) {
      ts = instance;

      return ts.create(token.address, amount, price, seller, buyer, {from: buyer});
    }).then(function() {
      return token.approve(ts.address, amount, {from: seller});
    }).then(function() {
      oldBalance = web3.eth.getBalance(seller);
      return ts.conclude({from: buyer, value: price});
    }).then(function(res) {
      newBalance = web3.eth.getBalance(seller);
      return assert.equal(oldBalance.toNumber() + price, newBalance.toNumber());
    });
  });

  it("buyer should be refunded extra Ether", function() {
    var extra = 100000;
    // TODO
  });
});
