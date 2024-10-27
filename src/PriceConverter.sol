pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(address i_priceFeedAddress) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_priceFeedAddress);

        (, int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount, address i_priceFeedAddress) public view returns (uint256) {
        uint256 ethPrice = getPrice(i_priceFeedAddress);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
}
