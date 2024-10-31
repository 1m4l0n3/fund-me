// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;
import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 public constant SEND_VALUE = 0.1 ether;

    function run() external {
        address mostRecentFundMeDeployment = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentFundMeDeployment);
    }

    function fundFundMe(address mostRecentlyDeployedContractAddress) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedContractAddress)).fund{
            value: SEND_VALUE
        }();
        vm.stopBroadcast();
        console.log("Deposit done with amount %s", SEND_VALUE);
    }
}

contract WithdrawFundMe is Script {
    function run() external {
        address mostRecentlyDeployedContractAddress = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployedContractAddress);
    }

    function withdrawFundMe(address mostRecentlyDeployedContractAddress)
        public
    {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedContractAddress)).withdraw();
        vm.stopBroadcast();
    }
}
