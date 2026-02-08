# Makefile for ZKAuth Foundry Project

# Load environment variables
-include .env

# Default network
NETWORK ?= polygon_zkevm_testnet

# Styled output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help install build test deploy deploy-verify clean format

help: ## Show this help message
	@echo "$(BLUE)ZKAuth - Foundry Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

install: ## Install dependencies
	@echo "$(BLUE)Installing Forge standard library...$(NC)"
	@forge install foundry-rs/forge-std --no-commit
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

build: ## Compile contracts
	@echo "$(BLUE)Building contracts...$(NC)"
	@forge build
	@echo "$(GREEN)✓ Build complete$(NC)"

test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	@forge test -vvv

test-gas: ## Run tests with gas report
	@echo "$(BLUE)Running tests with gas report...$(NC)"
	@forge test --gas-report

coverage: ## Generate coverage report
	@echo "$(BLUE)Generating coverage...$(NC)"
	@forge coverage

clean: ## Clean build artifacts
	@echo "$(BLUE)Cleaning artifacts...$(NC)"
	@forge clean
	@echo "$(GREEN)✓ Clean complete$(NC)"

format: ## Format Solidity files
	@echo "$(BLUE)Formatting contracts...$(NC)"
	@forge fmt
	@echo "$(GREEN)✓ Formatting complete$(NC)"

# Deployment targets
deploy-local: ## Deploy to local Anvil
	@echo "$(BLUE)Deploying to local network...$(NC)"
	@forge script script/Deploy.s.sol:DeployZKAuth --rpc-url localhost --broadcast

deploy-polygon: ## Deploy to Polygon zkEVM Testnet
	@echo "$(BLUE)Deploying to Polygon zkEVM Testnet...$(NC)"
	@forge script script/Deploy.s.sol:DeployZKAuth \
		--rpc-url polygon_zkevm_testnet \
		--broadcast \
		-vvvv

deploy-polygon-verify: ## Deploy to Polygon zkEVM Testnet with verification
	@echo "$(BLUE)Deploying to Polygon zkEVM Testnet with verification...$(NC)"
	@forge script script/Deploy.s.sol:DeployZKAuth \
		--rpc-url polygon_zkevm_testnet \
		--broadcast \
		--verify \
		-vvvv

deploy-scroll: ## Deploy to Scroll Sepolia
	@echo "$(BLUE)Deploying to Scroll Sepolia...$(NC)"
	@forge script script/Deploy.s.sol:DeployZKAuth \
		--rpc-url scroll_sepolia \
		--broadcast \
		-vvvv

deploy-linea: ## Deploy to Linea Testnet
	@echo "$(BLUE)Deploying to Linea Testnet...$(NC)"
	@forge script script/Deploy.s.sol:DeployZKAuth \
		--rpc-url linea_testnet \
		--broadcast \
		-vvvv

deploy-taiko: ## Deploy to Taiko Hekla
	@echo "$(BLUE)Deploying to Taiko Hekla...$(NC)"
	@forge script script/Deploy.s.sol:DeployZKAuth \
		--rpc-url taiko_testnet \
		--broadcast \
		-vvvv

# Verification
verify: ## Verify contract on block explorer
	@echo "$(BLUE)Verifying contract...$(NC)"
	@echo "Usage: make verify NETWORK=polygon_zkevm_testnet ADDRESS=0x..."
	@forge verify-contract \
		--chain-id 2442 \
		$(ADDRESS) \
		src/ZKAuthVerifier.sol:ZKAuthVerifier

# Anvil (local node)
anvil: ## Start local Anvil node
	@echo "$(BLUE)Starting Anvil...$(NC)"
	@anvil

# Utilities
flatten: ## Flatten contracts for verification
	@echo "$(BLUE)Flattening contracts...$(NC)"
	@forge flatten src/ZKAuthVerifier.sol > ZKAuthVerifier-flattened.sol
	@echo "$(GREEN)✓ Flattened to ZKAuthVerifier-flattened.sol$(NC)"

size: ## Show contract sizes
	@forge build --sizes

abi: ## Export contract ABI
	@forge inspect ZKAuthVerifier abi > ZKAuthVerifier.abi.json
	@echo "$(GREEN)✓ ABI exported to ZKAuthVerifier.abi.json$(NC)"

# Quick commands
check: build test ## Build and test

all: clean install build test ## Full rebuild

# Documentation
docs: ## Open Foundry book
	@open https://book.getfoundry.sh/

networks: ## Show configured networks
	@echo "$(BLUE)Configured Networks:$(NC)"
	@echo "  - polygon_zkevm_testnet (Chain ID: 2442)"
	@echo "  - scroll_sepolia (Chain ID: 534351)"
	@echo "  - linea_testnet (Chain ID: 59140)"
	@echo "  - taiko_testnet (Chain ID: 167009)"
	@echo "  - zksync_testnet (Chain ID: 300)"
	@echo ""
	@echo "$(BLUE)Test RPC:$(NC)"
	@cast block-number --rpc-url polygon_zkevm_testnet || echo "$(RED)✗ Polygon zkEVM RPC not responding$(NC)"
