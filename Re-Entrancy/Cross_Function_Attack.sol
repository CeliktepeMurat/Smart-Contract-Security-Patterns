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
  uint8 currentRate;

  constructor() {
    currentRate = 2;
  }

  // This contract supports various utility functions for transferring,
  // exchanging Ether and Tokens.
  // Note that this probably makes it rather hard for symbolic execution
  // tools to execute all combinations of possible re-entry points.

  function getTokenCountFor(address x) public view returns (uint256) {
    return tokenBalance[x];
  }

  function getEtherCountFor(address x) public view returns (uint256) {
    return etherBalance[x];
  }

  function getTokenCount() public view returns (uint256) {
    return tokenBalance[msg.sender];
  }

  function depositEther() public payable {
    if (msg.value > 0) {
      etherBalance[msg.sender] += msg.value;
    }
  }

  function exchangeTokens(uint256 amount) public {
    if (tokenBalance[msg.sender] >= amount) {
      uint256 etherAmount = amount * currentRate;
      etherBalance[msg.sender] += etherAmount;
      tokenBalance[msg.sender] -= amount;
    }
  }

  function exchangeEther(uint256 amount) public payable {
    etherBalance[msg.sender] += msg.value;
    if (etherBalance[msg.sender] >= amount) {
      uint256 tokenAmount = amount / currentRate;
      etherBalance[msg.sender] -= amount;
      tokenBalance[msg.sender] += tokenAmount;
    }
  }

  function transferToken(address to, uint256 amount) public {
    if (tokenBalance[msg.sender] >= amount) {
      tokenBalance[to] += amount;
      tokenBalance[msg.sender] -= amount;
    }
  }

  // This is the function that will be abused by the attacker during the
  // re-entrancy attack
  function exchangeAndWithdrawToken(uint256 amount) public {
    if (tokenBalance[msg.sender] >= amount) {
      uint256 etherAmount = tokenBalance[msg.sender] * currentRate;
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
      uint256 e = etherAmount + (tokenAmount * currentRate);

      // This state update acts as a re-entrancy guard into this function.
      etherBalance[msg.sender] = 0;

      // external call. The attacker cannot re-enter withdrawAll, since
      // etherBalance[msg.sender] is already 0.
      msg.sender.call{value: e};

      // problematic state update, after the external call.
      tokenBalance[msg.sender] = 0;
    }
  }
}
