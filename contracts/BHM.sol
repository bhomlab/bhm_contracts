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
  
  modifier onlyNotBlocked(address _addr) {
    require(!blocked[_addr]);
    _;
  }
  
  
  struct AuctionStruct {
  	address[] auctionAddr;  		
  }
  
  mapping (address => AuctionStruct) AuctionStructs;

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

////////////////
// Functions for User Level Policy
////////////////  

  mapping (address => bool) public admin;
  
  modifier onlyAdmin() {
    require(admin[msg.sender]);
    _;
  }
 
  mapping (address => bool) public certifiedAgent;

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
  
  function addCertifiedAgent(address _addr, bool _value) onlyAdmin public {
    require(_addr != address(0));
    require(admin[_addr] == !_value);
    certifiedAgent[_addr] = _value;
  }
  
  
  function createAuction(uint _biddingTime, string _owner, string _estateAddress, string _registrationNumber) public {
    //TODO add new information
  	AuctionStructs[msg.sender].auctionAddr.push(new Auction(_biddingTime, msg.sender, _estateAddress, _registrationNumber));
  	
  	//event 받아서 처리해야 한다
  }
  
////////////////
// Functions for Lease
////////////////    
//TODO 계약만 스마트 컨트랙으로 하도록 바꿀까?

  struct LeaseStruct {
    uint256 deposit;
  	uint256 leaseFee;
  	uint256[] paymentTimestamp;
  	address rent;
  	address confirmedCA;
  	address doubleConfirmedCA;
  	bool isUsed;
    bool lock;
    bool isConfirmed;
  }
  //KEY IS LEASETIMESTAMP == NOW
  mapping (address => mapping(uint256 => LeaseStructs)) leaseStructs;
  

  //1. create lease
  //1.1 set condition
  
  //use CA
  //real estate information
  //CA fee
  //check 128 or 256
  function createLease(uint256 _deposit, uint256 _leaseFee, bool _useCA, uint256[] _paymentTimestamp) public returns (uint256){
  	
  	//check condition
  	
  	//unique key owner x timestamp, default value of mapping is 0
  	require(leaseStructs[msg.sender][now].isUsed == false);
  	leaseStructs[msg.sender][now].deposit = _deposit;
  	leaseStructs[msg.sender][now].leaseFee = _leaseFee;
  	leaseStructs[msg.sender][now].isUsed = true;
  	leaseStructs[msg.sender][now].lock = false;
  	//TODO check length
  	for(uint i = 0; i < _paymentTimestamp.length; ++i){
  		leaseStructs[msg.sender][now].paymentTimestamp.push(_paymentTimestamp[i]);
  	}
  	
  	CreateLease(_deposit, _leaseFee, _useCA, _paymentTimestamp, now, msg.sender);
  }
  
  //2. apply lease
 
  //TODO
  function applyLease(address _to, uint256 _keyTimeStamp) public {
  	//check lock
  	require(leaseStructs[_to][keyTimeStamp].lock == false);
  	//set deposit for owner
  	//check uint128
  	uint _amount = leaseStructs[_to][_keyTimeStamp].deposit + (leaseStructs[_to][_keyTimeStamp].leaseFee * (leaseStructs[_to][_keyTimeStamp].paymentTimestamp.length + 1));
  	
  	setDeposit(msg.sender, _to, _amount);
  	
  	//set lock
  	leaseStructs[_to][_keyTimeStamp].lock = true;
  	leaseStructs[_to][_keyTimeStamp].rent = msg.sender;
  	//event
  	ApplyLease(_to, _keyTimeStamp, msg.sender);
  }
  
  //3. confirm contract by CA
  //check condition
  //CA confirmed
  //CA bonus?
  //for just lease, we don't need multi check
  function confirmLeaseByCA(address _target, uint256 _keyTimeStamp) public onlyCertifiedAgent {
  	//check it is locked
  	require(leaseStructs[_target][_keyTimeStamp].lock == true);
  	//need multi check?
    require(leaseStructs[_target][_keyTimeStamp].isConfirmed == false);
    //confirm
    leaseStructs[_target][_keyTimeStamp].isConfirmed = true;
    //fee?
    
    
  }

  
  //4. withdraw when time over
  function withdrawLeaseFee(address _target, uint256 _keyTimeStamp) public onlyCertifiedAgent {
	
    
    
  }
  
  
  //5. withdraw pre-deposit
  
  //6. cancel lease before confirm
  
  
  
  event CreateLease(uint256 _deposit, uint256 _leaseFee, bool _useCA, uint256[] _paymentTimestamp, uint256 currentTimestamp, address leaseOwner );
  event ApplyLease(address _to, uint256 _keyTimeStamp, address rent);
  
  
////////////////
// Functions for Deposit
////////////////  
  //TODO
  
  
  function withdrawByClaimer() public {

  }
  
  function withdrawByOwner() onlyOwner public {
  	require(state != State.Active);
  	uint256 balance = deposit.balance;
    owner.transfer(balance);  
  }

  
  
}
