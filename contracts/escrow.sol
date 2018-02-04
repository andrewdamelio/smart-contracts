pragma solidity ^0.4.19;


contract Escrow {
    
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }
    
    State public currentState;
    
    address public buyer;
    address public seller;
    uint public amount;
    address creator;

    modifier buyerOnly() {
        require(msg.sender == buyer);
        _;
    }

    modifier inState(State expectedState) {
        require(currentState == expectedState);
        _;
    }
    
    event SendPackage(address buyer);
    event ShipmentRecieved(uint balance);
    
    function Escrow(address _buyer, address _seller, uint _amount) public {
        creator = msg.sender;
        buyer = _buyer;
        seller = _seller;
        amount = _amount;
    }
    
    function sendPayment() public buyerOnly inState(State.AWAITING_PAYMENT) payable {
        require(msg.value == amount);
        currentState = State.AWAITING_DELIVERY;
        SendPackage(buyer);
    }
    
    function confirmDelivery()  public buyerOnly inState(State.AWAITING_DELIVERY) {
        seller.transfer(this.balance);
        ShipmentRecieved(amount);
        currentState = State.COMPLETE;
    }
}