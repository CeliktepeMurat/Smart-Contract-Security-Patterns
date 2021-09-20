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

  // This is the function that will be abused by the attacker during the
  // re-entrancy attack
  function exchangeAndWithdrawToken(uint256 amount) public {
    if (tokenBalance[msg.sender] >= amount) {
      uint256 etherAmount = tokenBalance[msg.sender] * rate;
      tokenBalance[msg.sender] -= amount;
      // safe because it uses the gas-limited transfer function, which
      // does not allow further calls.
      payable(msg.sender).transfer(etherAmount);
    }
  }

  // Function vulnerable to re-entrancy attack
  function withdrawAll() public {
    uint256 etherAmount = etherBalance[msg.sender];
    uint256 tokenAmount = tokenBalance[msg.sender];
    if (etherAmount > 0 && tokenAmount > 0) {
      uint256 e = etherAmount + (tokenAmount * rate);

      // This state update acts as a re-entrancy guard into this function.
      etherBalance[msg.sender] = 0;

      // external call. The attacker cannot re-enter withdrawAll, since
      // etherBalance[msg.sender] is already 0.
      msg.sender.call{ value: e };

      // problematic state update, after the external call.
      tokenBalance[msg.sender] = 0;
    }
  }
}
