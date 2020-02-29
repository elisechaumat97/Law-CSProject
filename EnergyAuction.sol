pragma solidity >=0.4.22 <0.6.0;

contract EnergyAuction{
    enum State {Offline, Online}
    State private state = State.Offline;
    address oracle;
    uint energyAvailable = 0;
    uint energySold=0;
    
    
    modifier onlyOracle(){
        require(msg.sender == oracle);
        _;
    }
    
    function oracleStartBid (uint _energyAvailable) public onlyOracle {
        require(!contractEnded,"the contract is ended");
        state= State.Online;
        energyAvailable = _energyAvailable;
    }
    
    
    function isOnline () private view returns(bool){
        return (state == State.Online);
    }
    
    // init contract
    uint power;
    address public seller;
    bool public contractEnded=false;
    
    //auction
    uint public biddingTime;
    uint private auctionEndTime;
    address private highestBidder;
    uint public highestBid;
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
    bool private sellValid=false;
    mapping(address => uint) public powerTrack;
    
    constructor(
        uint _biddingTime,
        uint _power,
        address _oracle
    ) public {
        seller = msg.sender;
        biddingTime = _biddingTime;
        power=_power;
        powerTrack[seller]=power;
        oracle = _oracle;
        state = State.Offline;
    }
    
    //Auction
    function launchAuction() public  {
        require(!contractEnded,"the contract is ended");
        require(msg.sender==seller,"you are not the seller");
        require(!auctionEnded,"the auction is finished");
        require(isOnline(),'cannot start the auction for now');
        require(!canStartBids,"the auction is already on");
        require(power <= energyAvailable , "you don't have enough energy");
        auctionEndTime = now + biddingTime;
        canStartBids=true;
     }
     

    function bid() public payable {
         require(!contractEnded,"the contract is ended");

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
   
     function deliver() public{
        require(!contractEnded,"the contract is ended");
        require(msg.sender==seller, "you are not the seller");
        require(auctionEnded, "the auction has not yet ended");
        require(!eneryDelivered, "you have already been delivered");
        uint amount=power;
        
         if (amount > 0) {
             
            power=0;
            powerTrack[highestBidder] = powerTrack[highestBidder]+amount; 
            powerTrack[seller]=powerTrack[seller]-amount;
            eneryDelivered=true;
            power=amount;
        }  
    }
    

    
    function oracleCheck (uint _energySold) public onlyOracle {
        require(!contractEnded,"the contract is not ended");
        require(eneryDelivered, "energy hasn't been delivered yet");
        require(!sellChecked, "already checked");
        energySold=_energySold;
        check();
    }
        
    function check() private {
        
        
        if(powerTrack[highestBidder]==energySold&&powerTrack[seller]==0){
            sellValid=true;
        }
        else{
            uint amount=energySold;
        
                if (amount > 0) {
             
                energySold=0;
                powerTrack[highestBidder] = powerTrack[highestBidder]-amount; 
                powerTrack[seller]=powerTrack[seller]+amount;
                energySold=amount;
                }  
                pendingReturns[highestBidder] += highestBid; 
            }
        sellChecked=true;
       
        
    }
    
     function sell() public returns (bool) {
        require(!contractEnded,"the contract is ended");
        require(msg.sender==seller, "you are not the seller");
        require(sellValid, "the delivery is not valid");
        require(!sellerPayed, "you have already been payed");
       
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
             return true;
    }
    
        function contractEnd() public {
            require(!contractEnded,"the contract is not ended");
            require(sellChecked||(power > energyAvailable),"the sell is not valid");
            require(msg.sender==seller,"you are not the seller");
            require((sellerPayed&&sellValid)||(!sellValid)||(power > energyAvailable), "you have not payed yet");
            contractEnded=true;
        }
    
}