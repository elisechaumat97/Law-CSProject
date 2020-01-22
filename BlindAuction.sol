pragma solidity >0.4.23 <0.7.0;

contract BlindAuction {
    //instead of an actual bid, a bidder sends its hashed version
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    address payable public beneficiary;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids; //this mapping stores all the bids corresponding to all the addresses

    address public highestBidder;
    uint public highestBid;
    
    mapping(address => uint) pendingReturns; //for each address, this mapping stores the value for eventual refunds

    //when emmitted, an event will store the logs given to it
    event AuctionEnded(address winner, uint highestBid);
    /*
    Function Modifiers are used to modify the behaviour of a function. 
    Here, it will add the prerequisite that the auction time is not up.
    The function body is inserted where the special symbol "_;" appears in the definition of a modifier. 
    So if condition of modifier is satisfied while calling this function, the function is executed and otherwise, 
    an exception is thrown.
    */
    modifier onlyBefore(uint _time) { require(now < _time); _; }
    modifier onlyAfter(uint _time) { require(now > _time); _; }
    
    constructor(
        uint _biddingTime,
        uint _revealTime,
        address payable _beneficiary
    ) public {
        beneficiary = _beneficiary;
        biddingEnd = now + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }
    
    /* Place a blinded bid with `_blindedBid` =
     keccak256(abi.encodePacked(value, fake, secret)).
     The sent ether is only refunded if the bid is correctly
     revealed in the revealing phase. The bid is valid if the
     ether sent together with the bid is at least "value" and
     "fake" is not true. Setting "fake" to true and sending
     not the exact amount are ways to hide the real bid but
     still make the required deposit. The same address can
     place multiple bids
    */
    function bid(bytes32 _blindedBid)
        public
        payable
        onlyBefore(biddingEnd)
    {
        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        }));
    }
    
    /*
    reveal() permits to see the blinded bids. 
    Refunds will be available for all topped bids, as well as invalid bids that were blinded properly
    */
function reveal(
        uint[] memory _values,
        bool[] memory _fake,
        bytes32[] memory _secret
    )
        public
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(_values.length == length); // the lengths of the bids lists are checked
        require(_fake.length == length);
        require(_secret.length == length);

        uint refund;
        for (uint i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i]; 
            (uint value, bool fake, bytes32 secret) =
                    (_values[i], _fake[i], _secret[i]);
                    if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))) {
                // Bid was not actually revealed
                // Do not refund deposit
                continue;
            }
            /*
            for one bid, if it is valid we refund, else we continu with another bid
            */
            refund += bidToCheck.deposit; // the refund equals the deposit
            if (!fake && bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value))// if the bid is the highest, we don't refund
                    refund -= value;
            }
            bidToCheck.blindedBid = bytes32(0); 
            // the bid to check is set to zero so we make sure a deposit can only be claimed once
        }
        msg.sender.transfer(refund);
    }
    /*
    this function finds the highest bid made so far
    */
    function placeBid(address bidder, uint value) internal
            returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid; // Refund the previously highest bidder
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }
    //withdraw a bid if someone overbid 
    function withdraw() public {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
    /*
    This prevent the sender to empty the contract by re-calling the withdraw function 
    */
            pendingReturns[msg.sender] = 0;

            msg.sender.transfer(amount);
        }
    }
   // End the auction and send the highest bid to the beneficiary
    function auctionEnd()
        public
        onlyAfter(revealEnd)
    {
        require(!ended);
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }

}