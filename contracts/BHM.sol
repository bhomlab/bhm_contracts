pragma solidity ^0.4.19;

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

  modifier onlyCertifiedAgent {
   require(certifiedAgent[msg.sender]);
    _;
  }

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
    
  event SetAdmin(address _addr);
  
//  function createAuction(uint _biddingTime, string _owner, string _estateAddress, string _registrationNumber) public {
//    //TODO add new information
//  	AuctionStructs[msg.sender].auctionAddr.push(new Auction(_biddingTime, msg.sender, _estateAddress, _registrationNumber));
//  	
//  	//event 받아서 처리해야 한다
//  }
  
////////////////
// Functions for Lease
////////////////    
//TODO 계약만 스마트 컨트랙으로 하도록 바꿀까?
//TODO We have to save this in minime token
  struct LeaseStruct {
  	uint256[] paymentTimestamp;
    uint256 deposit;
  	uint256 leaseFee;
  	uint256 agentFee;
  	address rent;
  	address confirmedCA;
  	bool isUsed;
    bool lock;
    bool isConfirmed;
    bool[] isPaid;
  }
  //KEY IS LEASETIMESTAMP == NOW
  mapping (address => mapping(uint256 => LeaseStruct)) leaseStructs;
  

  //1. create lease
  //1.1 set condition
  
  //use CA
  //real estate information
  //CA fee
  //check 128 or 256
  function createLease(uint256 _deposit, uint256 _leaseFee, bool _useCA, uint256[] _paymentTimestamp, uint256 _agentFee) public returns (uint256){
  	
  	//check condition
  	var _keyTimestamp = now;
  	//unique key owner x timestamp, default value of mapping is 0
  	require(leaseStructs[msg.sender][now].isUsed == false);
  	leaseStructs[msg.sender][_keyTimestamp].deposit = _deposit;
  	leaseStructs[msg.sender][_keyTimestamp].leaseFee = _leaseFee;
  	leaseStructs[msg.sender][_keyTimestamp].isUsed = true;
  	leaseStructs[msg.sender][_keyTimestamp].lock = false;
  	leaseStructs[msg.sender][_keyTimestamp].agentFee = _agentFee;
  	//TODO check length
  	for(uint i = 0; i < _paymentTimestamp.length; ++i){
  		leaseStructs[msg.sender][_keyTimestamp].paymentTimestamp.push(_paymentTimestamp[i]);
  		leaseStructs[msg.sender][_keyTimestamp].isPaid.push(false);
  	}
  	
  	CreateLease(_deposit, _leaseFee, _useCA, _paymentTimestamp, _keyTimestamp, msg.sender);
  }
  
  //2. apply lease
 
  //TODO
  function applyLease(address _to, uint256 _keyTimeStamp) public {
  	//check lock
  	require(leaseStructs[_to][_keyTimeStamp].lock == false);
  	//set deposit for owner
  	//check uint128
  	uint _amount = leaseStructs[_to][_keyTimeStamp].deposit + (leaseStructs[_to][_keyTimeStamp].leaseFee * (leaseStructs[_to][_keyTimeStamp].paymentTimestamp.length + 1));
  	require(_amount >= balanceOfAt(msg.sender, block.number));
  	//월세를 deposit으로 잡고
  	setDeposit(msg.sender, _to, leaseStructs[_to][_keyTimeStamp].leaseFee * (leaseStructs[_to][_keyTimeStamp].paymentTimestamp.length + 1));
  	//보증금을 넣어주고
  	transferFrom(msg.sender, _to, leaseStructs[_to][_keyTimeStamp].deposit);
  	//소유주에서 빌린 사람에게로 오는 deposit으로 잡자, 빌린 사람의 잔액이 없어도 되는지 확인
  	setDeposit(_to, msg.sender, leaseStructs[_to][_keyTimeStamp].deposit);
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
    //check enough agentFee
    require(leaseStructs[_target][_keyTimeStamp].agentFee >= balanceOfAt(_target, block.number));
    //fee?
    transferFrom(_target, msg.sender, leaseStructs[_target][_keyTimeStamp].agentFee);
	//confirm
    leaseStructs[_target][_keyTimeStamp].isConfirmed = true;
    ConfirmLeaseByCA(_target, _keyTimeStamp);
  }

  
  //4. withdraw when time over
  function withdrawLeaseFee(uint256 _keyTimeStamp) public {
	//is there a faster way?
    for(uint i = 0; i < leaseStructs[msg.sender][_keyTimeStamp].paymentTimestamp.length; ++i){
    	if( (leaseStructs[msg.sender][_keyTimeStamp].paymentTimestamp[i] <= now) && (leaseStructs[msg.sender][_keyTimeStamp].isPaid[i] == false)){
    		leaseStructs[msg.sender][_keyTimeStamp].isPaid[i] = true;
    		//withdraw
    		withdrawDeposit(leaseStructs[msg.sender][_keyTimeStamp].rent, msg.sender, leaseStructs[msg.sender][_keyTimeStamp].leaseFee);
    	}
  	}
  	
  }
  
  
  //5. withdraw pre-deposit
  //소유주 -> 빌린 사람
  function withdrawPreDeposit(address _target, uint256 _keyTimeStamp) public {
  	//require ownership
	require(msg.sender == leaseStructs[_target][_keyTimeStamp].rent);
	for(uint i = 0; i < leaseStructs[_target][_keyTimeStamp].paymentTimestamp.length; ++i){
    	require((leaseStructs[_target][_keyTimeStamp].paymentTimestamp[i] <= now) && (leaseStructs[_target][_keyTimeStamp].isPaid[i] == true));
    }
	withdrawDeposit(_target, msg.sender, leaseStructs[_target][_keyTimeStamp].deposit);	
  }
  
  
  
  //6. cancel lease before confirm
  
  
  
  event CreateLease(uint256 _deposit, uint256 _leaseFee, bool _useCA, uint256[] _paymentTimestamp, uint256 currentTimestamp, address leaseOwner );
  event ApplyLease(address _to, uint256 _keyTimeStamp, address rent);
  event ConfirmLeaseByCA(address _target, uint256 _keyTimeStamp);
  
