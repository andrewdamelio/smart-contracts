pragma solidity ^0.4.19;


contract Election {
    
    struct Candidate {
        string name;
        uint votes;
    }
    
    struct Voters {
        bool voted;
        uint vote;
        uint weight;
    }
    
    Candidate[] public candidates;
    mapping(address => Voters) public voters;
    
    address public owner;
    
    
    event ElectionOver(string candidate, uint candidateVotes);
    
    function Election(string _candidate1, string _candidate2) public {
        owner = msg.sender;    
        candidates.push(Candidate({ name: _candidate1, votes: 0 }));
        candidates.push(Candidate({ name: _candidate2, votes: 0 }));
    }
    
    function authorize(uint _weight, address _voter) public {
        require(msg.sender == owner);
        require(!voters[_voter].voted);
        
        voters[_voter].weight = _weight;
    } 
    
    function vote(uint candidateIndex) public {
        require(voters[msg.sender].voted == false);
        require(voters[msg.sender].weight > 0);
        
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = 1;
        candidates[candidateIndex].votes += voters[msg.sender].weight;
    }
    
    function end() public {
        require(msg.sender == owner);
        for (uint i = 0; i < candidates.length; i++) {
            ElectionOver(candidates[i].name, candidates[i].votes);
        }
        
        selfdestruct(owner);
    }
}