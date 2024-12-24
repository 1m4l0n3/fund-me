// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FuneMeTest is Test {
    FundMe public fundMe;
    DeployFundMe public deployFundMe;
    address i_owner;
    address testUser = makeAddr("Joe");
    uint256 testMoney = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint8 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(testUser);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function setUp() public {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        i_owner = fundMe.getOwner();
        deal(testUser, testMoney);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(i_owner, msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutMinimumEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testShouldUpdateFundersAmountWhenTheyFund() public funded {
        uint256 actualFundedAmount = fundMe.getFundedAmount(testUser);

        assertEq(actualFundedAmount, SEND_VALUE);
    }

    function testShouldUpdateFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, testUser);
    }

    function testWithdrawShouldFailWithNonOwner() public funded {
        vm.prank(testUser);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testOwnerShouldWithdrawAllTheFunds() public {
        uint256 noOfFunders = 10;
        for (uint160 index = 1; index <= noOfFunders; index++) {
            hoax(address(index), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 ownerMoneyBeforeWithdraw = i_owner.balance;
        uint256 fundMeMoneyBeforeWithdraw = address(fundMe).balance;

        vm.prank(i_owner);
        fundMe.withdraw();

        uint256 ownerMoneyAfterWithdraw = i_owner.balance;
        uint256 fundMeMoneyAfterWithdraw = address(fundMe).balance;
        assertEq(fundMeMoneyAfterWithdraw, 0);
        assertEq(
            ownerMoneyBeforeWithdraw + fundMeMoneyBeforeWithdraw,
            ownerMoneyAfterWithdraw
        );
    }
}
