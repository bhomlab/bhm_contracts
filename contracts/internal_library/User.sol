pragma solidity ^0.4.19;

contract User {
  mapping (address => string) email;

  event RegisterEmail(address _addr, string _email);

  function registerEmail(string _email) public {
    email[msg.sender] = _email;

    RegisterEmail(msg.sender, _email);
  }

}