////////////////
// Functions for Sale
////////////////    
  struct SaleStruct {
    uint256 deposit;
  	uint256 agentFee;
  	address buyer;
  	address confirmedCA;
  	address doubleConfirmedCA;
  	bool isUsed;
    bool lock;
    bool isConfirmed;
    bool isDoubleConfirmed;
    bool isPaid;
  }
  
  mapping (address => mapping(uint256 => SaleStruct)) saleStructs;

  function createSale(uint256 _deposit, bool _useCA, uint256 _agentFee) public returns (uint256){
  	
  	//check condition
  	var _keyTimestamp = now;
  	//unique key owner x timestamp, default value of mapping is 0
  	require(saleStructs[msg.sender][_keyTimestamp].isUsed == false);
  	saleStructs[msg.sender][_keyTimestamp].deposit = _deposit;
  	saleStructs[msg.sender][_keyTimestamp].isUsed = true;
  	saleStructs[msg.sender][_keyTimestamp].lock = false;
  	saleStructs[msg.sender][_keyTimestamp].agentFee = _agentFee;
	  	
  	CreateSale(_deposit, _useCA,  now, msg.sender);
  }
  
  function applySale(address _to, uint256 _keyTimeStamp) public {
  	//check lock
  	require(saleStructs[_to][_keyTimeStamp].lock == false);
  	//set deposit for owner
  	require(saleStructs[_to][_keyTimeStamp].deposit >= balanceOfAt(msg.sender, block.number));
  	setDeposit(msg.sender, _to, saleStructs[_to][_keyTimeStamp].deposit);
  	//set lock
  	saleStructs[_to][_keyTimeStamp].lock = true;
  	saleStructs[_to][_keyTimeStamp].buyer = msg.sender;
  	//event
  	ApplySale(_to, _keyTimeStamp, msg.sender);
  }
  
  function confirmTradeByCA(address _target, uint256 _keyTimeStamp) public onlyCertifiedAgent {
  	//check it is locked
  	require(saleStructs[_target][_keyTimeStamp].lock == true);
  	//need multi check?
    require(saleStructs[_target][_keyTimeStamp].isConfirmed == false);
    //check enough agentFee
    require(saleStructs[_target][_keyTimeStamp].agentFee >= balanceOfAt(_target, block.number));
    //fee?
    transferFrom(_target, msg.sender, saleStructs[_target][_keyTimeStamp].agentFee);
	//confirm
    saleStructs[_target][_keyTimeStamp].isConfirmed = true;
    confirmTradeByCA(_target, _keyTimeStamp);
  }
  
  
  event CreateSale(uint256 _deposit, bool _useCA, uint256 _now, address _senderAddress);
  event ApplySale(uint256 _deposit, bool _useCA, uint256 _now, address _senderAddress);
  event confirmTradeByCA(address _target, uint256 _keyTimeStamp);
  
////////////////
// Functions for Deposit
////////////////  

  
  
}
