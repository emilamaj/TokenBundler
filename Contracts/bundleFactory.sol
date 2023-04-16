// This smart contract is used to create a new bundle contract.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BundleContract.sol";

contract BundleFactory {
    event BundleCreated(address indexed bundleToken, string name, string symbol, address[] tokens, uint256[] proportions, address indexed creator);

    /// @notice Creates a new bundle contract.
    /// @param name The name of the token bundle.
    /// @param symbol The symbol of the token bundle.
    /// @param tokens The array of token addresses in the bundle.
    /// @param proportions The array of proportions for each token in the bundle.
    /// @return bundleAddress The address of the newly created bundle contract.
    function createBundleContract(
        string memory name,
        string memory symbol,
        uint256 bundleAmount,
        address[] memory tokens,
        uint256[] memory proportions
    ) public returns (address bundleAddress) {
        require(tokens.length == proportions.length, "Tokens and proportions length mismatch");
        require(tokens.length > 0, "Tokens length must be greater than 0");

        BundleContract newContract = new BundleContract(
            name,
            symbol,
            bundleAmount,
            tokens,
            proportions
        );
        emit BundleCreated(address(newContract), name, symbol, tokens, proportions, msg.sender);
        bundleAddress = address(newContract);
    }
}
