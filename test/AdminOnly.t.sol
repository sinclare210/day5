// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {AdminOnly} from "../src/AdminOnly.sol";

contract AdminOnlyTest is Test {

    AdminOnly public adminOnly;

   
   function setUp() public {
        adminOnly = new AdminOnly();
   }

   function testIfOwnerSetCorrectly () public view{
        assertEq(adminOnly.owner(), address(this));
   }

   function testIfAddTreasureWorksPerfectly () public {
    address owner = adminOnly.owner();
        adminOnly.addTreasure{value: 1 ether}();
        adminOnly.addTreasure{value: 1 ether}();
        assertEq(adminOnly.treasurAmount(), 2 ether);
        assertEq(adminOnly.withdrawAllowance(owner), 2 ether);

   }

   function testIfAddTreasurRevertWhenNotOwner () public{

        address sinclair = address(0x1);

        vm.deal(sinclair, 2 ether);

        vm.expectRevert();

        vm.prank(sinclair);

        adminOnly.addTreasure{value: 1 ether}();

    }

    function testApproveWithdrawRevertWhenValueIsLessThanAmount () public {

        address sinclair = address(0x1);
        adminOnly.addTreasure{value: 1 ether}();
        
        vm.expectRevert();
        adminOnly.approveWithdraw(sinclair, 2 ether);

    }




}