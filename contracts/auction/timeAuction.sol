pragma solidity ^0.4.19;

import "./baseAuction.sol";
import "./withdrawable.sol";


contract TimeAuction is BaseAuction, Withdrawable {
    
    string public itemDescription;
    uint public auctionEnd;
    address public maxBider;
    uint public maxBid;
    bool public ended;
    
    function TimeAuction(uint _durationMins, string _itemDescription) public {
        itemDescription = _itemDescription;
        // now === block.timestamp
        auctionEnd = now + (_durationMins * 1 minutes);
    }
    
    function bid()  public payable {
        require(now < auctionEnd);
        require(msg.value > maxBid);
        
        if (maxBider != 0) {
            pendingWithdrawals[maxBider] = maxBid;
        }
        
        maxBid = msg.value;
        maxBider = msg.sender;
        BidAccepted(maxBider, maxBid);
    }
    
    function end() public ownerOnly {
        require(now >= auctionEnd);
        require(ended == false);
        owner.transfer(maxBid);
        AuctionComplete(maxBider, maxBid);
        ended = true;
    }
}