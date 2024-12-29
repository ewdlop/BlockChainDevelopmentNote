```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract conducts elections with functions to add candidates, authorize voters, and cast votes.
contract Election {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint vote;
    }

    address public owner;
    string public electionName;
    uint public totalVotes;

    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    uint public candidatesCount;

    event ElectionResult(string candidate, uint voteCount);
    event VoterAuthorized(address voter);
    event VoteCasted(address voter, uint candidateId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(string memory _name) {
        owner = msg.sender;
        electionName = _name;
    }

    // Function to add a new candidate to the election
    function addCandidate(string memory _name) public onlyOwner {
        candidatesCount++;
        candidates.push(Candidate(candidatesCount, _name, 0));
    }

    // Function to authorize a voter
    function authorizeVoter(address _person) public onlyOwner {
        voters[_person].authorized = true;
        emit VoterAuthorized(_person);
    }

    // Function to cast a vote for a candidate
    function vote(uint _candidateId) public {
        require(voters[msg.sender].authorized, "You are not authorized to vote");
        require(!voters[msg.sender].voted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        voters[msg.sender].voted = true;
        voters[msg.sender].vote = _candidateId;
        candidates[_candidateId - 1].voteCount++;
        totalVotes++;

        emit VoteCasted(msg.sender, _candidateId);
    }

    // Function to end the election and emit the results
    function endElection() public onlyOwner {
        for (uint i = 0; i < candidatesCount; i++) {
            emit ElectionResult(candidates[i].name, candidates[i].voteCount);
        }
    }

    // Function to get the number of candidates
    function getNumCandidates() public view returns (uint) {
        return candidatesCount;
    }

    // Function to get the details of a candidate by index
    function getCandidate(uint _index) public view returns (uint, string memory, uint) {
        require(_index < candidatesCount, "Invalid candidate index");
        Candidate memory candidate = candidates[_index];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
}
```
