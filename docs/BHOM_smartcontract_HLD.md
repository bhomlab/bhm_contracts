### BHOM SMART CONTRACT HIGH LEVEL DESIGN DOCUMENT

### FEATURE LIST

1) BHOM.FR.SMARTCONTRACT.COMMON
2) BHOM.FR.SMARTCONTRACT.AUCTION
3) BHOM.FR.SMARTCONTRACT.LEASE
4) BHOM.FR.SMARTCONTRACT.SALE
5) BHOM.FR.SMARTCONTRACT.MIGRATION
6) BHOM.FR.SMARTCONTRACT.REGISTERWALLET

### 0. ABSTRACT

### 1. BHOM.FR.SMARTCONTRACT.COMMON

This is common function for BHOM smart contract.

#### 1.1. Requirement

1) Smart contract must have a deposit.
2) Smart contract must have a user level policy.
3) Smart contract must have a cancel/refund function.
4) Smart contract must offer optional confirmation of certified agent.
5) Smart contract offer registration function.
6) Smart contract does not exceed gas limit.

#### 1.2. function description

1.2.1 Deposit

Deposit is one of the most important part of this smart contract. Only authorized person of deposit can withdraw tokens. Deposit has these functions such as,

1) Safe withdraw by owner

```bash
	function withdrawDeposit (address _from, address _to, uint _amount) internal {
		if (_amount == 0) {
             WithdrawDeposit(_from, _to, _amount);
             return;
        }

        var previousDepositValueFrom = depositBalanceOfAt(_from, block.number);
        var previousClaimerValue = claimerBalanceAt(_from, block.number, _to);
        var previousBalanceTo = balanceOfAt(_to, block.number);
        var previousBalanceFrom = balanceOfAt(_from, block.number);

        require(previousDepositValueFrom >= _amount);
        require(previousClaimerValue >= _amount);

        updateDepositValueAtNow(balances[_from], previousDepositValueFrom - _amount, previousClaimerValue - _amount, _to);
		  updateValueAtNow(balances[_to], previousBalanceTo + _amount);
        WithdrawDeposit(_from, _to, _amount);
	}
```


2) Safe withdraw by claimer

```bash
  function withdrawByClaimer() public {
  	require(state != State.Active);
  	require();
  	uint256 balance = deposit.balance;
    claimer.transfer(balance);  
  }
```

3)

1.2.2 User Level Policy

As level of user, only user who has authority can do specific action.

1) Add Admin By Controller

```bash
  modifier onlyController {
   require(msg.sender == controller);
    _;
  }

  function addAdmin(address _addr, bool _value) onlyController public {
    require(_addr != address(0));
    require(admin[_addr] == !_value);
    admin[_addr] = _value;
  }
```



2) Add Certified Agent By Admin

```bash
  mapping (address => bool) public certifiedAgent;

  modifier onlyAdmin() {
    require(admin[msg.sender]);
    _;
  }

  function addCertifiedAgent(address _addr, bool _value) onlyAdmin public {
    require(_addr != address(0));
    require(admin[_addr] == !_value);
    certifiedAgent[_addr] = _value;
  }
```

3) Confirmation By Certified Agent

```bash
  modifier onlyCertifiedAgent {
   require(certifiedAgent[msg.sender]);
    _;
  }

  function confirmByCA(address _contractAddress, address _owner) onlyCertifiedAgent public {
    require(_addr != address(0));
    AuctionStructs[_owner]._contractAddress.auctionEnd();
  }
```

1.2.3 Cancel Function with Refund

Cancellation can be done before transaction finished. If transaction cancelled, owner of deposit can withdraw from vault.


1.2.4 Common Information of Real Estate

Common information of real estate have to be saved in smart contract. But which information will be saved is important point. Block is small, gas is expensive. Smart contract cannot contain everything. It will contains essential informations like

1) Owner
2) Registration number
3) Price
4) Type of transaction

1.2.5 Registration

Unless traditional registration system is replaced by blockchain,

1.2.6 Effective Gas Usage

Put data into permanent storage is quite expensive. If possible, we have to avoid using permanent storage.

```bash
  function addCertifiedAgent(address _addr, bool _value) onlyAdmin public {
    require(_addr != address(0));
    require(admin[_addr] == !_value);
    certifiedAgent[_addr] = _value;
  }
```




#### 1.3. Exceptional Case

1) Invalid initial value
2) Smaller amount of deposit than price
3) Fork of the token

#### 1.4. Block Test Case
1. Set invalid initial value
2. Check already registered

### 2. BHOM.FR.SMARTCONTRACT.AUCTION

#### 2.1. Requirement

1) Smart contract must have a deposit for auction.
2) Smart contract created by owner.
3) Highest bidder will be winner of the auction.
4) Bidding will be done by BHM.

#### 2.2. function description

2.2.1 Deposit

See 1.2.1

2.2.2 Creation

Transaction created by owner. Owner is 'Who want to sell real estate'.

```bash
  function Auction(uint _biddingTime, address _beneficiary ) public {
    tokenAddress = msg.sender;
    beneficiary = _beneficiary;
    auctionEnd = _biddingTime;
  }
```

2.2.3 Winner

Highest bidder will be winner of the auction. When bidding, token saved in deposit. If highest bidder appear, other bidders can withdraw their tokens.

```bash    
  function auctionEnd() public {     
     require(now >= auctionEnd);
     require(!ended);
     ended = true;
     AuctionEnded(highestBidder, highestBid);
     beneficiary.transfer(highestBid);
  }
```

2.2.4 Bidding by BHM



#### 2.3. Exceptional Case

1) Invalid initial value
2) Smaller amount of deposit than price
3)

