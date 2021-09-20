## Cross Function Re-Entrancy

The Token contract in the example is vulnerable to a re-entrancy attack starting with the withdrawAll function. However, the attacker cannot re-enter the withdrawAll. Instead the attacker has to re-enter the contract at the exchangeAndWithdrawToken to exploit the bug and drain the vulnerable contract from ether.
