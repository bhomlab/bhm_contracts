pragma solidity ^0.4.19;
import '/test/tomkim/contracts/external_library/minime/MiniMeToken.sol';

contract Auction is MiniMeToken{

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
      address Bidder; //비더
    	bool isUsed; //사용
      bool lock;
      bool auctionEnded; //경매플래그
      bool isConfirmed;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public onlyNotBlocked(_from) returns (bool success) {
      return super.transferFrom(_from, _to, _amount);
    }


    mapping (address => mapping(uint256 => AuctionStruct)) auctionStructs;

    //1. create Auction , msg.sender 계약의 소유자 = beneficiary
    function createAuction(address _beneficiary, uint256 _lowestprice, uint256 _agentFee,uint256 _auctionEndTime) public returns (uint256){
    	//check condition
    	var _keyTimestamp = now;
    	//unique key owner x timestamp, default value of mapping is 0
    	require(auctionStructs[msg.sender][_keyTimestamp].isUsed == false);
      require(auctionStructs[msg.sender][_keyTimestamp].auctionEndTime > now);
      auctionStructs[msg.sender][_keyTimestamp].auctionStartTime = now;
      auctionStructs[msg.sender][_keyTimestamp].beneficiary = _beneficiary;
    	auctionStructs[msg.sender][_keyTimestamp].lowestprice = _lowestprice;
      auctionStructe[msg.sender][_keyTimeStamp].agentFee = agentFee;
      auctionStructs[msg.sender][_keyTimestamp].auctionEndTime  = _auctionEndTime;
    	auctionStructs[msg.sender][_keyTimestamp].isUsed = true;
    	auctionStructs[msg.sender][_keyTimestamp].lock = false;
      auctionStructs[msg.sender][_keyTimestamp].auctionEnded = false;
      //경매 생성
    	CreateAuction(msg.sender, _lowestprice, _agentFee, _auctionEndTime, now);
    }

    //2. bid Auction
    function bidAuction(address _bidder, uint256 _keyTimeStamp, uint256 _bid, uint256 _biddingTime) public {
      //check lock
      require(auctionStructs[msg.sender][_keyTimeStamp].lock == false);
      //비드하는사람 잔고 확인
      require(auctionStructs[msg.sender][_keyTimeStamp].bid >= balanceOfAt(msg.sender, block.number));
      //최고 입찰가 보다 수신금액이 낮으면 돌려준다.
      require(auctionStructs[msg.sender][_keyTimeStamp].lowestprice > _bid);
      //입찰된 사람이 있는지 유무 확인
      require(auctionStructs[msg.sender][_keyTimeStamp].highestBidder == 0);

      //경매 비딩 금액, 시간
      auctionStructs[msg.sender][_keyTimeStamp].lock = true;
      auctionStructs[msg.sender][_keyTimeStamp].biddingTime = _biddingTime;
      auctionStructs[msg.sender][_keyTimeStamp].bid = _bid;
      auctionStructs[msg.sender][_keyTimeStamp].highestBid = auctionStructs[msg.sender][_keyTimeStamp].bid;

      //기존 최고 입찰가격이 비드 가격보다 낮을 경우 최고입찰자, 입찰가가 바뀜
      if(auctionStructs[msg.sender][_keyTimeStamp].highestBid < _bid) {
        auctionStructs[msg.sender][_keyTimeStamp].highestBidder = _bidder;
        auctionStructs[msg.sender][_keyTimeStamp].highestBid = _bid;
        //입찰 알림 이벤트
        BidAuction(msg.sender, _keyTimeStamp, auctionStructs[msg.sender][_keyTimeStamp].beneficiary,
          auctionStructs[msg.sender][_keyTimeStamp].highestBid, _biddingTime);
      }
      //경매자에게 최고입찰가 전달 준비
      setDeposit(auctionStructs[msg.sender][_keyTimeStamp].beneficiary, auctionStructs[msg.sender][_keyTimeStamp].highestBidder,
        auctionStructs[msg.sender][_keyTimeStamp].highestBid);
    }

    //3. Escro Auction
    function escroAuction(address _target, uint256 _keyTimeStamp) public onlyEscroAuction{
      //check it is locked
      require(auctionStructs[_target][_keyTimeStamp].lock == true);
      //need multi check?
      require(auctionStructs[_target][_keyTimeStamp].isConfirmed == false);
      //금액 전달
      require(auctionStructs[_target][_keyTimeStamp].agentFee >= balanceOfAt(_target, block.number))

      transferFrom(_target, msg.sender, auctionStructs[_target][_keyTimeStamp].agentFee);

      //입찰 금액 전달 확인
      auctionStructs[_target][_keyTimeStamp].isConfirmed = true;
      //에스크로 진행
      EscroAuction(_target, _keyTimeStamp);
    }

    //4. withDraw Aunction (End Auction)
    function withDrawAuction(address _bidder, uint256 _keyTimeStamp) public{
        // 유효성 검사 (경매기간 만료 됐는지)
        require(now >= auctionStructs[msg.sender][_keyTimeStamp].auctionEndTime);
        require(!auctionStructs[msg.sender][_keyTimeStamp].auctionEnded);

        // 경매기간 만료 확인
        auctionStructs[msg.sender][_keyTimeStamp].auctionEnded = true;

        // 판매자에가 입찰금액 전달
        withdrawDeposit(_bidder, msg.sender, auctionStructs[_bidder][_keyTimeStamp].highestBid);
    }

    //5. Events
    //경매생성 금액, 경매종료시간, 생성시간, 판매자
    event CreateAuction(address _beneficiary, uint256 _lowestprice, uint256 _auctionEndTime, uint256 _now);
    // 전달할곳, 타임스탬프, 보내는주소, 판매금, 비드시간대
    event BidAuction(address _bidder, uint256 _keyTimeStamp, address _beneficiary, uint256 _lowestprice, uint256 _biddingTime);
    // escro
    event ConfirmLeaseByCA(address _target, uint256 _keyTimeStamp);
}
