pragma solidity ^0.4.18;

import './external_library/minime/MiniMeToken.sol';

contract BHM is MiniMeToken {

////////////////
// Functions for Block
////////////////  
  
  mapping (address => bool) blocked;

  event Blocked(address _addr);
  event Unblocked(address _addr);
  
  function blockAddress(address _addr) public onlyController {
    require(!blocked[_addr]);
    blocked[_addr] = true;

    Blocked(_addr);
  }

  function unblockAddress(address _addr) public onlyController {
    require(blocked[_addr]);
    blocked[_addr] = false;

    Unblocked(_addr);
  }
  
  struct AuctionStruct {
  	address[] auctionAddr;  		
  }
  
  mapping (address => AuctionStruct) AuctionStructs;

  mapping (address => bool) public admin;

  modifier onlyNotBlocked(address _addr) {
    require(!blocked[_addr]);
    _;
  }
  
  modifier onlyAdmin() {
    require(admin[msg.sender]);
    _;
  }

  function BHM(address _tokenFactory) MiniMeToken(
    _tokenFactory,
    0x0,                  // parent token
    0,                    // snapshot block number from parent
    "BHOM",        // Token name
    18,                   // Decimals
    "BHM",                // Symbol
    true                 // Enable transfers
  ) public {}

  function transfer(address _to, uint256 _amount) public onlyNotBlocked(msg.sender) returns (bool success) {
    return super.transfer(_to, _amount);
  }

  function transferFrom(address _from, address _to, uint256 _amount) public onlyNotBlocked(_from) returns (bool success) {
    return super.transferFrom(_from, _to, _amount);
  }

  function generateTokens(address _owner, uint _amount) public onlyController  returns (bool) {
    return super.generateTokens(_owner, _amount);
  }

  function destroyTokens(address _owner, uint _amount) public onlyController  returns (bool) {
    return super.destroyTokens(_owner, _amount);
  }

  function blockAddress(address _addr) public onlyController {
    super.blockAddress(_addr);
  }

  function unblockAddress(address _addr) public onlyController {
    super.unblockAddress(_addr);
  }
  
  function enableTransfers(bool _transfersEnabled) public onlyController {
    super.enableTransfers(_transfersEnabled);
  }

  function generateTokensByList(address[] _owners, uint[] _amounts) public onlyController  returns (bool) {
    require(_owners.length == _amounts.length);

    for(uint i = 0; i < _owners.length; ++i) {
      generateTokens(_owners[i], _amounts[i]);
    }

    return true;
  }

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
  
  function createAuction(uint _biddingTime, string _owner, string _estateAddress, string _registrationNumber) public {
    //TODO add new information
  	AuctionStructs[msg.sender].auctionAddr.push(new Auction(_biddingTime, msg.sender, _estateAddress, _registrationNumber));
  	
  	//event �޾Ƽ� ó���ؾ� �Ѵ�
  }
  
  function saveToDeposit(){
  
  }
  
  function withdrawByClaimer() public {

  }
  
  function withdrawByOwner() onlyOwner public {
  	require(state != State.Active);
  	uint256 balance = deposit.balance;
    owner.transfer(balance);  
  }

  
  
}
