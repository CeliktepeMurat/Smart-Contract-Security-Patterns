// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import './Bank.sol';

abstract contract SubContractCallback {
  function registerSubContract(address payable what) public payable virtual;
}

contract SubContract {
  // this contract just holds the funds until the owner comes along and
  // withdraws them.

  address owner;
  Bank bank;
  uint256 amount;

  constructor(
    Bank _bank,
    address _owner,
    uint256 _amount
  ) {
    // for solidity 0.4.21
    /*function Intermediary(Bank _bank, address _owner, uint _amount) public {*/
    owner = _owner;
    bank = _bank;
    amount = _amount;

    // this contract wants to register itself with its new owner, so it
    // calls the new owner (i.e. the attacker). This passes control to an
    // untrusted third-party contract.
    SubContractCallback(_owner).registerSubContract(payable(address(this)));
  }

  function withdraw() public {
    if (msg.sender == owner) {
      payable(msg.sender).transfer(amount);
    }
  }

  receive() external payable {}
}
