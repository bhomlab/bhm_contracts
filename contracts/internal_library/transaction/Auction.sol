pragma solidity ^0.4.19;
import '/test/tomkim/contracts/external_library/minime/MiniMeToken.sol';

contract Auction is MiniMeToken{

    struct AuctionStruct {
      uint256 deposit; //판매대금
      uint256 highestBid; //최고입찰금액
      uint256 biddingTime; //경매입찰시간
      uint256 auctionStartTime; //경매시작시간
      uint256 auctionEndTime; //경매 종료
      address beneficiary; //경매자
      //address escro; //에스크로
      address highestBidder; //최고입찰자
    	bool isUsed; //사용
      bool lock;
      bool isConfirmed;
      bool auctionEnded;
    }

    //Escro 확인
    modifier onlyEscroAuction {
     require(escroAuction[msg.sender]);
      _;
    }

    modifier onlyAuctionEnd {
     require(auctionEnd[msg.value]);
      _;
    }

    mapping (address => mapping(uint256 => AuctionStruct)) auctionStructs;
    mapping (address => bool) public escroAuction;
    mapping (uint256 => bool) public auctionEnd;

    //1. create Auction
    function createAuction(uint256 _deposit, bool _useEscro) public returns (uint256){
    	//check condition
    	var _keyTimestamp = now;

    	//unique key owner x timestamp, default value of mapping is 0
    	require(auctionStructs[msg.sender][_keyTimestamp].isUsed == false);
      auctionStructs[msg.sender][_keyTimestamp].auctionStartTime = now;
    	auctionStructs[msg.sender][_keyTimestamp].deposit = _deposit;
    	auctionStructs[msg.sender][_keyTimestamp].isUsed = true;
    	auctionStructs[msg.sender][_keyTimestamp].lock = false;

      //경매 생성
    	CreateAuction(_deposit, _useEscro,  now, msg.sender);
    }

    //2. bid Auction
    function bidAuction(address _to, uint256 _keyTimeStamp, uint _highestBid, uint256 _biddingTime) public payable {
      //check lock
      require(auctionStructs[_to][_keyTimeStamp].lock == false);
      //잔고
      require(auctionStructs[_to][_keyTimeStamp].deposit >= balanceOfAt(msg.sender, block.number));
      //기간만료확인
      require(now <= _biddingTime);
      //최고 입찰가 보다 수신금액이 낮으면 돌려준다.
      require(auctionStructs[_to][_keyTimeStamp].deposit > _highestBid);
      //입찰된 사람이 있는지 유무 확인
      require(auctionStructs[_to][_keyTimeStamp].highestBidder == 0);

      auctionStructs[_to][_keyTimeStamp].lock = true;
      auctionStructs[_to][_keyTimeStamp].auctionEndTime == _biddingTime;
      //입찰자, 입찰가격
      auctionStructs[_to][_keyTimeStamp].highestBidder = msg.sender;
      auctionStructs[_to][_keyTimeStamp].highestBid = msg.value;

      //입찰 진행
      BidAuction(_to, _keyTimeStamp, msg.sender, msg.value, _biddingTime);
    }

    //3. Escro Auction
    function escroAuction(address _target, uint256 _keyTimeStamp) public onlyEscroAuction{
      //check it is locked
      require(auctionStructs[_target][_keyTimeStamp].lock == true);
      //need multi check?
      require(auctionStructs[_target][_keyTimeStamp].isConfirmed == false);
      //금액 전달
      transferFrom(_target, msg.sender, auctionStructs[_target][_keyTimeStamp].highestBid);
      //입찰 금액 전달 확인
      auctionStructs[_target][_keyTimeStamp].isConfirmed = true;
      //에스크로 진행
      EscroAuction(_target, _keyTimeStamp);
    }

    //4. withDraw Aunction (End Auction)
    function withDrawAuction(address _beneficiary, uint256 _keyTimeStamp) public payable onlyAuctionEnd{
        // 유효성 검사 (경매기간 만료 됐는지)
        require(now >= auctionStructs[msg.sender][_keyTimeStamp].auctionEndTime);
        require(!auctionStructs[msg.sender][_keyTimeStamp].auctionEnded);

        // 경매기간 만료 확인
        auctionStructs[msg.sender][_keyTimeStamp].auctionEnded = true;

        // 금액 전달, 경매종료
        require(msg.sender == auctionStructs[_beneficiary][_keyTimeStamp].highestBidder);
        require(msg.value == auctionStructs[msg.sender][_keyTimeStamp].highestBid);
        withdrawAuction(_beneficiary, msg.sender, msg.value);
    }

    //5. Events
    //경매생성 금액, 에스크로, 시간, 판매자
    event CreateAuction(uint256 _deposit, bool _useEscro, uint256 _now, address _beneficiary);
    // 전달할곳, 타임스탬프, 보내는주소, 판매금, 비드시간대
    event BidAuction(address _to, uint256 _keyTimeStamp, address _senderAddress, uint256 _deposit, uint256 _biddingTime);
    // 에스크로 확인 완료
    event EscroAuction(address _target, uint256 _keyTimeStamp);
    // 경매 종료 판매자에게 판매금액(입찰가) 전달
    event withdrawAuction(address _beneficiary, address _to, uint256 _highestBid);
}
