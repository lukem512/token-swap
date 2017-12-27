var Migrations = artifacts.require("./Migrations.sol");
var TokenSwap = artifacts.require("./TokenSwap.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(TokenSwap);
};
