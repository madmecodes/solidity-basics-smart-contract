// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Import Chainlink's AggregatorV3Interface
// This interface allows us to interact with Chainlink Price Feeds
import {AggregatorV3Interface} from
    "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title PriceConverter
 * @author Your Name
 * @notice A library to convert ETH amounts to USD using Chainlink Price Feeds
 * @dev This demonstrates: libraries, Chainlink oracles, interfaces, decimals
 */
library PriceConverter {
    /**
     * @notice Get the latest ETH/USD price from Chainlink
     * @dev Calls the Chainlink Price Feed to get current price
     * @param priceFeed The Chainlink Price Feed contract
     * @return The current price of ETH in USD (with 18 decimals)
     */
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Chainlink Price Feeds return multiple values, we only need price
        (, int256 price,,,) = priceFeed.latestRoundData();

        // Price comes back with 8 decimal places (e.g., 2000_00000000 for $2000)
        // We need to match ETH's 18 decimal places
        // So we multiply by 1e10 to get 18 decimals total
        return uint256(price) * 1e10; // Price with 18 decimals
    }

    /**
     * @notice Convert ETH amount to USD value
     * @dev Uses the Chainlink Price Feed to get current exchange rate
     * @param ethAmount The amount of ETH (in Wei, 18 decimals)
     * @param priceFeed The Chainlink Price Feed contract
     * @return The USD value (with 18 decimals)
     */
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Get current ETH price in USD (18 decimals)
        uint256 ethPrice = getPrice(priceFeed);

        // Calculate USD value
        // ethPrice has 18 decimals, ethAmount has 18 decimals
        // Multiplying them gives us 36 decimals
        // We divide by 1e18 to bring it back to 18 decimals
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUsd;
    }
}

/*
 * KEY CONCEPTS SUMMARY:
 *
 * 1. LIBRARIES:
 *    - Special type of contract with reusable functions
 *    - Functions are usually 'internal' or 'pure'
 *    - Cannot have state variables (no storage)
 *    - Cannot inherit or be inherited
 *    - Cannot receive Ether
 *    - Deployed separately and linked, or embedded in contracts
 *
 * 2. USING LIBRARIES:
 *    - Import: import {LibraryName} from "path"
 *    - Attach to type: using LibraryName for Type;
 *    - Usage: uint256 usdValue = ethAmount.getConversionRate(priceFeed);
 *    - Or direct call: PriceConverter.getConversionRate(ethAmount, priceFeed);
 *
 * 3. CHAINLINK PRICE FEEDS:
 *    - Decentralized oracle network
 *    - Provides real-world data to smart contracts
 *    - ETH/USD feed gives current exchange rate
 *    - Updated frequently by multiple nodes
 *    - Different addresses on different networks
 *
 * 4. ORACLES:
 *    - Blockchains cannot access external data natively
 *    - Oracles bridge blockchain and real world
 *    - Centralized oracles = single point of failure
 *    - Chainlink = decentralized oracle network
 *    - Multiple independent nodes provide data
 *
 * 5. INTERFACES:
 *    - Contract definitions without implementation
 *    - Used to interact with external contracts
 *    - AggregatorV3Interface defines Chainlink Price Feed functions
 *    - Only need to know function signatures, not implementation
 *
 * 6. DECIMALS IN SOLIDITY:
 *    - Solidity doesn't support decimals/floats natively
 *    - Use integers with implied decimal places
 *    - ETH uses 18 decimals (1 ETH = 1e18 Wei)
 *    - Chainlink uses 8 decimals for prices
 *    - Must align decimals when doing calculations
 *
 * DECIMAL EXAMPLES:
 *
 * ETH: 1 ETH = 1,000,000,000,000,000,000 Wei (18 zeros)
 * Chainlink Price: $2000 = 2000_00000000 (8 decimals)
 *
 * To convert:
 * 1. Get price: 2000_00000000 (8 decimals)
 * 2. Add 10 zeros: 2000_000000000000000000 (18 decimals)
 * 3. Multiply by ETH amount (also 18 decimals)
 * 4. Divide by 1e18 to get back to 18 decimals
 *
 * PRICE FEED EXAMPLE:
 *
 * latestRoundData() returns:
 * - roundId: Round ID of the latest update
 * - answer: The price (8 decimals)
 * - startedAt: Timestamp when round started
 * - updatedAt: Timestamp when round was updated
 * - answeredInRound: Round ID in which answer was computed
 *
 * We only use 'answer' (the price), but all values are returned
 *
 * NETWORK-SPECIFIC PRICE FEEDS:
 *
 * Ethereum Sepolia ETH/USD:
 * 0x694AA1769357215DE4FAC081bf1f309aDC325306
 *
 * Ethereum Mainnet ETH/USD:
 * 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
 *
 * zkSync Sepolia ETH/USD:
 * (Would need to check Chainlink docs for address)
 *
 * See: https://docs.chain.link/data-feeds/price-feeds/addresses
 */
