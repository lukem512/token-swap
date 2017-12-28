pragma solidity ^0.4.17;

// Test ERC20 token
// Luke Mitchell <hi@lukemitchell.co>

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract TestToken is StandardToken {
  string public constant name = "Test Token";
  string public constant symbol = "TEST";
  uint public constant decimals = 2;

  uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));

  function TestToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
