// Smart contract for a regular OpenZeppelin ERC20 token, but with the possibility to set on deploy the following parameters:
// - name
// - symbol
// - decimals
// - initial supply

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomERC20 is ERC20 {
    uint8 _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimalPoints,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _decimals = decimalPoints;
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
