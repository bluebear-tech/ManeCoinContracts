pragma solidity ^0.4.17;

import "../installed_contracts/zeppelin/contracts/token/StandardToken.sol";

contract MANEToken is StandardToken {

  string public name = "ManeCoin";
  string public symbol = "MANE";
  uint8 public constant decimals = 18;

  function MANEToken(address tokenHolder) {
    totalSupply = 982451653 ether;
    balances[tokenHolder] = totalSupply;
  }
}
