//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IBankVault {
    function distributeToStakers(address token, uint256 amount) external;
}
