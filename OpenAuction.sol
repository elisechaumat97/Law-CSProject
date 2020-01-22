pragma solidity >=0.4.22 <0.7.0;

contract OpenAuction {

    // The period times are seconds
    address payable public beneficiary;
    uint public auctionEndTime;

    // Current state of the auction.
    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool ended;

    /*
    Events when emitted allow to store the logs given to it.
    Here these logs are the highest bidder's address with the bid value
    */
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(
        uint _biddingTime,
        address payable _beneficiary
    ) public {
        beneficiary = _beneficiary;
        auctionEndTime = now + _biddingTime;
    }

    /*
    The bid function has to be payable because it will recieve Ethers.
    require() here permits to check whether the auction has ended and if the bid is higher than the former highest one
    If require fails, the money is sent back
    */
    function bid() public payable {

        require(
            now <= auctionEndTime,
            "Auction already ended."
        );

        require(
            msg.value > highestBid,
            "There already is a higher bid."
        );

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid; 
            /*
            For this new bidder, the amount to refund him in case a higher bid is made is set to his bid
            */
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value); // the new highest bid data are stored
    }

    /* 
    Withdraw a bid allows to get back one's money
    */
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
           
            pendingReturns[msg.sender] = 0;
            /*
            Setting this value to zero is very important. If a bidder calls back the Withdraw function 
            before is first exectution is done, then he won't be able to steal all the money from the contract
            */
            // the money is sent back to the bidder
            if (!msg.sender.send(amount)) {
                // if the process didn't work out then the amount to refund him is reset to its original state
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /*
    This function keeps the highest bid and send it to its beneficiary
    */
    function auctionEnd() public {

        // 1. Conditions
        require(now >= auctionEndTime, "Auction not yet ended.");
        require(!ended, "auctionEnd has already been called.");

        // 2. Effects
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // 3. Interaction
        beneficiary.transfer(highestBid);
    }
}