// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface SafeSender {
  function send(address, uint256) external;
}

library SafeSending {
  function send(address to, uint256 amount) public pure {
    // external call, control goes back to attacker
    to.call{ value: amount };
  }
}

contract Bank {
  using SafeSending for SafeSender;
  mapping(address => uint256) public balances;
  address owner;
  SafeSender sender;

  constructor(SafeSender _safesender) {
    /*function Bank(SafeSending _safesender) public {*/
    owner = msg.sender;
    sender = _safesender;
  }

  function getBalance(address who) public view returns (uint256) {
    return balances[who];
  }

  function donate(address to) public payable {
    balances[to] += msg.value;
  }

  function withdraw(uint256 amount) public {
    if (balances[msg.sender] >= amount) {
      // instead of using send, transfer or call here, transfer is passed
      // to the library contract, which handles sending Ether.
      _libsend(msg.sender, amount);
      // state update after the DELEGATECALL
      balances[msg.sender] -= amount;
    }
  }

  /*struct s { bytes4 sig; address to; uint256 amount; }*/
  function _libsend(address to, uint256 amount) internal {
    // call send function of the Library contract with DELEGATECALL
    (bool success, ) = address(sender).delegatecall(
      abi.encodeWithSignature('send(address,uint256)', to, amount)
    );
    require(success);
  }
}
