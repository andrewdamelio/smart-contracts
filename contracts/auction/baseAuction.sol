pragma solidity ^0.4.19;

import "./auction.sol";


contract BaseAuction is Auction {
    
    address public owner;
    
    modifier ownerOnly() { 
        require(msg.sender == owner); 
        _; 
    }
    
    event AuctionComplete(address winner, uint bid);
    event BidAccepted(address maxBider, uint bidAmount);

    function BaseAuction() public {
        owner = msg.sender;
    }
}