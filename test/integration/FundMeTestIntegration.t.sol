// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract IntegrationTest is Test {
    DeployFundMe deployFundMe;
    FundMe public fundMe;

    uint256 constant SEND_VALUE = 0.1 ether;

    address alice = makeAddr("alice");

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(alice, SEND_VALUE);
    }

    function testUserCanFundAndOwnerCanWithdraw() public {
        uint256 preUserBalance = address(alice).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 postUserBalance = address(alice).balance;
        uint256 postOwnerBalance = address(fundMe.getOwner()).balance;
        assertEq(address(fundMe).balance, 0);
        assertEq(postUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, postOwnerBalance);
    }
}
