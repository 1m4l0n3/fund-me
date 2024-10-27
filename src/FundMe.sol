// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();
error NoMinimumFunds();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) investersAmount;
    address[] investers;
    address public i_owner;
    AggregatorV3Interface private s_priceFeed;
    uint256 public constant MINIMUM_USD = 5 * 10**18;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        if (msg.value.getConversionRate() < MINIMUM_USD) {
            revert NoMinimumFunds();
        }
        if (investersAmount[msg.sender] == 0) {
            investers.push(msg.sender);
        }
        investersAmount[msg.sender] += msg.value;
    }

    modifier owner_only() {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    function withdraw() public owner_only {
        for (uint256 index = 0; index <= investers.length; index++) {
            address invester = investers[index];
            investersAmount[invester] = 0;
        }
        investers = new address[](0);

        (bool withdrawSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(withdrawSuccess, "Withdraw Failed!");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }
}
