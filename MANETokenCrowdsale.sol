pragma solidity ^0.4.11;

import 'zeppelin/contracts/token/StandardToken.sol';
import 'zeppelin/contracts/math/SafeMath.sol';
import 'zeppelin/contracts/ownership/Ownable.sol';

contract MANETokenCrowdsale is Ownable {
  using SafeMath for uint256;

  // The token being sold
  StandardToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public endTime;

  // address where funds are collected
  address public wallet;
  address public tokenPoolAddress;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function MANETokenCrowdsale(
    uint256 _endTime,
    uint256 _rate,
    address _wallet,
    address tokenAddress,
    address _tokenHolder
  ) Ownable() {
    require(_endTime > 0);
    require(_rate > 0);
    require(_wallet != 0x0);
    require(_tokenHolder != 0x0);

    token = StandardToken(tokenAddress);
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
    tokenPoolAddress = _tokenHolder;
  }

  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender);
  }

  function updateRate(uint256 _rate) onlyOwner external returns (bool) {
    require(_rate > 0);
    rate = _rate;
    return true;
  }

  function updateWallet(address _wallet) onlyOwner external returns (bool) {
    require(_wallet != 0x0);
    wallet = _wallet;

    return true;
  }

  function updateTokenAddress(address _tokenAddress) onlyOwner external returns (bool) {
    require(_tokenAddress != 0x0);
    token = StandardToken(_tokenAddress);

    return true;
  }

  function updateTokenPoolAddress(address _tokenHolder) onlyOwner external returns (bool) {
    require(_tokenHolder != 0x0);
    tokenPoolAddress = _tokenHolder;
    return true;
  }

  function updateEndTime(uint256 _endTime) onlyOwner external returns (bool){
    endTime = _endTime;
    return true;
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable returns (bool){
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.transferFrom(tokenPoolAddress, beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();

    return true;
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool nonZeroPurchase = msg.value != 0;
    return !hasEnded() && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
}
