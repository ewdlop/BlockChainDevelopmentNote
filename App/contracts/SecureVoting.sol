// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureVoting {
    struct Voter {
        bool voted;
        uint8 vote; // Index of the voted proposal
        bool authorized;
    }

    struct Proposal {
        string name;
        uint256 voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    event VoterAuthorized(address voter);
    event VoteCast(address voter, uint8 proposal);

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can call this function.");
        _;
    }

    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function authorizeVoter(address voter) public onlyChairperson {
        require(!voters[voter].authorized, "Voter is already authorized.");
        voters[voter].authorized = true;
        emit VoterAuthorized(voter);
    }

    function vote(uint8 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.authorized, "You are not authorized to vote.");
        require(!sender.voted, "You have already voted.");
        require(proposal < proposals.length, "Invalid proposal.");

        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += 1;

        emit VoteCast(msg.sender, proposal);
    }

    function winningProposal() public view returns (uint8 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint8 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() public view returns (string memory winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}
