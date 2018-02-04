pragma solidity ^0.4.19;


interface Auction {
    
    function bid() public payable;
    
    function end() public;
}
