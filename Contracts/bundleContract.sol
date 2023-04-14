// This smart contract allows you to create a bundle of tokens. The bundle is made out of base tokens in various proportions that can be minted and burned by the users, but follows the ERC20 standard for any other purpose.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // No need to use SafeMath since solidity 0.8+ has integrated protection

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract bundleContract is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address[] public tokens;
    uint256[] public proportions;
    uint256 public totalProportions;
    
    event Minted(address indexed recipient, uint256 amount);
    event Burned(address indexed sender, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        address[] memory _tokens,
        uint256[] memory _proportions
    ) ERC20(name, symbol) {
        // Array checks
        require(_tokens.length == _proportions.length, "Tokens and proportions length mismatch");
        require(_tokens.length > 0, "Tokens length must be greater than 0");
        
        // Ensure no duplicate token addresses
        for (uint256 i = 0; i < _tokens.length; i++) {
            for (uint256 j = i + 1; j < _tokens.length; j++) {
                require(_tokens[i] != _tokens[j], "Duplicate token address found");
            }
        }

        // Ensure no zero proportions
        for (uint256 i = 0; i < _proportions.length; i++) {
            require(_proportions[i] > 0, "Proportion cannot be zero");
        }

        tokens = _tokens;
        proportions = _proportions;

        for (uint256 i = 0; i < _proportions.length; i++) {
            totalProportions += _proportions[i];
        }
    }
    
    // This function allows you to mint some amount of the token bundle. The tokens must first be approved to be spent by the bundleContract on the behalf of msg.sender
    function mint(uint256 amount, address recipient) external nonReentrant { // 'nonReentrant' modifier is not strictly necessary here, but it's good practice
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenAmount = amount * proportions[i] / totalProportions;
            IERC20(tokens[i]).safeTransferFrom(msg.sender, address(this), tokenAmount);
        }

        _mint(recipient, amount);
        emit Minted(recipient, amount);
    }
    
    // This function allows you to burn some amount of token bundle. The tokens will be sent to the recipient.
    function burn(uint256 amount, address recipient) external nonReentrant { // 'nonReentrant' modifier is not strictly necessary here.
        _burn(msg.sender, amount); // OpenZeppelin's ERC20.sol has a _burn function that checks if the user has enough tokens to burn

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenAmount = amount * proportions[i] / totalProportions;
            IERC20(tokens[i]).safeTransfer(recipient, tokenAmount);
        }

        emit Burned(msg.sender, amount);
    }
}