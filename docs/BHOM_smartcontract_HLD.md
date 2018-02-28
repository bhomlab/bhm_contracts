### BHOM SMART CONTRACT HIGH LEVEL DESIGN DOCUMENT

### FEATURE LIST

1) BHOM.FR.SMARTCONTRACT.COMMON
2) BHOM.FR.SMARTCONTRACT.AUCTION
3) BHOM.FR.SMARTCONTRACT.LEASE
4) BHOM.FR.SMARTCONTRACT.TRADE
5) BHOM.FR.SMARTCONTRACT.SALE
6) BHOM.FR.SMARTCONTRACT.MIGRATION

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

Deposit is one of the most important part of this smart contract. Only owner of deposit can withdraw token from vault. Deposit has these functions such as,

1) Safe withdraw by owner

```bash
  function withdraw() onlyOwner public {
  	require(state != State.Active);
  	uint256 balance = deposit.balance;
    owner.transfer(balance);  
  }
```

//TODO
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


#### 1.3. Exceptional Case

1) Invalid initial value
2) Smaller amount of deposit than price
3) 

#### 1.4. Block Test Case


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

//TODO ���� �ÿ� BHM ��Ʈ�� �ּҸ� ����ϰ� �ű⼭ CA���� Ȯ���Ѵ�?
Transaction smart contract created by owner. Owner is 'Who want to sell real estate'. When initiating, BHM Token contract address must be saved in transaction smart contract.

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

BHM�� deposit�� ���� ����...
minime token�� lock unlock�� �־�� �ҵ�?
��ġ�� ���θ� ������ �ؼ� ��Ʈ���� �־�ΰ� ������ �ϸ� �ɵ�?

//TODO
��Ʈ�ѷ��� �Ѱܾ� �� ���� �ִ�.
Highest bidder�� ��Ÿ���� withdraw�� ����������.




### 6 
```bash
  function addCertifiedAgent(address _addr, bool _value) onlyAdmin public {
    require(_addr != address(0));
    require(admin[_addr] == !_value);
    certifiedAgent[_addr] = _value;
  }
```

 
