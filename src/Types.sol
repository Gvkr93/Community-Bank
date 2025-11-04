//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IMintableToken} from "./interfaces/IMintableToken.sol";

enum LoanStatus {
    Unknown,
    Pending,
    Open,
    Closed,
    Rejected
}

struct LoanInfo {
    bytes32 id;
    LoanStatus status;
    address borrower;
    string details;
    uint256 amount;
    uint256 collateral;
    uint256 term;
    uint256 interestRate;
    uint256 remainingBalance;
    uint256 originalBalance;
    uint256 totalPaymentAmount;
    uint256 principalAmountPerDollarOwed;
    IMintableToken token;
}

struct TokenHolderInfo {
    address account;
    uint256 balance;
}
