// Foundry test file for BundleFactory.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../forge-std/Test.sol";
import "../forge-std/StdUtils.sol";
import "../forge-std/console.sol";

import "../Contracts/BundleFactory.sol";
import "../Contracts/BundleContract.sol";
import "../Contracts/CustomERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract FactoryTest is BundleFactory, Test {
    using SafeERC20 for IERC20;
    
    BundleContract bundle;
    string constant bname = "Bundled USD";
    string constant bsymbol = "bdUSD";
    address constant _usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT, 6 decimals
    address constant _dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI, 18 decimals
    address constant _usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC, 6 decimals
    address constant _weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH, 18 decimals

    function setUp() public {
        address[] memory tokens = new address[](3);
        tokens[0] = _usdt;
        tokens[1] = _dai;
        tokens[2] = _usdc;

        uint256[] memory proportions = new uint256[](3);
        proportions[0] = 1e6; // 1 USDT
        proportions[1] = 1e18; // 1 DAI
        proportions[2] = 1e6; // 1 USDC
        // 3 bdUSD = 1 USDT + 1 DAI + 1 USDC

        address bundleAddress = createBundleContract(bname, bsymbol, 3e18, tokens, proportions);
        bundle = BundleContract(bundleAddress);
    }
    
    function test_Burn() public {
        // Fund the factory contract with tokens
        deal(_usdt, address(this), 1e6); // Fund 1 USDT
        deal(_dai, address(this), 1e18); // Fund 1 DAI
        deal(_usdc, address(this), 1e6); // Fund 1 USDC

        // Approve bundle contract to spend tokens
        IERC20(_usdt).safeApprove(address(bundle), 1e6);
        IERC20(_dai).safeApprove(address(bundle), 1e18);
        IERC20(_usdc).safeApprove(address(bundle), 1e6);

        // Mint bundle token units
        bundle.mint(3e18, address(this)); // Mint 3 bdUSD

        // Burn bundle token units
        bundle.burn(3e18, address(this)); // Burn 3 bdUSD and send the base tokens back to this contract

        // Check balances
        assertEq(bundle.balanceOf(address(this)), 0, "Bundle balance mismatch");
        assertEq(IERC20(_usdt).balanceOf(address(this)), 1e6, "USDT balance mismatch");
        assertEq(IERC20(_dai).balanceOf(address(this)), 1e18, "DAI balance mismatch");
        assertEq(IERC20(_usdc).balanceOf(address(this)), 1e6, "USDC balance mismatch");
    }

    function testFuzz_MintMultiple(uint256 tokenCount, uint256 bundleAmount) public { // Fuzz test: mint bundles of N different tokens
        vm.assume(tokenCount > 0 && tokenCount <= 1e3); // Assume tokenCount is a reasonable number
        vm.assume(bundleAmount > 0); // Assume bundleAmount is strictly positive

        // Deploy 'tokenCount' ERC20 tokens
        address[] memory tokens = new address[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokens[i] = new 
        }
}