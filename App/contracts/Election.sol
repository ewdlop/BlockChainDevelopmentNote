// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    function addCandidate(string memory _name) public onlyOwner {
        candidatesCount++;
        candidates.push(Candidate(candidatesCount, _name, 0));
    }

    function authorizeVoter(address _person) public onlyOwner {
        voters[_person].authorized = true;
        emit VoterAuthorized(_person);
    }

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

    function endElection() public onlyOwner {
        for (uint i = 0; i < candidatesCount; i++) {
            emit ElectionResult(candidates[i].name, candidates[i].voteCount);
        }
    }

    function getNumCandidates() public view returns (uint) {
        return candidatesCount;
    }

    function getCandidate(uint _index) public view returns (uint, string memory, uint) {
        require(_index < candidatesCount, "Invalid candidate index");
        Candidate memory candidate = candidates[_index];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
}