#### 2.4. Block Test Case
1) Set invalid initial value
2) Check auction already registered
3) Check if Auction end time is registered more than making auction time  
4) Current time exactly must be over auction end time
5) Check if BHM amount of beneficiary is more than auction lowest price
6) Check making auction
7) Check period of auction is available bid
8) Check auction end time is later than the current time (auction creating time)  
9) Anyone can participate in the auction (Blocked Address X)
10) Check if bidding time isn't over the auction end time
11) Check if token amount of bidder more than auction lowest price
12) If bidder is over pay more than existing highest bidder, Bidder becomes highest bidder
13) If bidder is over pay more than existing highest bidder, bid is highest bid
14) Invalid bid event
15) Check if BHM amount of beneficiary more than agent fee
16) Check agent fee is transfered
17) Check event escro
18) Check if Auction end time is over current time
19) Check exact highest bidder
20) Check exact highest bid
21) Transfer highest bid
22) After transfer highest bid, auction must be end
23) Auction end

### 3. BHOM.FR.SMARTCONTRACT.LEASE

#### 3.1. Requirement

1) Smart contract must have a deposit for lease.
2) Smart contract created by owner.
3) Smart contract offer periodical payment function.

#### 3.2. function description

3.2.1 Deposit

See 1.2.1

3.2.2 Creation

Transaction created by owner. Lease can be done simple contract. It does not need double confirm.

```bash
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

```

3.2.3 Payment

Every period, owner get right for each payment.  

```bash
  uint8[] periodTimeStamp;
  uint8 lastTimeStamp;
  uint256 paymentAmount;

  mapping (address => Period) public periods;

  function addPayment(uint8 _paymentTimeStamp, uint256 _amount) public onlyOwner {
    periodTimeStamp.push(_paymentTimeStamp);
    paymentAmount = _amount;
  }
```

#### 3.3. Exceptional Case

1) Invalid initial value

#### 3.4. Block Test Case

1) Set invalid initial value
2) Check every period of lease is paid
3) Check lease already registered
4) Check payment time stamp
5) Check create lease    
6) Anyone can make lease (Blocked Address X)
7) Check if amount is deposit plus lease fee
8) Check if BHM amount of renter more than agent fee  
9) Check setDeposit
10) Check transfer deposit
11) Check exact renter
12) Check if BHM amount of renter more than agent fee
13) Check if payment time is less than current time and renter have not paid (withdrawLeaseFee)
14) Withdraws BHM(lease fee) at renter account
15) Check renter address
16) Check if payment time is less than current time and renter have paid (withdrawPreDeposit)
17) Lease end

### 4. BHOM.FR.SMARTCONTRACT.SALE

#### 4.1. Requirement

1) Smart contract must have a deposit for sale.
2) Smart contract created by owner.
3) Smart contract offer double confirm function.
4) Smart contract have a event for register.

#### 4.2. function description

4.2.1 Deposit

See 1.2.1

4.2.2 Creation

Transaction created by owner.

4.2.3 Double Confirm

4.2.4 Event for Register

#### 4.3. Exceptional Case

1) Invalid initial value

#### 4.4. Block Test Case
1) Set invalid initial value
2) Check sale already registered
3) Anyone can make sale (Blocked Address X)
4) Check create sale
5) Anyone can apply sale (Blocked Address X)  
6) Check apply sale already registered
7) Check if BHM amount of buyer is more than sale deposit
8) Check set deposit
9)  Check exact buyer
10) Invalid apply event
11) CA exactly confirms invalid value  
12) Check agent fee is transfered
13) Confirms sale trade
14) Sale end

### 5. BHOM.FR.SMARTCONTRACT.MIGRATION

#### 5.1. Requirement

1) Smart contract must have a data for migration.

#### 5.2. function description

5.2.1 Migration

Every fork, all data can be accessed by next token. Using minime token, we can access previous data. And also unimportant data will be saved at traditional database. Checkpoint is struct for saving data(especially tokens). We also need similar struct for saving contract data.

```bash
    struct  Checkpoint {
        uint128 fromBlock;
        uint128 value;
        uint128 deposit;
        mapping (address => uint128) claimerValue;
    }    
    struct CheckpointForContract {


	}    
```

#### 5.3. Exceptional Case

1) Invalid initial value

#### 5.4. Block Test Case

1) Set invalid initial value

### 5. BHOM.FR.SMARTCONTRACT.MIGRATION

#### 5.1. Requirement

1) Smart contract must have a data for migration.

#### 5.2. function description

5.2.1 Migration

Every fork, all data can be accessed by next token. Using minime token, we can access previous data. And also unimportant data will be saved at traditional database. Checkpoint is struct for saving data(especially tokens). We also need similar struct for saving contract data.

```bash
    struct  Checkpoint {
        uint128 fromBlock;
        uint128 value;
        uint128 deposit;
        mapping (address => uint128) claimerValue;
    }    
    struct CheckpointForContract {


	}    
```

#### 5.3. Exceptional Case

1) Invalid initial value

#### 5.4. Block Test Case

1) Set invalid initial value





### 6. BHOM.FR.SMARTCONTRACT.REGISTERWALLET

#### 6.1. Requirement

1) Smart contract offer register function for BHM platform. By calling function smart contract, we can match user ID and user address. By matching we can easily offer information out side of blockchain.

#### 6.2. function description

6.2.1

For matching User ID and Ethereum address, we need a function for identification. Like register email.

```bash
  mapping (address => string) email;

  event RegisterEmail(address _addr, string _email);

  function registerEmail(string _email) public {
    email[msg.sender] = _email;

    RegisterEmail(msg.sender, _email);
  }
```

#### 6.3. Exceptional Case

1) Invalid initial value
2) check already registered

#### 6.4. Block Test Case

1) Set invalid initial value
