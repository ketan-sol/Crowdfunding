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
        require(
            msg.value >= minContribution,
            "Minimum contribution not satisfied"
        );

        if (contributors[msg.sender] == 0) {
            numberOfContributors++;
        }
        contributors[msg.sender] = contributors[msg.sender] + msg.value;
        raisedAmount = raisedAmount + msg.value;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
