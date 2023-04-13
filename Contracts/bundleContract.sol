// This is the smart contract for the token bundle. It is initialized by the bundleFactory.sol contract
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract bundleContract is ERC20 {
    using SafeMath for uint256;

    address[] public tokens;
    uint256[] public proportions;
    uint256 public totalProportions;

    constructor(
        string memory name,
        string memory symbol,
        address[] memory _tokens,
        uint256[] memory _proportions
    ) ERC20(name, symbol) {
        require(
            _tokens.length == _proportions.length,
            "Tokens and proportions arrays must have the same length"
        );
        tokens = _tokens;
        proportions = _proportions;

        for (uint256 i = 0; i < _proportions.length; i++) {
            totalProportions = totalProportions.add(_proportions[i]);
        }
    }

    function mint(uint256 amount) external {
        require(tokens.length > 0, "No tokens in the bundle");

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenAmount = amount.mul(proportions[i]).div(totalProportions);
            IERC20(tokens[i]).transferFrom(msg.sender, address(this), tokenAmount);
        }
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount, address to) external {
        _burn(msg.sender, amount);

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenAmount = amount.mul(proportions[i]).div(totalProportions);
            IERC20(tokens[i]).transfer(to, tokenAmount);
        }
    }
}