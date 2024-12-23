// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CodeReview {

    enum Status { Pending, Approved, Rejected }

    struct CodeSubmission {
        address submitter;
        string codeHash;  // Store a hash of the code to verify integrity
        string description;
        Status status;
        address[] approvals;  // Addresses of reviewers who approved
    }

    address public owner;
    mapping(uint256 => CodeSubmission) public submissions;
    uint256 public submissionCount;
    uint256 public requiredApprovals;

    event CodeSubmitted(uint256 indexed submissionId, address indexed submitter, string codeHash);
    event CodeReviewed(uint256 indexed submissionId, address indexed reviewer, Status status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier onlySubmitter(uint256 submissionId) {
        require(msg.sender == submissions[submissionId].submitter, "Only submitter can call this function.");
        _;
    }

    modifier onlyPending(uint256 submissionId) {
        require(submissions[submissionId].status == Status.Pending, "Submission is not pending.");
        _;
    }

    constructor(uint256 _requiredApprovals) {
        owner = msg.sender;
        requiredApprovals = _requiredApprovals;
    }

    function submitCode(string memory codeHash, string memory description) public {
        submissions[submissionCount] = CodeSubmission({
            submitter: msg.sender,
            codeHash: codeHash,
            description: description,
            status: Status.Pending,
            approvals: new address[](0)
        });

        emit CodeSubmitted(submissionCount, msg.sender, codeHash);
        submissionCount++;
    }

    function approveCode(uint256 submissionId) public onlyPending(submissionId) {
        CodeSubmission storage submission = submissions[submissionId];

        for (uint i = 0; i < submission.approvals.length; i++) {
            require(submission.approvals[i] != msg.sender, "You have already approved this submission.");
        }

        submission.approvals.push(msg.sender);

        if (submission.approvals.length >= requiredApprovals) {
            submission.status = Status.Approved;
        }

        emit CodeReviewed(submissionId, msg.sender, submission.status);
    }

    function rejectCode(uint256 submissionId) public onlyPending(submissionId) {
        CodeSubmission storage submission = submissions[submissionId];
        submission.status = Status.Rejected;

        emit CodeReviewed(submissionId, msg.sender, Status.Rejected);
    }

    function updateRequiredApprovals(uint256 _requiredApprovals) public onlyOwner {
        requiredApprovals = _requiredApprovals;
    }

    function getApprovals(uint256 submissionId) public view returns (address[] memory) {
        return submissions[submissionId].approvals;
    }
}
