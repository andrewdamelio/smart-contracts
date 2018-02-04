pragma solidity ^0.4.19;

// Escrow without an arbiter but with a security fee to encourage honesty from seller/buyer.

contract Escrow {
    
    enum State { AWAITING_DEPOSIT, AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED }
    
    State public currentState;
    
    address public buyer;
    address public seller;
    uint public constant SECURITY_DEPOSIT = 1000000000000000000; // 1 Ether honesty fee
    uint public amount;
    address creator;

    modifier sellerOnly() {
        require(msg.sender == seller);
        _;
    }

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
    event StatusUpdate(string status);
    
    function Escrow(address _buyer, address _seller, uint _amount) public {
        creator = msg.sender;
        buyer = _buyer;
        seller = _seller;
        amount = _amount;
        
        StatusUpdate("Escrow created, waiting for Seller to provide security deposit");
    }
    
    function sendDeposit() public sellerOnly inState(State.AWAITING_DEPOSIT) payable {
        require(msg.value == SECURITY_DEPOSIT);

        currentState = State.AWAITING_PAYMENT;

        StatusUpdate("Seller has made security deposit of 1 Ether");
    }
       
    function sendPayment() public buyerOnly inState(State.AWAITING_PAYMENT) payable {
        require(msg.value == amount + SECURITY_DEPOSIT);

        currentState = State.AWAITING_DELIVERY;

        StatusUpdate("Buyer has made security deposit of 1 Ether and provided the escrow amount");
    }
    
    function confirmDelivery() public buyerOnly inState(State.AWAITING_DELIVERY) {
        currentState = State.COMPLETE;

        seller.transfer(this.balance - SECURITY_DEPOSIT);
        buyer.transfer(SECURITY_DEPOSIT);
 
        StatusUpdate("Buyer has confirmed delivery, funds have been released to all parties");
    }

    function confirmRefund() public sellerOnly inState(State.AWAITING_DELIVERY) {
        currentState = State.REFUNDED;

        buyer.transfer(this.balance - SECURITY_DEPOSIT);
        seller.transfer(SECURITY_DEPOSIT);
 
        StatusUpdate("Seller has provided a refund, all other funds have been released to all parties");
    }    
}