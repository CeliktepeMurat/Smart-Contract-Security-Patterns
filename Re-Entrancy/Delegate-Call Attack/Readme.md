## Delegate Call Re-Entrancy

The `Bank` contract utilizes a library, called via delegatecall, for performing the ether sending. This obfuscates the re-entrancy vulnerability in the withdraw function. Any static analysis tool will not be able to detect this vulnerability when analyzing only the Bank contract and not the combination of the contract and its libraries.
