//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IMintableToken} from "./interfaces/IMintableToken.sol";
import {TokenHolderInfo} from "./Types.sol";

/// @notice BANK token minted 1:1 for depositors by BankVault (owner/minter)
contract MintableToken is ERC20, IMintableToken {
    /// @notice address of the token minter. Only this address will be allowed to mint/burn tokens
    address public minter;

    /// @notice list of token holders
    address[] private _tokenHolders;

    /// @notice mapping of addresses to a whether they are a known holder
    mapping(address => bool) private _knownHoldersLookup;

    /// @notice modifier to protect functions that should only be called by the token minter
    /// @dev allows anyone to mint if the minter address is the dead address. Useful for test envs
    modifier onlyTokenMinter() {
        if (minter != address(0x0)) {
            require(msg.sender == minter, "unauthorized");
        }

        _;
    }

    constructor(address _minter, string memory name, string memory symbol) ERC20(name, symbol) {
        minter = _minter;
    }

    /// @inheritdoc ERC20
    function transfer(address to, uint256 value) public virtual override(ERC20, IERC20) returns (bool) {
        _registerTokenHolder(to);

        return super.transfer(to, value);
    }

    /// @inheritdoc ERC20
    function transferFrom(address from, address to, uint256 value)
        public
        virtual
        override(ERC20, IERC20)
        returns (bool)
    {
        _registerTokenHolder(to);

        return super.transferFrom(from, to, value);
    }

    /// @notice Mint the tokens to the specified address
    function mint(uint256 amount, address to) public onlyTokenMinter {
        _mint(to, amount);
        _registerTokenHolder(to);
    }

    /// @notice Burn the tokens owned by the specified address
    function burn(uint256 amount, address owner) public onlyTokenMinter {
        _burn(owner, amount);
        _registerTokenHolder(owner);
    }

    /**
     * @notice Get the amount of tokens held by all token owners
     */
    function getTokenHolderInfo() public view returns (TokenHolderInfo[] memory infos) {
        address[] memory holders = _tokenHolders;

        infos = new TokenHolderInfo[](holders.length);

        for (uint256 i = 0; i < holders.length; i++) {
            address holder = holders[i];
            uint256 balance = this.balanceOf(holder);

            infos[i] = TokenHolderInfo({account: holder, balance: balance});
        }
    }

    /**
     * @notice Add a new token holder if they do not currently exists
     *
     * @param holder The token holder to conditionally add
     */
    function _registerTokenHolder(address holder) private {
        if (_knownHoldersLookup[holder] == true) {
            return;
        }

        _knownHoldersLookup[holder] = true;
        _tokenHolders.push(holder);
    }
}
