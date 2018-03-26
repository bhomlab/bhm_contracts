pragma solidity ^0.4.19;
import '/test/tomkim/contracts/external_library/minime/MiniMeToken.sol';

contract Auction is MiniMeToken{

    //already BHM.sol
    mapping (address => bool) blocked;
    event Blocked(address _addr);
    modifier onlyNotBlocked(address _addr) {
      require(!blocked[_addr]);
      _;
    }
    modifier onlyCertifiedAgent {
     require(certifiedAgent[msg.sender]);
      _;
    }
    mapping (address => bool) public certifiedAgent;

    struct AuctionStruct {
      uint256 lowestprice; //경매최저가
      uint256 highestBid; //최고입찰금액
      uint256 bid; //비드금액
      uint256 agentFee; //수수료
      uint256 biddingTime; //경매입찰시간
      uint256 auctionStartTime; //경매시작시간
      uint256 auctionEndTime; //경매 종료
      address beneficiary; //경매자
      address highestBidder; //입찰자
      address bidder; //비더
      bool isUsed; //사용
      bool lock;
      bool auctionEnded; //경매플래그
      bool isConfirmed;
    }

    //already BHM.sol
    function transferFrom(address _from, address _to, uint256 _amount) public onlyNotBlocked(_from) returns (bool success) {
      return super.transferFrom(_from, _to, _amount);
    }

    mapping (address => mapping(uint256 => AuctionStruct)) auctionStructs;

    //1. create Auction , msg.sender 계약의 소유자 = beneficiary
    function createAuction(uint256 _lowestprice, uint256 _agentFee, uint256 _auctionEndTime) public returns (uint256){
    	// check condition
    	var _keyTimeStamp = now;
    	require(auctionStructs[msg.sender][_keyTimestamp].isUsed == false);
      //경매마감시간이 지금보다 더늦게설정해야함
      require(auctionStructs[msg.sender][_keyTimestamp].auctionEndTime > now);
      auctionStructs[msg.sender][_keyTimestamp].auctionStartTime = now;
    	auctionStructs[msg.sender][_keyTimestamp].lowestprice = _lowestprice;
      auctionStructs[msg.sender][_keyTimestamp].agentFee = _agentFee;
      auctionStructs[msg.sender][_keyTimestamp].auctionEndTime  = _auctionEndTime;
    	auctionStructs[msg.sender][_keyTimestamp].isUsed = true;
    	auctionStructs[msg.sender][_keyTimestamp].lock = false;
      auctionStructs[msg.sender][_keyTimestamp].auctionEnded = false;
      //경매 생성
    	CreateAuction(msg.sender, _lowestprice, _agentFee, _auctionEndTime);
    }

    //2. bid Auction 잔고랑 bid 비교
    function bidAuction(address _beneficiary, uint256 _keyTimeStamp, uint256 _bid, uint256 _biddingTime) public {
      //check lock
      require(auctionStructs[_beneficiary][_keyTimeStamp].lock == false);
      //경매 기간 만기인지 확인
      require(auctionStructs[_beneficiary][_keyTimeStamp].auctionEndTime >= now);
      //비드타임이 경매 만기 전인지 확인
      require(auctionStructs[_beneficiary][_keyTimeStamp].auctionEndTime >= auctionStructs[msg.sender][_keyTimeStamp].biddingTime);
      //비더가 최저가보다 높게 지불가능한지 확인
      require(auctionStructs[_beneficiary][_keyTimeStamp].lowestprice <= balanceOfAt(msg.sender, block.number));
      //잔고가 비더금액보다 많은지
      require(_bid <= balanceOfAt(msg.sender, block.number));
      //최저가 보다 수신금액이 낮으면 X
      require(auctionStructs[_beneficiary][_keyTimeStamp].lowestprice < _bid);
      //진행되는 최고경매가 보다 낮으면 X
      require(auctionStructs[_beneficiary][_keyTimeStamp].highestBid < _bid);
      //경매자에게 비드가 set
      setDeposit(msg.sender, _beneficiary, auctionStructs[_beneficiary][_keyTimeStamp].highestBid);
      //경매 비딩 금액, 시간
      auctionStructs[_beneficiary][_keyTimeStamp].biddingTime = _biddingTime;
      auctionStructs[_beneficiary][_keyTimeStamp].lock = true;
      auctionStructs[_beneficiary][_keyTimeStamp].bidder = msg.sender;
      auctionStructs[_beneficiary][_keyTimeStamp].bid = _bid;
      auctionStructs[_beneficiary][_keyTimeStamp].highestBidder = auctionStructs[_beneficiary][_keyTimeStamp].bidder;
      auctionStructs[_beneficiary][_keyTimeStamp].highestBid = auctionStructs[_beneficiary][_keyTimeStamp].bid;

      //현재 최고입찰가 전달
      BidAuction(_beneficiary, _keyTimeStamp, auctionStructs[_beneficiary][_keyTimeStamp].highestBidder,
        auctionStructs[_beneficiary][_keyTimeStamp].highestBid, _biddingTime);
    }

    //3. Escro Auction add certifiedAgent
    function escroAuction(address _beneficiary, uint256 _keyTimeStamp) public onlyCertifiedAgent{
      //check it is locked
      require(auctionStructs[_beneficiary][_keyTimeStamp].lock == true);
      //need multi check?
      require(auctionStructs[_beneficiary][_keyTimeStamp].isConfirmed == false);
      //경매자가 수수료 지불가능한지 확인
      require(auctionStructs[_beneficiary][_keyTimeStamp].agentFee <= balanceOfAt(_beneficiary, block.number));
      //에스크로 수수료 전달
      transferFrom(_beneficiary, msg.sender, auctionStructs[_beneficiary][_keyTimeStamp].agentFee);
      //확인
      auctionStructs[_beneficiary][_keyTimeStamp].isConfirmed = true;
      //에스크로 진행
      EscroAuction(_beneficiary, _keyTimeStamp);
    }

    //4. withDraw Aunction (End Auction)
    function withDrawAuction(address _beneficiary, uint256 _keyTimeStamp) public{
      // 유효성 검사 (경매기간 만료 됐는지)
      require(auctionStructs[_beneficiary][_keyTimeStamp].auctionEndTime <= now);
      require(!auctionStructs[_beneficiary][_keyTimeStamp].auctionEnded);
      // 경매기간 만료 확인
      auctionStructs[_beneficiary][_keyTimeStamp].auctionEnded = true;
      // 판매자에게 금액 전달 입찰완료
      withdrawDeposit(msg.sender, _beneficiary, auctionStructs[_beneficiary][_keyTimeStamp].highestBid);
      // 경매 종료
      AuctionEnd(auctionStructs[_beneficiary][_keyTimeStamp].highestBidder, auctionStructs[_beneficiary][_keyTimeStamp].highestBid
        , _keyTimeStamp);
    }

    //5. Events
    //경매생성 금액, 경매종료시간, 생성시간, 판매자
    event CreateAuction(address _beneficiary, uint256 _lowestprice, uint256 _agentFee, uint256 _auctionEndTime);
    // 전달할곳, 타임스탬프, 보내는주소, 판매금, 비드시간대
    event BidAuction(address _beneficiary, uint256 _keyTimeStamp, address highestBidder, uint256 _highestBid, uint256 _biddingTime);
    // escro Auction
    event EscroAuction(address _target, uint256 _keyTimeStamp);
    // Auction end
    event AuctionEnd(address _highestBidder, uint256 _highestBid, uint256 _keyTimeStamp);
}
