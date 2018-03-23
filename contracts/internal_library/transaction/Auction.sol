pragma solidity ^0.4.19;
import '/test/tomkim/contracts/external_library/minime/MiniMeToken.sol';

contract Auction is MiniMeToken{

    struct AuctionStruct {
      uint256 lowestprice; //경매최저가
      uint256 highestBid; //최고입찰금액
      uint256 Bid; //비드금액
      uint256 biddingTime; //경매입찰시간
      uint256 auctionStartTime; //경매시작시간
      uint256 auctionEndTime; //경매 종료
      address beneficiary; //경매자
      address highestBidder; //입찰자
      address Bidder; //비더
    	bool isUsed; //사용
      bool lock;
      bool auctionEnded;
    }

    mapping (address => mapping(uint256 => AuctionStruct)) auctionStructs;
    mapping (address => bool) public escroAuction;
    mapping (uint256 => bool) public auctionEnd;

    //1. create Auction , msg.sender 계약의 소유자 = beneficiary
    function createAuction(uint256 _lowestprice, bool _useEscro) public returns (uint256){
    	//check condition
    	var _keyTimestamp = now;
    	//unique key owner x timestamp, default value of mapping is 0
    	require(auctionStructs[msg.sender][_keyTimestamp].isUsed == false);
      auctionStructs[msg.sender][_keyTimestamp].auctionStartTime = now;
    	auctionStructs[msg.sender][_keyTimestamp].lowestprice = _lowestprice;
    	auctionStructs[msg.sender][_keyTimestamp].isUsed = true;
    	auctionStructs[msg.sender][_keyTimestamp].lock = false;
      auctionStructs[msg.sender][_keyTimestamp].auctionEnded = false;
      //경매 생성
    	CreateAuction(_lowestprice, _useEscro,  now, msg.sender);
    }

    //2. bid Auction payable 이더리움이 불렸을때..  _highestBid => _bid
    function bidAuction(address _bidder, uint256 _keyTimeStamp, uint256 _bid, uint256 _biddingTime) public {
      //check lock
      require(auctionStructs[msg.sender][_keyTimeStamp].lock == false);
      //잔고
      require(auctionStructs[msg.sender][_keyTimeStamp].lowestprice >= balanceOfAt(_bidder, block.number));
      //기간만료확인
      require(now <= _biddingTime);
      //최고 입찰가 보다 수신금액이 낮으면 돌려준다.
      require(auctionStructs[msg.sender][_keyTimeStamp].lowestprice > _bid);
      //입찰된 사람이 있는지 유무 확인
      require(auctionStructs[_bidder][_keyTimeStamp].highestBidder == 0);

      auctionStructs[msg.sender][_keyTimeStamp].lock = true;
      auctionStructs[msg.sender][_keyTimeStamp].auctionEndTime = _biddingTime;

      //기존 최고 입찰가격이 비드 가격보다 낮을 경우 최고입찰자, 입찰가가 바뀜
      if(auctionStructs[_bidder][_keyTimeStamp].highestBid < _bid){
        auctionStructs[_bidder][_keyTimeStamp].highestBidder = _bidder;
        auctionStructs[_bidder][_keyTimeStamp].highestBid = _bid;
        //경매자에게 최고입찰가 전달 준비
        setDeposit(msg.sender, auctionStructs[_bidder][_keyTimeStamp].highestBidder, auctionStructs[_bidder][_keyTimeStamp].highestBid);
      }
      //입찰 전달
      BidAuction(_bidder, _keyTimeStamp, msg.sender, _bid, _biddingTime);
    }

    //3. withDraw Aunction (End Auction)
    function withDrawAuction(address _bidder, uint256 _keyTimeStamp) public{
        // 유효성 검사 (경매기간 만료 됐는지)
        require(now >= auctionStructs[msg.sender][_keyTimeStamp].auctionEndTime);
        require(!auctionStructs[msg.sender][_keyTimeStamp].auctionEnded);

        // 금액 전달, 경매종료
        require(msg.sender == auctionStructs[_bidder][_keyTimeStamp].highestBidder);
        require(auctionStructs[msg.sender][_keyTimeStamp].lowestprice == auctionStructs[_bidder][_keyTimeStamp].highestBid);

        // 경매기간 만료 확인
        auctionStructs[msg.sender][_keyTimeStamp].auctionEnded = true;
        // 판매자에가 입찰금액 전달
        withdrawDeposit(_bidder, msg.sender, auctionStructs[_bidder][_keyTimeStamp].highestBid);
    }

    //4. Events
    //경매생성 금액, 에스크로, 시간, 판매자
    event CreateAuction(uint256 _lowestprice, bool _useEscro, uint256 _now, address _beneficiary);
    // 전달할곳, 타임스탬프, 보내는주소, 판매금, 비드시간대
    event BidAuction(address _bidder, uint256 _keyTimeStamp, address _senderAddress, uint256 _lowestprice, uint256 _biddingTime);
}
