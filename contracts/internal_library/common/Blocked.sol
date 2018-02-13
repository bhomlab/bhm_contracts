pragma solidity ^0.4.18;

contract Blocked {
  mapping (address => bool) blocked;

  event Blocked(address _addr);
  event Unblocked(address _addr);

  function blockAddress(address _addr) public {
    require(!blocked[_addr]);
    blocked[_addr] = true;

    Blocked(_addr);
  }

  function unblockAddress(address _addr) public {
    require(blocked[_addr]);
    blocked[_addr] = false;

    Unblocked(_addr);
  }
}
