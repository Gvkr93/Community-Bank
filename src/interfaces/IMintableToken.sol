//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokenHolderInfo} from "../Types.sol";

interface IMintableToken is IERC20 {
    function mint(uint256 amount, address to) external;

    function burn(uint256 amount, address owner) external;

    function getTokenHolderInfo() external view returns (TokenHolderInfo[] memory infos);
}
