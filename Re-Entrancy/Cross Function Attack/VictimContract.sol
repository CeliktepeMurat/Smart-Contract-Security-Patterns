// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract VictimContract {
  /** 
    // @notice This contract keeps track of two balances for it's users.
    // @notice A user can send ether to this contract and exchange ether for tokens and vice
    // @notice versa, given a varying exchange rate (currentRate).
  */

  mapping(address => uint256) tokenBalance;
  mapping(address => uint256) etherBalance;
  uint8 rate;

  constructor() {
    rate = 2;
  }

  function depositEther() public payable {
    if (msg.value > 0) {
      etherBalance[msg.sender] += msg.value;
    }
  }

  function exchangeTokenToEther(uint256 _amount) public {
    require(tokenBalance[msg.sender] >= _amount);

    uint256 etherAmount = _amount * rate;
    etherBalance[msg.sender] += etherAmount;
    tokenBalance[msg.sender] -= _amount;
  }

  function exchangeEtherToToken(uint256 _amount) public payable {
    require(etherBalance[msg.sender] >= _amount);

    uint256 tokenAmount = _amount / rate;
    etherBalance[msg.sender] -= _amount;
    tokenBalance[msg.sender] += tokenAmount;
  }

  /**
  // @notice This is the function that will be abused by the attacker during the re-entrancy attack
   */
  function exchangeAndWithdrawToken(uint256 _amount) public {
    if (tokenBalance[msg.sender] >= _amount) {
      uint256 etherAmount = tokenBalance[msg.sender] * rate;
      tokenBalance[msg.sender] -= _amount;

      payable(msg.sender).transfer(etherAmount);
    }
  }

  // Function vulnerable to re-entrancy attack
  function withdrawAll() public {
    uint256 etherAmount = etherBalance[msg.sender];
    uint256 tokenAmount = tokenBalance[msg.sender];
    if (etherAmount > 0 && tokenAmount > 0) {
      uint256 amount = etherAmount + (tokenAmount * rate);

      // This state update acts as a re-entrancy guard into this function.
      etherBalance[msg.sender] = 0;

      /**
      // @notice external call. The attacker cannot re-enter withdrawAll, since
      // etherBalance[msg.sender] is already 0.
       */
      msg.sender.call{ value: amount };

      // problematic state update, after the external call.
      tokenBalance[msg.sender] = 0;
    }
  }

  function getTokenCount() public view returns (uint256) {
    return tokenBalance[msg.sender];
  }
}
