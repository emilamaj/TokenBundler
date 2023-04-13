// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./bundleContract.sol";

contract bundleFactory {
    event BundleCreated(address indexed bundleToken);

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
        emit BundleCreated(address(newContract));
        return address(newContract);
    }
}