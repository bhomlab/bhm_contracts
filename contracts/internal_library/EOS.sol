pragma solidity ^0.4.19;

contract EOS {

  struct userEOS {
      string eosKey;
      uint eosAmount;
  }

  mapping (address => userEOS) ethAddressForEOS;
  event RegisterEOSAddress(address _addr, string _eosKey);

  function registerEOSAddress(string _eosKey) public returns (bool) {
    ethAddressForEOS[msg.sender].eosKey = _eosKey;
    RegisterEOSAddress(msg.sender , ethAddressForEOS[msg.sender].eosKey);
   	return true;
  }

}
