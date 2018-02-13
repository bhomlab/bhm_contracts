pragma solidity ^0.4.18;

import './external_library/minime/MiniMeToken.sol';
import './internal_library/common/Blocked.sol';


contract BHM is MiniMeToken, Blocked {
  bool public sudoEnabled = true;
  
  mapping (address => bool) public admin;

  modifier onlySudoEnabled() {
    require(sudoEnabled);
    _;
  }

  modifier onlyNotBlocked(address _addr) {
    require(!blocked[_addr]);
    _;
  }
  
  modifier onlyAdmin() {
    require(admin[msg.sender]);
    _;
  }

  event SudoEnabled(bool _sudoEnabled);

  function BHM(address _tokenFactory) MiniMeToken(
    _tokenFactory,
    0x0,                  // no parent token
    0,                    // no snapshot block number from parent
    "BHOM",        // Token name
    18,                   // Decimals
    "BHM",                // Symbol
    true                 // Enable transfers
  ) public {}

  /*For token control*/
  function transfer(address _to, uint256 _amount) public onlyNotBlocked(msg.sender) returns (bool success) {
    return super.transfer(_to, _amount);
  }

  function transferFrom(address _from, address _to, uint256 _amount) public onlyNotBlocked(_from) returns (bool success) {
    return super.transferFrom(_from, _to, _amount);
  }

  function generateTokens(address _owner, uint _amount) public onlyController onlySudoEnabled returns (bool) {
    return super.generateTokens(_owner, _amount);
  }

  function destroyTokens(address _owner, uint _amount) public onlyController onlySudoEnabled returns (bool) {
    return super.destroyTokens(_owner, _amount);
  }

  function blockAddress(address _addr) public onlyController onlySudoEnabled {
    super.blockAddress(_addr);
  }

  function unblockAddress(address _addr) public onlyController onlySudoEnabled {
    super.unblockAddress(_addr);
  }

  function enableSudo(bool _sudoEnabled) public onlyController {
    sudoEnabled = _sudoEnabled;
    SudoEnabled(_sudoEnabled);
  }
  
  function enableTransfers(bool _transfersEnabled) public onlyController {
    super.enableTransfers(_transfersEnabled);
  }

  function generateTokensByList(address[] _owners, uint[] _amounts) public onlyController onlySudoEnabled returns (bool) {
    require(_owners.length == _amounts.length);

    for(uint i = 0; i < _owners.length; i++) {
      generateTokens(_owners[i], _amounts[i]);
    }

    return true;
  }
  
  /**
   * @dev set new admin as admin of KYC contract
   * @param _addr address The address to set as admin of KYC contract
   */
  function setAdmin(address _addr, bool _value)
    public
    onlyController
    returns (bool)
  {
    require(_addr != address(0));
    require(admin[_addr] == !_value);

    admin[_addr] = _value;

    SetAdmin(_addr);

    return true;
  }
  
  
}
