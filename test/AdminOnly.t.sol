// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {AdminOnly} from "../src/AdminOnly.sol";

contract AdminOnlyTest is Test {
    AdminOnly public adminOnly;

    receive() external payable {}

    function setUp() public {
        adminOnly = new AdminOnly();
    }

    function testIfOwnerSetCorrectly() public view {
        assertEq(adminOnly.owner(), address(this));
    }

    function testIfAddTreasureWorksPerfectly() public {
        address owner = adminOnly.owner();
        adminOnly.addTreasure{value: 1 ether}();
        adminOnly.addTreasure{value: 1 ether}();
        assertEq(adminOnly.treasurAmount(), 2 ether);
        assertEq(adminOnly.withdrawAllowance(owner), 2 ether);
    }

    function testIfAddTreasurRevertWhenNotOwner() public {
        address sinclair = address(0x1);

        vm.deal(sinclair, 2 ether);

        vm.expectRevert();

        vm.prank(sinclair);

        adminOnly.addTreasure{value: 1 ether}();
    }

    function testApproveWithdrawRevertWhenValueIsLessThanAmount() public {
        address sinclair = address(0x1);
        adminOnly.addTreasure{value: 1 ether}();

        vm.expectRevert();
        adminOnly.approveWithdraw(sinclair, 2 ether);
    }

    function testApproveWithdrawWorksPerfectly() public {
        address sinclair = address(0x1);
        adminOnly.addTreasure{value: 1 ether}();

        adminOnly.approveWithdraw(sinclair, 0.5 ether);
        assertEq(adminOnly.withdrawAllowance(sinclair), 0.5 ether);
        assertEq(adminOnly.allowWithdrawal(sinclair), true);

        vm.expectRevert();
        adminOnly.approveWithdraw(sinclair, 2 ether);
    }

    function testTransferOwnerWorkForOnlyOwner() public {
        address sinclair = address(0x1);
        address addy = address(0x2);

        vm.prank(sinclair);
        vm.expectRevert();

        adminOnly.transferOwner(addy);
    }

    function testTransferOwnerWorkForOnlyOwnerAndRevertForAddyZero() public {
        address sinclair = address(0x1);
        address addy = address(0x0);

        //work for normal addy
        adminOnly.transferOwner(sinclair);
        assertEq(adminOnly.owner(), sinclair);

        vm.expectRevert();
        adminOnly.transferOwner(addy);
    }

    function testCheckTreasureAmount() public {
        adminOnly.addTreasure{value: 1 ether}();

        assertEq(adminOnly.checkTreasureAmount(), 1 ether);

        //revert if another user try to check
        address sinclair = address(0x1);

        vm.prank(sinclair);
        vm.expectRevert();
        adminOnly.checkTreasureAmount();
    }

    function testCheckTreasureAmountRevertWhenTriedByAnotherUser() public {
        //revert if another user try to check
        address sinclair = address(0x1);

        vm.prank(sinclair);
        vm.expectRevert();
        adminOnly.checkTreasureAmount();
    }

    function testResetWithdrawStatus() public {
        address sinclair = address(0x1);
        adminOnly.addTreasure{value: 1 ether}();

        adminOnly.approveWithdraw(sinclair, 0.5 ether);
        adminOnly.resetWithdrawStatus(0.2 ether, sinclair);

        assertEq(adminOnly.withdrawAllowance(sinclair), 0.2 ether);
    }

    function testWithdrawByOwner() public {
        address owner = adminOnly.owner();

        vm.deal(owner, 2 ether);

        adminOnly.addTreasure{value: 1 ether}();

        uint256 balanceBefore = address(this).balance;
        console.log(balanceBefore);

        adminOnly.withdrawAmountByUser(0.5 ether);
        uint256 balanceAfter = address(this).balance;
        console.log(balanceAfter);

        assertEq(adminOnly.treasurAmount(), 0.5 ether);
    }

    function testOwnerCanWithdraw() public {
        adminOnly.addTreasure{value: 1 ether}();

        uint256 initialOwnerBalance = address(this).balance;

        adminOnly.withdrawAmountByUser(0.5 ether);

        assertEq(adminOnly.treasurAmount(), 0.5 ether);
        assertGt(address(this).balance, initialOwnerBalance); // Received funds
    }

    function testOwnerCannotWithdrawMoreThanTreasure() public {
        adminOnly.addTreasure{value: 1 ether}();

        vm.expectRevert("Not enough");
        adminOnly.withdrawAmountByUser(2 ether);
    }

    function testNonApprovedUserCannotWithdraw() public {
        address sinclair = address(0x1);
        vm.deal(address(adminOnly), 1 ether);
        adminOnly.addTreasure{value: 1 ether}();

        vm.prank(sinclair);
        vm.expectRevert("Not Allowed");
        adminOnly.withdrawAmountByUser(0.1 ether);
    }

    function testUserCannotWithdrawMoreThanAllowance() public {
        address sinclair = address(0x1);
        vm.deal(address(adminOnly), 1 ether);
        adminOnly.addTreasure{value: 1 ether}();
        adminOnly.approveWithdraw(sinclair, 0.4 ether);

        vm.prank(sinclair);
        vm.expectRevert("Not enough");
        adminOnly.withdrawAmountByUser(0.5 ether);
    }

    function testApprovedUserCanWithdraw() public {
        address sinclair = address(0x1);
        vm.deal(address(adminOnly), 1 ether);
        vm.deal(sinclair, 0); // start with 0 ETH
        adminOnly.addTreasure{value: 1 ether}();
        adminOnly.approveWithdraw(sinclair, 0.4 ether);

        vm.prank(sinclair);
        adminOnly.withdrawAmountByUser(0.4 ether);

        assertEq(adminOnly.treasurAmount(), 0.6 ether);
        assertEq(adminOnly.withdrawAllowance(sinclair), 0); // all withdrawn
    }

    function testUserPartialWithdrawThenRemaining() public {
        address sinclair = address(0x1);
        vm.deal(address(adminOnly), 1 ether);
        adminOnly.addTreasure{value: 1 ether}();
        adminOnly.approveWithdraw(sinclair, 0.8 ether);

        // First withdrawal
        vm.prank(sinclair);
        adminOnly.withdrawAmountByUser(0.3 ether);
        assertEq(adminOnly.withdrawAllowance(sinclair), 0.5 ether);
        assertEq(adminOnly.treasurAmount(), 0.7 ether);

        // Second withdrawal
        vm.prank(sinclair);
        adminOnly.withdrawAmountByUser(0.5 ether);
        assertEq(adminOnly.withdrawAllowance(sinclair), 0 ether);
        assertEq(adminOnly.treasurAmount(), 0.2 ether);
    }

    function testUserFailsIfWithdrawAmountEqualsZero() public {
        address sinclair = address(0x1);
        vm.deal(address(adminOnly), 1 ether);
        adminOnly.addTreasure{value: 1 ether}();
        adminOnly.approveWithdraw(sinclair, 0.5 ether);

        vm.prank(sinclair);
        vm.expectRevert(); // will fail on low-level call returning false
        adminOnly.withdrawAmountByUser(0 ether);
    }
}
