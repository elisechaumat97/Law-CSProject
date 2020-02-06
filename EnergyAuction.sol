pragma solidity >=0.4.22 <0.6.0;

contract EnergyAuction{
    
    // init contract
    uint power;
    address public seller;
    bool public contractEnded=false;
    
    //auction
    uint public biddingTime;
    uint private auctionEndTime;
    address private highestBidder;
    uint private highestBid;
    mapping(address => uint) pendingReturns;
    bool private auctionEnded=false;
    bool private canStartBids=false;
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    
    //sell
    bool private sellEnded=false;
    bool private sellerPayed=false;
    bool private eneryDelivered=false;
    bool private sellChecked=false;
    mapping(address => uint) public powerTrack;
    
    constructor(
        uint _biddingTime,
        address _seller,
        uint _power
    ) public {
        seller = _seller;
        biddingTime = _biddingTime;
        power=_power;
        powerTrack[seller]=power;
    }
    
    //Auction
    function launchAuction() public  {
        require(msg.sender==seller,"you are not the seller");
        require(!auctionEnded,"the auction is finished");
        require(!canStartBids,"the auction is already on");
        auctionEndTime = now + biddingTime;
        canStartBids=true;
     }
     

    function bid() public payable {
        require(
            canStartBids,"The auction is not opened yet."
            );

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
        emit HighestBidIncreased(msg.sender, msg.value); 
        // the new highest bid data are stored
    }

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
    
    function auctionEnd() public {

        // 1. Conditions
        require(msg.sender==seller,"you are not the seller");
        require(now >= auctionEndTime, "Auction not yet ended.");
        require(!auctionEnded, "auctionEnd has already been called.");

        // 2. Effects
        auctionEnded = true;
        emit AuctionEnded(highestBidder, highestBid);

        
    }
    
    //sell
    function sell() public returns (bool) {
        require(auctionEnded, "the auction has not yet ended");
        require(!sellerPayed, "you have already been payed");
        require(msg.sender==seller, "you are not the seller");
       
       uint amount=highestBid;
        
       if (amount > 0) {
           
            highestBid = 0;
            /*
            Setting this value to zero is very important. If a bidder calls back the Withdraw function 
            before is first exectution is done, then he won't be able to steal all the money from the contract
            */
            // the money is sent back to the seller
            if(!msg.sender.send(amount)){
                highestBid=amount;
                sellerPayed=false;
                return false;
            }
            sellerPayed=true;
            }
            delivery();
             return true;
    }
    
     function delivery() private{
        require(!eneryDelivered, "you have already been delivered");
        require(sellerPayed, "the energy has not been payed yet");
        uint amount=power;
        
         if (amount > 0) {
             
            power=0;
            powerTrack[highestBidder] = powerTrack[highestBidder]+amount; 
            powerTrack[seller]=powerTrack[seller]-amount;
            eneryDelivered=true;
            power=amount;
        }  
        check();
    }
    
    function check() private {
        require(eneryDelivered, "energy hasn't been delivered yet");
        require(!sellChecked, "already checked");
        if(powerTrack[highestBidder]==power){
            sellChecked=true;
            //log0(bytes32("the sell is checked"));
        }
        /*else{
            
            uint amount_power=power;
            if (amount_power > 0) {
             
                power=0;
                powerTrack[highestBidder] = 0; 
                powerTrack[seller]+=amount_power;
        }   
            uint amount_bid=highestBid;
            if (amount_bid > 0) {
             //à revoir
                highestBid=0;
                //seller.send(amount_bid);
                //highestBidder.send(-amount_bid);
            }   
            sellChecked=true;
             highestBid=amount_bid;
             power=amount_power;
            
            
            
        }*/
        else{
            log0(bytes32("sell not valid"));
        
        }
    }
    
        function contractEnd() public {
            require(msg.sender==seller,"you are not the seller");
            require(sellChecked,"the sell is not valid");
            contractEnded=true;
        }

    

    
}