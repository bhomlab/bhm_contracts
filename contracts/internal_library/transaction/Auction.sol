pragma solidity ^0.4.19;
import '/test/tomkim/contracts/external_library/minime/MiniMeToken.sol';

contract Auction is MiniMeToken{

    struct AuctionStruct {
      uint256 deposit; //판매대금
      uint256 highestBid; //최고입찰금액
      uint biddingTime;//경매입찰시간
      uint auctionEnd; //경매 종료
    	address beneficiary; //경매자
      address highestBidder; //최고입찰자
      address saler;
    	address confirmedCA; //에스크로 혹은 중개
    	bool isUsed; //사용
      bool lock;
      bool isConfirmed;
      bool isPaid;
    }

    //Escro 확인
    modifier onlyEscroAuction {
     require(escroAuction[msg.sender]);
      _;
    }

    mapping (address => mapping(uint256 => AuctionStruct)) auctionStructs;
    mapping (address => bool) public escroAuction;

    //1. create Auction
    function createAuction(uint _auctionEnd, uint256 _deposit, bool _useCA, address _beneficiary) public returns (uint256){
    	//check condition
    	var _keyTimestamp = now;
    	//unique key owner x timestamp, default value of mapping is 0
    	require(auctionStructs[msg.sender][_keyTimestamp].isUsed == false);
      //auctionStructs[msg.sender][_keyTimeStamp].biddingTime = _auctionEnd;
    	auctionStructs[msg.sender][_keyTimestamp].deposit = _deposit;
    	auctionStructs[msg.sender][_keyTimestamp].isUsed = true;
    	auctionStructs[msg.sender][_keyTimestamp].lock = false;
      //경매 생성
    	CreateAuction(now, _deposit, _useCA,  now, msg.sender);
    }


    //2. bid Auction
    function bidAuction(address _to, uint256 _keyTimeStamp, uint _highestBid, uint _biddingTime) public {
        //check lock
        require(auctionStructs[_to][_keyTimeStamp].lock == false);
        //set amount for owner
        require(auctionStructs[_to][_keyTimeStamp].deposit >= balanceOfAt(msg.sender, block.number));
        //period over
        require(now <= auctionStructs[_to][_keyTimeStamp].auctionEnd);
        //최고 입찰가 보다 수신금액이 낮으면 돌려준다.
        require(auctionStructs[_to][_keyTimeStamp].deposit > _highestBid);
        //최고 입찰자가 있으면 돌려준다.
        /* if (auctionStructs[_to][_keyTimeStamp].highestBidder != 0) {
            auctionStructs[_to][_keyTimeStamp].highestBidder += _highestBid;
        } */
        //setDeposit(msg.sender, _to, auctionStructs[_to][_keyTimeStamp].deposit);
        auctionStructs[_to][_keyTimeStamp].lock = true;
        auctionStructs[_to][_keyTimeStamp].highestBidder = msg.sender;
        auctionStructs[_to][_keyTimeStamp].highestBid = msg.value;

        //비드 Auction
        BidAuction(_to, _keyTimeStamp, msg.sender, msg.value);
    }

    //3. Escro
    function escroAuction(address _target, uint256 _keyTimeStamp) public onlyEscroAuction{
      //check it is locked
      require(auctionStructs[_target][_keyTimeStamp].lock == true);
      //need multi check?
      require(auctionStructs[_target][_keyTimeStamp].isConfirmed == false);
      //fee?
      transferFrom(_target, msg.sender, auctionStructs[_target][_keyTimeStamp].highestBidder);
      //confirm
      auctionStructs[_target][_keyTimeStamp].isConfirmed = true;
      EscroAuction(_target, _keyTimeStamp);
    }

    //4. withDraw Aunction
    function withDrawAuction(address _target, uint256 _keyTimeStamp) public {
        require(msg.sender == auctionStructs[_target][_keyTimeStamp].highestBidder);
        /* uint256 amount = auctionStructs[msg.sender][_keyTimeStamp].highestBidder;

        if (!msg.sender.send(amount)) {
              //auctionStructs[msg.sender][_keyTimestamp].highestBidder = amount;
              return false;
        } */
        withdrawAuction(_target, msg.sender, AuctionStructs[_target][_keyTimeStamp].highestBidder);
    }

    /* //5. end Auction
    function endAuction() public {
        // 유효성 검사 (기간만료 됐는지)
        require(now >= auctionEnd);
        require(!ended);
        // 2. Effects
        ended = true;
        EndedAuction(highestBidder, highestBid);

        // 3. Interaction
        beneficiary.transfer(highestBid);
    } */


    //6. Events
    event CreateAuction(uint _biddingTime, uint256 _deposit, bool _useCA, uint256 _now, address _beneficiary);
    event BidAuction(address _to, uint256 _keyTimeStamp, address _senderAddress, uint256 _deposit);
    event EscroAuction(address _target, uint256 _keyTimeStamp);
    event withdrawAuction(address _target, address _to, uint256 _deposit);
    //event HighestBidIncreased(address bidder, uint amount);
    event EndedAuction(address _target, uint _deposit);
}
