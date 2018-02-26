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

  function addAdmin() onlyController public {
    require(_addr != address(0));
    require(admin[_addr] == !_value);
    admin[_addr] = _value;
  }
```



2) Add Certified Agent By Admin

3) Confirmation By Certified Agent




1.2.3 Cancel Function with Refund
1.2.4 Common Information of Real Estate


#### 1.3. Exceptional Case

1) 

#### 1.4. Block Test Case




 
