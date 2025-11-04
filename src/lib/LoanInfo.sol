//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IMintableToken} from "../interfaces/IMintableToken.sol";
import {MintableToken} from "../MintableToken.sol";
import {LoanInfo, LoanStatus} from "../Types.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

library LoanInfoLib {
    error LoanNotFound();
    error InvalidLoanStatusForOperation();
    error InvalidPaymentAmountForLoanBalance();

    function processPayment(
        mapping(bytes32 => LoanInfo) storage self,
        bytes32 id,
        uint256 amount,
        address repaymentToken
    ) internal returns (LoanInfo memory) {
        LoanInfo memory loan = self[id];

        // make sure the loan can be modified. Only loans in the open state can be paid on
        if (loan.status == LoanStatus.Unknown) {
            revert LoanNotFound();
        } else if (loan.status != LoanStatus.Open) {
            revert InvalidLoanStatusForOperation();
        }

        // ensure the payment is not more than the remaining balance
        if (loan.remainingBalance < amount) {
            revert InvalidPaymentAmountForLoanBalance();
        }

        // transfer funds and update remaining loan balance
        IERC20(repaymentToken).transferFrom(loan.borrower, address(this), amount);

        loan.remainingBalance -= amount;

        if (loan.remainingBalance == 0) {
            loan.status = LoanStatus.Closed;
        }

        self[id] = loan;

        return loan;
    }

    function reject(mapping(bytes32 => LoanInfo) storage self, bytes32 id, address repaymentToken) internal {
        LoanInfo memory loan = self[id];

        // make sure the loan can be modified. Only loans in the pending state can be rejected
        if (loan.status == LoanStatus.Unknown) {
            revert LoanNotFound();
        } else if (loan.status != LoanStatus.Pending) {
            revert InvalidLoanStatusForOperation();
        }

        // transfer back collateral to borrower
        IERC20(repaymentToken).transfer(loan.borrower, loan.collateral);

        // change the loan status to rejected and store the update
        loan.status = LoanStatus.Rejected;

        self[id] = loan;
    }

    function finalize(
        mapping(bytes32 => LoanInfo) storage self,
        bytes32 id,
        uint256 interestRate,
        uint256 totalPaymentAmount
    ) internal returns (LoanInfo memory) {
        LoanInfo memory loan = self[id];

        if (loan.status == LoanStatus.Unknown) {
            revert LoanNotFound();
        } else if (loan.status != LoanStatus.Pending) {
            revert InvalidLoanStatusForOperation();
        }

        loan.interestRate = interestRate;
        loan.totalPaymentAmount = totalPaymentAmount;
        loan.originalBalance = totalPaymentAmount;
        loan.remainingBalance = totalPaymentAmount;
        loan.status = LoanStatus.Open;
        loan.principalAmountPerDollarOwed = Math.mulDiv(loan.amount, 10 ** 18, totalPaymentAmount);

        self[id] = loan;

        return loan;
    }

    function create(
        mapping(bytes32 => LoanInfo) storage self,
        uint256 amount,
        uint256 collateral,
        uint256 term,
        string memory details,
        address borrowToken
    ) internal returns (LoanInfo memory) {
        bytes32 id = keccak256(abi.encode(block.timestamp, msg.sender, amount, details));

        // withdraw collateral from borrower
        if (collateral > 0) {
            IERC20(borrowToken).transferFrom(msg.sender, address(this), collateral);
        }

        // create the token representing the loan
        IMintableToken token = new MintableToken(address(this), "LOAN", string(abi.encodePacked(id)));

        LoanInfo memory loan = LoanInfo({
            id: id,
            status: LoanStatus.Pending,
            borrower: msg.sender,
            amount: amount,
            collateral: collateral,
            details: details,
            term: term,
            interestRate: 0,
            remainingBalance: 0,
            originalBalance: 0,
            totalPaymentAmount: 0,
            principalAmountPerDollarOwed: 0,
            token: token
        });

        self[loan.id] = loan;

        return loan;
    }
}
