# ========== VERIFY CONTRACTS ==========

verify-bankvault:
	forge verify-contract \
		--chain-id 11155111 \
		0xD558A744bE91787073B89f9ac2A338a9CCD8c39A \
		src/BankVault.sol:BankVault \
		--constructor-args $$(cast abi-encode "constructor(address,address)" \
			0x2d97DF81C0d2c55FD114550D801eef0851e8a1B7 \
			0x4a723A90E99AD88B0d9861897D211dD3928239BE) \
		--etherscan-api-key $$(grep ETHERSCAN_API_KEY .env | cut -d '=' -f2) \
		--watch

verify-loanvault:
	forge verify-contract \
		--chain-id 11155111 \
		0xF28A304D2D0D15436270C909Ac6b0a0d6d120A3c \
		src/LoanVault.sol:LoanVault \
		--constructor-args $$(cast abi-encode "constructor(address,address,address)" \
			0xD558A744bE91787073B89f9ac2A338a9CCD8c39A \
			0x2d97DF81C0d2c55FD114550D801eef0851e8a1B7 \
			0x4a723A90E99AD88B0d9861897D211dD3928239BE) \
		--etherscan-api-key $$(grep ETHERSCAN_API_KEY .env | cut -d '=' -f2) \
		--watch

verify-bank-token:
	forge verify-contract \
		--chain-id 11155111 \
		0x82129d1139A0bc15751229A244A769E825EA475b \
		src/MintableToken.sol:MintableToken \
		--constructor-args $$(cast abi-encode "constructor(address,string,string)" \
			0xD558A744bE91787073B89f9ac2A338a9CCD8c39A \
			"Community Bank" \
			"BANK") \
		--etherscan-api-key $$(grep ETHERSCAN_API_KEY .env | cut -d '=' -f2) \
		--watch

verify-sbank-token:
	forge verify-contract \
		--chain-id 11155111 \
		0x54f622BF66dF2301Ba23EC4421673AE3E5F20FE1 \
		src/MintableToken.sol:MintableToken \
		--constructor-args $$(cast abi-encode "constructor(address,string,string)" \
			0xD558A744bE91787073B89f9ac2A338a9CCD8c39A \
			"Staked BANK" \
			"sBANK") \
		--etherscan-api-key $$(grep ETHERSCAN_API_KEY .env | cut -d '=' -f2) \
		--watch
