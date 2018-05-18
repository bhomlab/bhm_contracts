pragma solidity ^0.4.19;
import './external_library/minime/MiniMeToken.sol';
import './internal_library/User.sol';
import './internal_library/EOS.sol';


contract BHM is MiniMeToken, User, EOS{
    // //////////////
    // Functions for Block
    // //////////////
    mapping (address => bool) blocked;

    event Blocked(address _addr);

    event Unblocked(address _addr);

    function blockAddress(address _addr) public onlyController{
        require(!blocked[_addr]);
        blocked[_addr] = true;
        Blocked(_addr);
    }

    function unblockAddress(address _addr) public onlyController{
        require(blocked[_addr]);
        blocked[_addr] = false;
        Unblocked(_addr);
    }

    modifier onlyNotBlocked(address _addr){
        require(!blocked[_addr]);
        _;
    }

    function BHM(address _tokenFactory) MiniMeToken(_tokenFactory,
    	0x0,                  // parent token
    	0,                    // snapshot block number from parent
    	"BHOM",        // Token name
    	18,                   // Decimals
    	"BHM",                // Symbol
    	true // Enable transfers
    ) public{
    }

    function transfer(address _to, uint256 _amount) public onlyNotBlocked(msg.sender) returns (bool success){
        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success){
        return super.transferFrom(_from, _to, _amount);
    }

    function generateTokens(address _owner, uint _amount) public onlyController  returns (bool){
        return super.generateTokens(_owner, _amount);
    }

    function destroyTokens(address _owner, uint _amount) public onlyController  returns (bool){
        return super.destroyTokens(_owner, _amount);
    }

    function enableTransfers(bool _transfersEnabled) public onlyController{
        super.enableTransfers(_transfersEnabled);
    }

    function generateTokensByList(address[] _owners, uint[] _amounts) public onlyController returns (bool){
        require(_owners.length == _amounts.length);
        for(uint i = 0; i < _owners.length; ++i){
            generateTokens(_owners[i], _amounts[i]);
        }
        return true;
    }

    // //////////////
    // Functions for User Level Policy
    // //////////////
    modifier onlyCertifiedAgent{
        require(certifiedAgent[msg.sender]);
        _;
    }

    mapping (address => bool) public admin;

    modifier onlyAdmin(){
        require(admin[msg.sender]);
        _;
    }

    mapping (address => bool) public certifiedAgent;

    function setAdmin(address _addr, bool _value) public onlyController{
        require(_addr != address(0));
        require(admin[_addr] == !_value);
        admin[_addr] = _value;
        SetAdmin(_addr);
    }

    function addCertifiedAgent(address _addr, bool _value) public onlyAdmin{
        require(_addr != address(0));
        require(admin[_addr] == !_value);
        certifiedAgent[_addr] = _value;
        AddCertifiedAgent(_addr);
    }

    event SetAdmin(address _addr);

    event AddCertifiedAgent(address _addr);

    struct InitialPayStruct{
        uint256 deposit;
        bool isUsed;
    }

    mapping (address => mapping(uint256 => InitialPayStruct)) initialPayStructs;

    function createInitialPay(uint256 _deposit) public returns (uint256){
        var _keyTimestamp = now;
        // isUsed 시연할때는 빼고
        // require(initialPayStructs[msg.sender][_keyTimestamp].isUsed == false);
        initialPayStructs[msg.sender][_keyTimestamp].deposit = _deposit;
        // initialPayStructs[msg.sender][_keyTimestamp].isUsed = true;
        CreateInitialPay(msg.sender, initialPayStructs[msg.sender][_keyTimestamp].deposit, now);
    }

    // 즉시지불
    function initialPayment(address _to, uint256 _keyTimestamp) public returns (bool){
        // isUsed 시연할때는 빼고
        // require(initialPayStructs[_to][_keyTimestamp].isUsed == true);
        immediatelyTransfer(_to, initialPayStructs[_to][_keyTimestamp].deposit);
        InitialPayment(msg.sender, _to, initialPayStructs[_to][_keyTimestamp].deposit);
    	// initialPayStructs[_to][_keyTimestamp].isUsed == false;
    }

    function immediatelyTransfer(address _to, uint256 _amount) internal returns (bool success){
        return super.transfer(_to, _amount);
    }

    event CreateInitialPay(address _from, uint256 _deposit, uint256 _keyTimestamp);
    event InitialPayment(address _from, address _to, uint256 _amount);

    /* ////////////////
     * // Functions for Auction
     * ////////////////
     *   struct AuctionStruct {
     *     uint256 lowestprice;
     *     uint256 highestBid;
     *     uint256 bid;
     *     uint256 agentFee;
     *     uint256 auctionEndTime;
     *     address beneficiary;
     *     address highestBidder;
     *     address bidder;
     *     bool isUsed;
     *     bool lock;
     *     bool auctionEnded;
     *     bool isConfirmed;
     *   }

     *   // auctionStruts Mapping
     *   mapping (address => mapping(uint256 => AuctionStruct)) auctionStructs;

     *   // 1. create Auction , msg.sender = beneficiary
     *   // @param _lowestprice Lowestprice of Auction
     *   // @param _agentFee
     *   // @param _auctionEndTime
     *   // @Return token values
     *   function createAuction(uint256 _lowestprice, uint256 _agentFee, uint256 _auctionEndTime) public returns (uint256) {
     *     var _keyTimeStamp = now;
     *     require(auctionStructs[msg.sender][_keyTimeStamp].isUsed == false);
     *     require(auctionStructs[msg.sender][_keyTimeStamp].auctionEndTime > now);

     *     auctionStructs[msg.sender][_keyTimeStamp].lowestprice = _lowestprice;
     *     auctionStructs[msg.sender][_keyTimeStamp].agentFee = _agentFee;
     *     auctionStructs[msg.sender][_keyTimeStamp].auctionEndTime  = _auctionEndTime;
     *     auctionStructs[msg.sender][_keyTimeStamp].isUsed = true;
     *     auctionStructs[msg.sender][_keyTimeStamp].lock = false;
     *     auctionStructs[msg.sender][_keyTimeStamp].auctionEnded = false;

     *     CreateAuction(msg.sender, _lowestprice, _agentFee, _auctionEndTime);
     *   }

     *   // 2. bid Auction
     *   // @param _beneficiary
     *   // @param _keyTimeStamp
     *   // @param _bid
     *   function bidAuction(address _beneficiary, uint256 _keyTimeStamp, uint256 _bid) public {
     *     require(auctionStructs[_beneficiary][_keyTimeStamp].lock == false);
     *     require(auctionStructs[_beneficiary][_keyTimeStamp].auctionEndTime >= now);
     *     require(auctionStructs[_beneficiary][_keyTimeStamp].lowestprice <= balanceOfAt(msg.sender, block.number));
     *     require(_bid <= balanceOfAt(msg.sender, block.number));
     *     require(auctionStructs[_beneficiary][_keyTimeStamp].lowestprice < _bid);
     *     require(auctionStructs[_beneficiary][_keyTimeStamp].highestBid < _bid);
     *     setDeposit(msg.sender, _beneficiary, auctionStructs[_beneficiary][_keyTimeStamp].highestBid);

     *     auctionStructs[_beneficiary][_keyTimeStamp].lock = true;
     *     auctionStructs[_beneficiary][_keyTimeStamp].bidder = msg.sender;
     *     auctionStructs[_beneficiary][_keyTimeStamp].bid = _bid;
     *     auctionStructs[_beneficiary][_keyTimeStamp].highestBidder = auctionStructs[_beneficiary][_keyTimeStamp].bidder;
     *     auctionStructs[_beneficiary][_keyTimeStamp].highestBid = auctionStructs[_beneficiary][_keyTimeStamp].bid;

     *     BidAuction(_beneficiary, now, auctionStructs[_beneficiary][_keyTimeStamp].highestBidder,
     *       auctionStructs[_beneficiary][_keyTimeStamp].highestBid);
     *   }

     *   // 3. Escro Auction add certifiedAgent
     *   // @param _beneficiary
     *   // @param _keyTimeStamp
     *   function escroAuction(address _beneficiary, uint256 _keyTimeStamp) public onlyCertifiedAgent {
     *     require(auctionStructs[_beneficiary][_keyTimeStamp].lock == true);
     *     require(auctionStructs[_beneficiary][_keyTimeStamp].isConfirmed == false);
     *     require(auctionStructs[_beneficiary][_keyTimeStamp].agentFee <= balanceOfAt(_beneficiary, block.number));
     *     transferFrom(_beneficiary, msg.sender, auctionStructs[_beneficiary][_keyTimeStamp].agentFee);
     *     auctionStructs[_beneficiary][_keyTimeStamp].isConfirmed = true;

     *     EscroAuction(_beneficiary, _keyTimeStamp);
     *   }

     *   // 4. withDraw Aunction (End Auction)
     *   function withDrawAuction(address _beneficiary, uint256 _keyTimeStamp) public {
     *     require(auctionStructs[_beneficiary][_keyTimeStamp].auctionEndTime <= now);
     *     require(!auctionStructs[_beneficiary][_keyTimeStamp].auctionEnded);
     *     auctionStructs[_beneficiary][_keyTimeStamp].auctionEnded = true;
     *     withdrawDeposit(msg.sender, _beneficiary, auctionStructs[_beneficiary][_keyTimeStamp].highestBid);

     *     AuctionEnd(auctionStructs[_beneficiary][_keyTimeStamp].highestBidder, auctionStructs[_beneficiary][_keyTimeStamp].highestBid);
     *   }

     *   //5. Events
     *   event CreateAuction(address _beneficiary, uint256 _lowestprice, uint256 _agentFee, uint256 _auctionEndTime);
     *   event BidAuction(address _beneficiary, uint256 _keyTimeStamp, address highestBidder, uint256 _highestBid);
     *   event EscroAuction(address _target, uint256 _keyTimeStamp);
     event AuctionEnd(address _highestBidder, uint256 _highestBid);  */
    // //////////////
    // Functions for Lease
    // //////////////
    struct LeaseStruct{
        uint256[] paymentTimestamp;
        uint256 deposit;
        uint256 leaseFee;
        uint256 agentFee;
        address leaseOwner;
        address rent;
        bool isUsed;
        bool lock;
        bool isConfirmed;
        bool[] isPaid;
    }
    // KEY IS LEASETIMESTAMP == NOW
    mapping (address => mapping(uint256 => LeaseStruct)) leaseStructs;

    // 1. create lease
    // 1.1 set condition
    // use CA
    // real estate information
    // CA fee
    // check 128 or 256
    function createLease(uint256 _deposit, uint256 _leaseFee, bool _useCA, uint256[] _paymentTimestamp, uint256 _agentFee) public returns (uint256){
        // check condition
        var _keyTimeStamp = now;
        // unique key is owner x timestamp
        require(leaseStructs[msg.sender][now].isUsed == false);
        // leaseStructs[msg.sender][_keyTimeStamp].leaseOwner = msg.sender;
        leaseStructs[msg.sender][_keyTimeStamp].deposit = _deposit;
        leaseStructs[msg.sender][_keyTimeStamp].leaseFee = _leaseFee;
        leaseStructs[msg.sender][_keyTimeStamp].isUsed = true;
        leaseStructs[msg.sender][_keyTimeStamp].lock = false;
        leaseStructs[msg.sender][_keyTimeStamp].agentFee = _agentFee;
        // TODO check length add BT case
        for(uint i = 0; i < _paymentTimestamp.length; ++i){
            leaseStructs[msg.sender][_keyTimeStamp].paymentTimestamp.push(_paymentTimestamp[i]);
            leaseStructs[msg.sender][_keyTimeStamp].isPaid.push(false);
        }
        CreateLease(leaseStructs[msg.sender][_keyTimeStamp].deposit, leaseStructs[msg.sender][_keyTimeStamp].leaseFee,
     	leaseStructs[msg.sender][_keyTimeStamp].agentFee,
        leaseStructs[msg.sender][_keyTimeStamp].isUsed, _paymentTimestamp, _keyTimeStamp, msg.sender);
    }

    // 2. apply lease
    function applyLease(address _to, uint256 _keyTimeStamp) public{
        require(leaseStructs[_to][_keyTimeStamp].isUsed == true);
        // check lock
        require(leaseStructs[_to][_keyTimeStamp].lock == false);
        // set deposit for owner
        // check uint128
        uint amount = leaseStructs[_to][_keyTimeStamp].deposit + (leaseStructs[_to][_keyTimeStamp].leaseFee * leaseStructs[_to][_keyTimeStamp].paymentTimestamp.length);
        require(amount <= balanceOf(msg.sender));
        transfer(_to, leaseStructs[_to][_keyTimeStamp].deposit);
        setDeposit(msg.sender, _to, leaseStructs[_to][_keyTimeStamp].leaseFee * leaseStructs[_to][_keyTimeStamp].paymentTimestamp.length);
        setDeposit(_to, msg.sender, leaseStructs[_to][_keyTimeStamp].deposit);
        leaseStructs[_to][_keyTimeStamp].rent = msg.sender;
        leaseStructs[_to][_keyTimeStamp].lock = true;
        // event
        ApplyLease(_to, _keyTimeStamp, leaseStructs[_to][_keyTimeStamp].rent,
        leaseStructs[_to][_keyTimeStamp].deposit, leaseStructs[_to][_keyTimeStamp].leaseFee * leaseStructs[_to][_keyTimeStamp].paymentTimestamp.length);
    }

    // 3. confirm contract by CA
    // check condition
    // CA confirmed
    // for just lease, we don't need multi check
    function confirmLeaseByCA(address _target, uint256 _keyTimeStamp) public onlyCertifiedAgent{
        // check it is locked
        require(leaseStructs[_target][_keyTimeStamp].lock == true);
        require(leaseStructs[_target][_keyTimeStamp].isConfirmed == false);
        // check enough agentFee
        require(leaseStructs[_target][_keyTimeStamp].agentFee <= balanceOf(_target));
        // fee?
        setDeposit(_target, msg.sender, leaseStructs[_target][_keyTimeStamp].agentFee);
        withdrawDeposit(_target, msg.sender, leaseStructs[_target][_keyTimeStamp].agentFee);
        // confirm
        leaseStructs[_target][_keyTimeStamp].isConfirmed = true;
        ConfirmLeaseByCA(_target, _keyTimeStamp);
    }

    // 4. withdraw when time over
    function withdrawLeaseFee(address _target, uint256 _keyTimeStamp) public{
        // is there a faster way?
        for(uint i = 0; i < leaseStructs[msg.sender][_keyTimeStamp].paymentTimestamp.length; ++i){
            if((leaseStructs[msg.sender][_keyTimeStamp].paymentTimestamp[i] <= now) && (leaseStructs[msg.sender][_keyTimeStamp].isPaid[i] == false)){
                leaseStructs[msg.sender][_keyTimeStamp].isPaid[i] = true;
                // 1가 2에게서 가져감
                withdrawDeposit(_target, msg.sender, leaseStructs[msg.sender][_keyTimeStamp].leaseFee);
                WithdrawLeaseFee(leaseStructs[msg.sender][_keyTimeStamp].rent, msg.sender, leaseStructs[msg.sender][_keyTimeStamp].leaseFee);
            }
        }
    }

    // 5. withdraw pre-deposit
    // return of the deposit
    function withdrawPreDeposit(address _to, uint256 _keyTimeStamp) public{
        // require ownership
        for(uint i = 0; i < leaseStructs[_to][_keyTimeStamp].paymentTimestamp.length; ++i){
            require((leaseStructs[_to][_keyTimeStamp].paymentTimestamp[i] <= now) && (leaseStructs[_to][_keyTimeStamp].isPaid[i] == true));
        }
        withdrawDeposit(_to, msg.sender, leaseStructs[_to][_keyTimeStamp].deposit);
    }

    // 6. cancel lease before confirm
    event CreateLease(uint256 _deposit, uint256 _leaseFee, uint256 _agentFee, bool _useCA, uint256[] _paymentTimestamp, uint256 _keyTimestamp, address _leaseOwner);
    event ApplyLease(address _to, uint256 _keyTimeStamp, address _rent, uint256 _deposit, uint256 _leaseFee);
    event ConfirmLeaseByCA(address _target, uint256 _keyTimeStamp);
    event WithdrawLeaseFee(address _from , address _to, uint256 _leaseFee);

    // //////////////
    // Functions for Sale
    // //////////////
    struct SaleStruct{
        uint256 deposit;
        uint256 agentFee;
        address buyer;
        bool isUsed;
        bool lock;
        bool isConfirmed;
        bool isPaid;
    }

    mapping (address => mapping(uint256 => SaleStruct)) saleStructs;

    function createSale(uint256 _deposit, bool _useCA, uint256 _agentFee) public returns (uint256){
        // check condition
        var _keyTimestamp = now;
        // unique key owner x timestamp, default value of mapping is 0
        require(saleStructs[msg.sender][_keyTimestamp].isUsed == false);
        saleStructs[msg.sender][_keyTimestamp].deposit = _deposit;
        saleStructs[msg.sender][_keyTimestamp].isUsed = true;
        saleStructs[msg.sender][_keyTimestamp].lock = false;
        saleStructs[msg.sender][_keyTimestamp].agentFee = _agentFee;
        CreateSale(saleStructs[msg.sender][_keyTimestamp].deposit, saleStructs[msg.sender][_keyTimestamp].agentFee,
     	saleStructs[msg.sender][_keyTimestamp].isUsed,  now, msg.sender);
    }

    function applySale(address _to, uint256 _keyTimeStamp) public{
        // check lock
        require(saleStructs[_to][_keyTimeStamp].lock == false);
        // set deposit for owner
        require(saleStructs[_to][_keyTimeStamp].deposit <= balanceOf(msg.sender));
        setDeposit(msg.sender, _to, saleStructs[_to][_keyTimeStamp].deposit);
        // set lock
        saleStructs[_to][_keyTimeStamp].lock = true;
        saleStructs[_to][_keyTimeStamp].buyer = msg.sender;
        // event
        ApplySale(_to, _keyTimeStamp, saleStructs[_to][_keyTimeStamp].deposit, now, saleStructs[_to][_keyTimeStamp].buyer);
    }

    function confirmTradeByCA(address _target, uint256 _keyTimeStamp) public onlyCertifiedAgent{
        // check it is locked
        require(saleStructs[_target][_keyTimeStamp].lock == true);
        // need multi check?
        require(saleStructs[_target][_keyTimeStamp].isConfirmed == false);
        // check enough agentFee
        require(saleStructs[_target][_keyTimeStamp].agentFee <= balanceOf(_target));
        // fee
        setDeposit(_target, msg.sender, saleStructs[_target][_keyTimeStamp].agentFee);
        withdrawDeposit(_target, msg.sender, saleStructs[_target][_keyTimeStamp].agentFee);
        // confirm
        saleStructs[_target][_keyTimeStamp].isConfirmed = true;
        ConfirmTradeByCA(_target, _keyTimeStamp);
    }

    function withDrawSale(uint256 _keyTimeStamp) public{
        withdrawDeposit(saleStructs[msg.sender][_keyTimeStamp].buyer, msg.sender, saleStructs[msg.sender][_keyTimeStamp].deposit);
        WithDrawSale(saleStructs[msg.sender][_keyTimeStamp].buyer, saleStructs[msg.sender][_keyTimeStamp].deposit);
    }

    event CreateSale(uint256 _deposit, uint256 _agentFee, bool _useCA, uint256 _now, address _senderAddress);
    event ApplySale(address _to, uint256 _keyTimeStamp, uint256 _deposit, uint256 _now, address _buyer);
    event ConfirmTradeByCA(address _target, uint256 _keyTimeStamp);
    event WithDrawSale(address _buyer, uint256 _deposit);
}


