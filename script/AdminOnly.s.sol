// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract AdminOlny {
    address public owner;
    uint256 public treasurAmount;
    mapping (address => uint256) public withdrawAllowance;
    mapping (address => bool) public hasWithdrawn;

    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner () {
        require(owner == msg.sender,"Not authorised");
        _;
    }

    function addTreasure() public payable onlyOwner {
        treasurAmount += msg.value;
        withdrawAllowance[msg.sender] += msg.value;
    }

    function approveWithdraw(address addy, uint256 amount) public onlyOwner payable {
        require(amount < treasurAmount, "Not enough");
        withdrawAllowance[addy] = amount;
    }

    function withdrawAmountByUser (uint256 amount) public {

        if(owner == msg.sender){
            require(amount < treasurAmount, "Not enough");
            (bool success,) = msg.sender.call{value:amount}("");
            require(success, "Failed");
            treasurAmount -= amount;
        }
        require(withdrawAllowance[msg.sender] <= amount, "Not enough");
        withdrawAllowance[msg.sender] -= amount;
        treasurAmount -= amount;
        (bool success,) = msg.sender.call{value:amount}("");
        require(success, "Failed");
    }






}