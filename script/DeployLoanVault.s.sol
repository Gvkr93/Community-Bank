// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {MintableToken} from "../src/MintableToken.sol";
import {LoanVault} from "../src/LoanVault.sol";
import {BankVault} from "../src/BankVault.sol";
import {ILoanVault} from "../src/interfaces/ILoanVault.sol";
import {IMintableToken} from "../src/interfaces/IMintableToken.sol";

contract DeployLoanVault is Script {
    address constant DEAD_ADDRESS = address(0);

    function run() external returns (MintableToken, BankVault, LoanVault) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        MintableToken usdc = new MintableToken(DEAD_ADDRESS, "USDC", "USDC");
        BankVault bank = new BankVault(address(usdc), DEAD_ADDRESS);

        ILoanVault loanVaultInterface = bank.loanVault();
        IMintableToken bankTokenInterface = bank.BANK();
        IMintableToken sBankTokenInterface = bank.sBANK();

        address loanVaultAddr = address(loanVaultInterface);
        address bankTokenAddr = address(bankTokenInterface);
        address sBankTokenAddr = address(sBankTokenInterface);

        vm.stopBroadcast();

        console.log("USDC token deployed at: ", address(usdc));
        console.log("BankVault deployed at: ", address(bank));
        console.log("LoanVault deployed at: ", loanVaultAddr);
        console.log("BANK token at: ", bankTokenAddr);
        console.log("sBANK token at: ", sBankTokenAddr);

        return (usdc, bank, LoanVault(loanVaultAddr));
    }
}
