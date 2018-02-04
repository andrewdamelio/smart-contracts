pragma solidity ^0.4.19;


contract Killswitch {

    enum State { ALIVE, DEAD }
    State public currentState;
    
    uint public checkinFreq;
    uint public holdings;
    uint public durationMins;
    address public beneficiary;
    address public owner;
 
    event CheckedIn(uint timestamp);
    event AttemptedClaim(uint timestamp);
  
    function Killswitch(uint _durationMins, address _beneficiary) public payable {
        require(msg.sender != _beneficiary);
        owner = msg.sender;
        holdings = msg.value;
        beneficiary = _beneficiary;
        durationMins = _durationMins;
        currentState = State.ALIVE;
        checkinFreq = now + (_durationMins * 1 minutes);
    }
 
    function claimHoldings() public {
        require(msg.sender == beneficiary);
        require(currentState == State.ALIVE);
        if (now < checkinFreq) {
            AttemptedClaim(now);
        } else {
            currentState = State.DEAD;
            beneficiary.transfer(holdings);
        }
    }   

    function checkIn() public {
        require(msg.sender == owner);
        checkinFreq = now + (durationMins * 1 minutes);
        CheckedIn(now);
    }
}