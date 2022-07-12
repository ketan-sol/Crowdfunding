//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "hardhat/console.sol";

contract Crowdfunding {
    address public manager;
    uint256 public minContribution;
    uint256 public deadline;
    uint256 public target;
    uint256 public raisedAmount;
    uint256 public numberOfContributors;

    mapping(address => uint256) public contributors;

    struct Request {
        string description;
        address payable recipient;
        uint256 value;
        bool completed;
        uint256 numberOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint256 => Request) public requests;
    uint256 public numberOfRequests;

    constructor(
        uint256 _target,
        uint256 _deadline,
        uint256 _minContribution
    ) {
        target = _target;
        deadline = block.timestamp + _deadline;
        minContribution = _minContribution;
        manager = msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp < deadline, "Deadline has passed");
        require(msg.value >= minContribution, "Minimum contribution not met");

        if (contributors[msg.sender] == 0) {
            numberOfContributors++;
        }
        contributors[msg.sender] = contributors[msg.sender] + msg.value;
        raisedAmount = raisedAmount + msg.value;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function refund() public {
        require(
            block.timestamp > deadline && raisedAmount < target,
            "You are not eligible for refund"
        );
        require(
            contributors[msg.sender] > 0,
            "You are not eligible for refund"
        );
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    function createRequest(
        string memory _description,
        address payable _recipient,
        uint256 _value
    ) public onlyManager {
        Request storage newRequest = requests[numberOfRequests];
        numberOfRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.numberOfVoters = 0;
    }

    function voting(uint256 requestNumber) public {
        require(contributors[msg.sender] > 0, "You must be a contributor");
        Request storage currentRequest = requests[requestNumber];
        require(
            currentRequest.voters[msg.sender] == false,
            "You have already voted"
        );
        currentRequest.voters[msg.sender] = true;
        currentRequest.numberOfVoters++;
    }

    function Payment(uint256 requestNumber) public onlyManager {
        require(raisedAmount >= target, "Insufficient funds");
        Request storage currentRequest = requests[requestNumber];
        require(
            currentRequest.completed == false,
            "The request has already been completed"
        );
        require(
            currentRequest.numberOfVoters > numberOfContributors / 2,
            "no majority"
        );
        currentRequest.recipient.transfer(currentRequest.value);
        currentRequest.completed = true;
    }
}
