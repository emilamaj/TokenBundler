// This smart contract allows you to mint/burn a bundle of tokens. The bundle is made out of base tokens in various proportions that can be minted and burned by the users, but follows the ERC20 standard for any other purpose.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BundleContract is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address[] public tokens; // Base tokens that make up the bundle
    uint256[] public proportions; // Proportions of each base token in the bundle
    uint256 public bundleAmount; // Amount of token units minted when base tokens are provided in the same amounts as the proportions.

    /// @notice Emitted when a new bundle is minted.
    event Minted(address indexed recipient, uint256 amount);

    /// @notice Emitted when a bundle is burned.
    event Burned(address indexed sender, uint256 amount);

    /// @dev Initializes the token bundle contract.
    /// @param name The name of the token bundle.
    /// @param symbol The symbol of the token bundle.
    /// @param _bundleAmount The amount of token units minted per unit of base tokens provided (wrt proportions).
    /// @param _tokens The array of token addresses in the bundle.
    /// @param _proportions The array of proportions for each token in the bundle.
    constructor(string memory name, string memory symbol, uint256 _bundleAmount, address[] memory _tokens, uint256[] memory _proportions) ERC20(name, symbol) {
        // Array checks
        require(_tokens.length == _proportions.length, "Tokens and proportions length mismatch");
        require(_tokens.length > 0, "Tokens length must be greater than 0");
        require(_bundleAmount > 0, "Bundle amount must be greater than 0");

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

        bundleAmount = _bundleAmount;
        tokens = _tokens;
        proportions = _proportions;
    }

    /// @notice Mints a token bundle and sends it to the recipient.
    /// @dev The tokens must first be approved to be spent by the BundleContract on behalf of msg.sender.
    /// @param amount The amount of the token bundle to mint.
    /// @param recipient The address to receive the minted token bundle.
    function mint(uint256 amount, address recipient) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(recipient != address(0), "Recipient cannot be the zero address");

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenAmount = amount * proportions[i] / bundleAmount;
            IERC20(tokens[i]).safeTransferFrom(msg.sender, address(this), tokenAmount);
        }

        _mint(recipient, amount);
        emit Minted(recipient, amount);
    }

    /// @notice Burns a token bundle and sends the underlying tokens to the recipient.
    /// @param amount The amount of the token bundle to burn.
    /// @param recipient The address to receive the underlying tokens after burning the token bundle.
    function burn(uint256 amount, address recipient) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(recipient != address(0), "Recipient cannot be the zero address");
        _burn(msg.sender, amount); // OpenZeppelin's ERC20.sol has a _burn function that checks if the user has enough tokens to burn

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenAmount = amount * proportions[i] / bundleAmount;
            IERC20(tokens[i]).safeTransfer(recipient, tokenAmount);
        }

        emit Burned(msg.sender, amount);
    }
}
