// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();
error NoMinimumFunds();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_investersAmount;
    address[] s_investers;
    address public i_owner;
    address private s_priceFeedAddress;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeedAddress = priceFeedAddress;
    }

    function fund() public payable {
        if (msg.value.getConversionRate(s_priceFeedAddress) < MINIMUM_USD) {
            revert NoMinimumFunds();
        }
        if (s_investersAmount[msg.sender] == 0) {
            s_investers.push(msg.sender);
        }
        s_investersAmount[msg.sender] += msg.value;
    }

    modifier owner_only() {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    function withdraw() public owner_only {
        for (uint256 index = 0; index <= s_investers.length; index++) {
            address invester = s_investers[index];
            s_investersAmount[invester] = 0;
        }
        s_investers = new address[](0);

        (bool withdrawSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(withdrawSuccess, "Withdraw Failed!");
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeedAddress);
        return priceFeed.version();
    }

    function getFundedAmount(address investerAddress) public view returns (uint256) {
        return s_investersAmount[investerAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_investers[index];
    }
}
