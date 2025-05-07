// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


contract AdminOnly {
    address public owner;
    uint256 public treasurAmount;
    mapping (address => uint256) public withdrawAllowance;
    mapping (address => bool) public allowWithdrawal;

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
        allowWithdrawal[addy] = true;
    }

    function withdrawAmountByUser(uint256 amount) public {
        require (amount > 0, "Not ALLOWED");
    if (msg.sender == owner) {
        require(amount <= treasurAmount, "Not enough");
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Failed");
        treasurAmount -= amount;
        return; // ✅ Stop execution here
    }

    require(allowWithdrawal[msg.sender], "Not Allowed");
    require(withdrawAllowance[msg.sender] >= amount, "Not enough");  // ✅ Fix comparison

    withdrawAllowance[msg.sender] -= amount;
    treasurAmount -= amount;

    (bool success,) = msg.sender.call{value: amount}("");
    require(success, "Failed");
}


    function resetWithdrawStatus(uint256 amount, address addy) public onlyOwner{
        
         require (allowWithdrawal[addy],"Not Allowed");
         withdrawAllowance[addy] = amount;
    }

    function transferOwner (address addy) public onlyOwner {
        require(addy != address(0),"Not allowed");
        owner = addy;
    }

    function checkTreasureAmount () public onlyOwner view returns(uint256) {
        return treasurAmount;
    }

}