# Token Bundler

This token bundler lets you create synthetic ERC20-compatible assets by wrapping together multiple tokens in predetermined proportions.
This permissionless system allows anyone to create a new token bundle, and anyone to trade it on Uniswap or other AMMs.
Users can mint a given token bundle by depositing the underlying tokens, and redeem the underlying tokens by burning the token bundle.

Todo:
- [ ] Add automated tests
- [ ] Add user interface for creating token bundles
- [ ] Add UI for minting and burning token bundles
- [ ] Add UI for exploring the pricing opportunities of token bundles

## Smart Contracts

### BundleFactory.sol: 
The contract the creates and deploys the token bundles. It is the only contract that needs to be manually deployed. \

- `createBundleContract(string name, string symbol, uint256 _bundleAmount, address[] _tokens, uint256[] _proportions)`: Creates a new token bundle contract and deploys it. \
The token bundle contract is deployed with the given name, symbol, and bundles the given tokens in the given proportions: \
- `name`: The name of the token bundle e.g. "Bundled USD". \
- `symbol`: The symbol of the token bundle e.g. "bdUSD". \
- `_bundleAmount`: The amount of the token bundle that is minted when the underlying tokens are deposited. **Note that a bundle token always has 18 decimals**\
- `_tokens`: Addresses of the tokens that are bundled. \
- `_proportions`: Proportions of the tokens in the bundle. **Care must be taken as to ensure that the token decimals are taken into account.** \

To bundle USDT (6 decimals) and DAI (18 decimals) in a 1:1 ratio, the proportions should be `[1e6, 1e18]` and the bundle amount should be `2e18`. Alternatively, the proportions could be `[1, 1e12]` and the bundle amount could be `2e12`. That way, when the user deposits 1 USDT and 1 DAI, they receive 2 bdUSD. \


### BundleContract.sol: 
The contract that is deployed for each token bundle. It is deployed by the BundleFactory contract. \
It has the usual interface of an ERC20 token, on top of which are implemented the `mint` and `burn` functions: \

- `mint(uint256 amount, address recipient)`: Mints the given amount of the token bundle units and sends it to the given recipient. \
The msg.sender must already possess a sufficient amount of the underlying tokens (which is `amount*proportion[i]/bundleAmount` for each base token). \
The BundleContract of token bundle which is about to be minted must have already been approved by the msg.sender for spending the underlying tokens. \

- `burn(uint256 amount, address recipient)`: Burns the given amount of the token bundle and sends the underlying tokens to the given recipient. \
The msg.sender must already possess a sufficient amount of the token bundle (`balanceOf(msg.sender) >= amount`). \
