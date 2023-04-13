// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./bundleContract.sol";

contract bundleFactory {
    function createBundleContract(
        string memory name,
        string memory symbol,
        address[] memory tokens,
        uint256[] memory proportions
    ) public returns (address) {
        bundleContract newContract = new bundleContract(
            name,
            symbol,
            tokens,
            proportions
        );
        return address(newContract);
    }
}