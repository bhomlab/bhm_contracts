pragma solidity ^0.4.19;

contract EOS {
  mapping (address => string) ethAddressForEOS;

  event RegisterEOSAddress(address _addr, string _eosAddr);

  function eegisterEOSAddress(string _eosAddr) public {
    ethAddressForEOS[msg.sender] = _eosAddr;

    RegisterEOSAddress(msg.sender, _eosAddr);
  }

}