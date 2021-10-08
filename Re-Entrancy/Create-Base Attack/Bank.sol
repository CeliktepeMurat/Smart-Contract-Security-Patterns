// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import './SubContract.sol';

contract Bank {
  mapping(address => uint256) balances;
  mapping(address => SubContract) subs;

  function getBalance(address _address) public view returns (uint256) {
    return balances[_address];
  }

  function withdraw(uint256 _amount) public {
    if (balances[msg.sender] >= _amount) {
      // The new keyword creates a new contract (in this case of type
      // subContract). This is implemented on the EVM level with the CREATE
      // instruction. CREATE immediately runs the constructor of the
      // contract. i.e this must be seen as an external call to another
      // contract.
      // Even though the contract can be considered "trusted", it can
      // perform further problematic actions (e.g. more external calls)
      subs[msg.sender] = new SubContract(this, msg.sender, _amount);
      // state update **after** the CREATE
      balances[msg.sender] -= _amount;
      payable(address(subs[msg.sender])).transfer(_amount);
    }
  }

  function deposit() public payable {
    balances[msg.sender] += msg.value;
  }
}
