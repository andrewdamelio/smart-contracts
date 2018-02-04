pragma solidity ^0.4.19;


contract Killswitch {

    enum State { ALIVE, DEAD }
    State public currentState;
    
    uint public checkinFrequency;
    uint public holdings;
    uint public durationMins;
    address public beneficiary;
    address public owner;
 
    event UpdateStatus(string status, uint now);
    
    modifier isAlive() {
        require(currentState == State.ALIVE);
        _;
    }
  
    function Killswitch(uint _durationMins, address _beneficiary) public payable {
        require(msg.sender != _beneficiary);
        owner = msg.sender;
        holdings = msg.value;
        beneficiary = _beneficiary;
        durationMins = _durationMins;
        currentState = State.ALIVE;
        checkinFrequency = now + (_durationMins * 1 minutes);
    }
 
    function claimHoldings() public isAlive {
        require(msg.sender == beneficiary);
        if (now < checkinFrequency) {
            UpdateStatus("Claim failed. Owner still has time to check in", now);
        } else {
            currentState = State.DEAD;
            beneficiary.transfer(holdings);
            UpdateStatus("Claim cleared. Owner is unaccounted for", now);
        }
    }   

    function checkIn() public {
        require(msg.sender == owner);
        checkinFrequency = now + (durationMins * 1 minutes);
        UpdateStatus("Owner checked in", checkinFrequency);
    }
}