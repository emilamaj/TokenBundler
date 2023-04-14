// This smart contract allows you to create a bundle of tokens. The bundle is made out of base tokens in various proportions that can be minted and burned by the users, but follows the ERC20 standard for any other purpose.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract bundleContract is ERC20 {
    address[] public tokens;
    uint256[] public proportions;
    uint256 public totalProportions;

    constructor(
        string memory name,
        string memory symbol,
        address[] memory _tokens,
        uint256[] memory _proportions
    ) ERC20(name, symbol) {
        tokens = _tokens;
        proportions = _proportions;

        for (uint256 i = 0; i < _proportions.length; i++) {
            totalProportions += _proportions[i];
        }
    }

    // This function allows you to mint some amount of the token bundle. The tokens must first be sent to the bundleContract.
    function mint(uint256 amount, address recipient) external {
        _mint(recipient, amount);
    }
    
    // This function allows you to mint some amount of the token bundle. The tokens must first be approved to be spent by the bundleContract on the behalf of msg.sender
    function mintFrom(uint256 amount, address recipient) external {
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenAmount = amount * proportions[i] / totalProportions;
            IERC20(tokens[i]).transferFrom(msg.sender, address(this), tokenAmount);
        }
        _mint(recipient, amount);
    }

    // This function allows you to burn some amount of token bundle. The tokens will be sent to the recipient.
    function burn(uint256 amount, address recipient) external {
        _burn(msg.sender, amount);

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenAmount = amount * proportions[i] / totalProportions;
            IERC20(tokens[i]).transfer(recipient, tokenAmount);
        }
    }
}