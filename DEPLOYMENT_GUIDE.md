# ZKAuth - Foundry Deployment Guide

Complete guide to deploy ZKAuthVerifier to ZK proof testnets using Foundry.

---

## 📋 Prerequisites

### Install Foundry

```bash
# Install Foundry (Forge, Cast, Anvil, Chisel)
curl -L https://foundry.paradigm.xyz | bash

# Run foundryup to install
foundryup

# Verify installation
forge --version
cast --version
anvil --version
```

### Install Dependencies

```bash
# Git (for submodule management)
git --version  # Should be installed

# Make sure you have a wallet ready
# MetaMask or any Ethereum wallet
```

---

## 🚀 Quick Start (3 Steps)

### Step 1: Setup Project

```bash
# Clone or create project directory
cd foundry-zkauth

# Install Forge standard library (optional, already configured)
forge install foundry-rs/forge-std --no-commit
```

### Step 2: Configure Environment

```bash
# Create .env file
cp .env.example .env

# Edit .env and add your private key
nano .env  # or vim, code, etc.
```

Add to `.env`:
```bash
PRIVATE_KEY=your_private_key_without_0x_prefix
POLYGONSCAN_API_KEY=your_api_key  # Optional, for verification
```

### Step 3: Deploy

```bash
# Build contracts
forge build

# Deploy to Polygon zkEVM Testnet
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url polygon_zkevm_testnet \
    --broadcast \
    --verify \
    -vvvv
```

---

## 🌐 Supported Networks

### 1. Polygon zkEVM Testnet (Cardona) ⭐ RECOMMENDED

**Network Details:**
- Chain ID: 2442
- RPC: https://rpc.cardona.zkevm-rpc.com
- Explorer: https://cardona-zkevm.polygonscan.com
- Faucet: https://faucet.polygon.technology/

**Deploy Command:**
```bash
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url polygon_zkevm_testnet \
    --broadcast \
    --verify \
    -vvvv
```

**Get Testnet ETH:**
1. Visit https://faucet.polygon.technology/
2. Select "Polygon zkEVM Testnet (Cardona)"
3. Enter wallet address
4. Receive 0.1 ETH instantly

---

### 2. zkSync Era Sepolia Testnet

**Network Details:**
- Chain ID: 300
- RPC: https://sepolia.era.zksync.dev
- Explorer: https://sepolia.explorer.zksync.io

**Deploy Command:**
```bash
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url zksync_testnet \
    --broadcast \
    -vvvv
```

**Note:** zkSync requires special deployment via zkforge or custom setup. Standard Foundry deployment may have limitations.

**Get Testnet ETH:**
1. Get Sepolia ETH: https://sepoliafaucet.com/
2. Bridge: https://portal.zksync.io/bridge

---

### 3. Scroll Sepolia Testnet

**Network Details:**
- Chain ID: 534351
- RPC: https://sepolia-rpc.scroll.io
- Explorer: https://sepolia.scrollscan.com

**Deploy Command:**
```bash
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url scroll_sepolia \
    --broadcast \
    --verify \
    -vvvv
```

**Get Testnet ETH:**
1. Get Sepolia ETH: https://sepoliafaucet.com/
2. Bridge: https://sepolia.scroll.io/bridge

---

### 4. Linea Testnet (Goerli)

**Network Details:**
- Chain ID: 59140
- RPC: https://rpc.goerli.linea.build
- Explorer: https://goerli.lineascan.build

**Deploy Command:**
```bash
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url linea_testnet \
    --broadcast \
    --verify \
    -vvvv
```

**Get Testnet ETH:**
- Faucet: https://faucet.goerli.linea.build/

---

### 5. Taiko Testnet (Hekla)

**Network Details:**
- Chain ID: 167009
- RPC: https://rpc.hekla.taiko.xyz
- Explorer: https://hekla.taikoscan.network

**Deploy Command:**
```bash
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url taiko_testnet \
    --broadcast \
    -vvvv
```

**Get Testnet ETH:**
- Bridge: https://bridge.hekla.taiko.xyz/

---

## 📝 Step-by-Step Deployment

### Step 1: Build Contracts

```bash
# Compile contracts
forge build

# Expected output:
# [⠢] Compiling...
# [⠆] Compiling 1 files with 0.8.20
# [⠰] Solc 0.8.20 finished in 2.5s
# Compiler run successful
```

### Step 2: Test Locally (Optional)

```bash
# Run local tests
forge test -vvv

# Start local Anvil node
anvil

# Deploy to local node (in another terminal)
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url localhost \
    --broadcast
```

### Step 3: Deploy to Testnet

```bash
# Deploy to Polygon zkEVM Testnet
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url polygon_zkevm_testnet \
    --broadcast \
    -vvvv
```

**Expected Output:**
```
[⠢] Compiling...
No files changed, compilation skipped
Script ran successfully.
Gas used: 2,234,567

== Logs ==
===========================================
ZKAuthVerifier Deployment Complete
===========================================
Contract Address: 0x1234...5678
Deployer: 0xabcd...efgh
Chain ID: 2442
Auth Validity: 86400 seconds (24 hours)
===========================================

To verify contract, run:
forge verify-contract --chain-id 2442 0x1234...5678 src/ZKAuthVerifier.sol:ZKAuthVerifier

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
```

**Save the contract address!**

---

## ✅ Verify Contract

### Automatic Verification

```bash
# Verify during deployment (recommended)
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url polygon_zkevm_testnet \
    --broadcast \
    --verify \
    -vvvv
```

### Manual Verification

```bash
# Get API key from block explorer
# Add to .env: POLYGONSCAN_API_KEY=your_key

# Verify contract
forge verify-contract \
    --chain-id 2442 \
    --watch \
    0xYourContractAddress \
    src/ZKAuthVerifier.sol:ZKAuthVerifier \
    --etherscan-api-key $POLYGONSCAN_API_KEY
```

---

## 🔧 Interact with Contract

### Using Cast (Foundry CLI)

```bash
# Check if address is authenticated
cast call 0xContractAddress \
    "isAuthenticated(address)(bool)" \
    0xUserAddress \
    --rpc-url polygon_zkevm_testnet

# Get authentication details
cast call 0xContractAddress \
    "getAuthDetails(address)(bool,uint256,uint256)" \
    0xUserAddress \
    --rpc-url polygon_zkevm_testnet

# Call authenticate function (with proof)
cast send 0xContractAddress \
    "authenticate(uint256[2],uint256[2][2],uint256[2],uint256[2])" \
    "[proof_a_x,proof_a_y]" \
    "[[proof_b_x0,proof_b_x1],[proof_b_y0,proof_b_y1]]" \
    "[proof_c_x,proof_c_y]" \
    "[nullifier,commitment]" \
    --rpc-url polygon_zkevm_testnet \
    --private-key $PRIVATE_KEY
```

### Using Foundry Script

Create `script/Interact.s.sol`:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ZKAuthVerifier.sol";

contract InteractZKAuth is Script {
    function run() external {
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        ZKAuthVerifier zkAuth = ZKAuthVerifier(contractAddress);
        
        vm.startBroadcast();
        
        // Check authentication
        bool isAuth = zkAuth.isAuthenticated(msg.sender);
        console.log("Is Authenticated:", isAuth);
        
        vm.stopBroadcast();
    }
}
```

Run:
```bash
CONTRACT_ADDRESS=0xYourAddress forge script script/Interact.s.sol:InteractZKAuth \
    --rpc-url polygon_zkevm_testnet \
    --broadcast
```

---

## 🧪 Testing

### Unit Tests

Create `test/ZKAuthVerifier.t.sol`:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ZKAuthVerifier.sol";

contract ZKAuthVerifierTest is Test {
    ZKAuthVerifier public zkAuth;
    address public user1 = address(0x1);
    
    function setUp() public {
        zkAuth = new ZKAuthVerifier();
    }
    
    function testDeployment() public {
        assertEq(zkAuth.owner(), address(this));
        assertEq(zkAuth.AUTH_VALIDITY_PERIOD(), 24 hours);
    }
    
    function testNotAuthenticatedByDefault() public {
        assertFalse(zkAuth.isAuthenticated(user1));
    }
    
    // Add more tests...
}
```

Run tests:
```bash
forge test -vvv
```

### Gas Reports

```bash
forge test --gas-report
```

---

## 🔐 Generate ZK Proofs

### Install Circom Tools

```bash
# Install Circom
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
git clone https://github.com/iden3/circom.git
cd circom
cargo build --release
cargo install --path circom

# Install snarkjs
npm install -g snarkjs
```

### Create Circuit

`circuits/auth.circom`:
```circom
pragma circom 2.0.0;

template Auth() {
    signal input privateKey;
    signal input nullifier;
    signal input commitment;
    
    signal privateKeySquared;
    privateKeySquared <== privateKey * privateKey;
    commitment === privateKeySquared;
    
    signal expectedNullifier;
    expectedNullifier <== privateKey + commitment;
    nullifier === expectedNullifier;
}

component main {public [nullifier, commitment]} = Auth();
```

### Generate Proof

```bash
# Compile circuit
circom circuits/auth.circom --r1cs --wasm --sym -o build/

# Download Powers of Tau
wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau

# Setup
snarkjs groth16 setup build/auth.r1cs powersOfTau28_hez_final_10.ptau auth_0000.zkey
snarkjs zkey contribute auth_0000.zkey auth_final.zkey --name="Contribution" -v

# Export verification key
snarkjs zkey export verificationkey auth_final.zkey verification_key.json

# Create input
echo '{"privateKey":"123","nullifier":"15252","commitment":"15129"}' > input.json

# Generate witness
node build/auth_js/generate_witness.js build/auth_js/auth.wasm input.json witness.wtns

# Generate proof
snarkjs groth16 prove auth_final.zkey witness.wtns proof.json public.json

# Export call data
snarkjs zkey export soliditycalldata public.json proof.json
```

---

## 📊 Foundry Commands Reference

### Build & Compile
```bash
forge build                    # Compile contracts
forge clean                    # Clean artifacts
forge build --sizes            # Show contract sizes
forge build --force            # Force recompile
```

### Testing
```bash
forge test                     # Run all tests
forge test -vvv                # Verbose output
forge test --gas-report        # Gas usage report
forge test --match-test testName  # Run specific test
forge coverage                 # Code coverage
```

### Deployment
```bash
forge script script/Deploy.s.sol \
    --rpc-url <network> \
    --broadcast \
    --verify \
    -vvvv

# Dry run (simulation)
forge script script/Deploy.s.sol \
    --rpc-url <network>
```

### Interaction
```bash
cast call <address> "function()" --rpc-url <network>      # Read
cast send <address> "function()" --rpc-url <network> \
    --private-key $PRIVATE_KEY                             # Write
cast balance <address> --rpc-url <network>                 # Check balance
cast block-number --rpc-url <network>                      # Block number
```

### Verification
```bash
forge verify-contract \
    --chain-id <id> \
    <address> \
    src/Contract.sol:ContractName \
    --etherscan-api-key $API_KEY
```

### Utilities
```bash
cast abi-encode "function(uint256,address)" 123 0x...    # Encode data
cast keccak "Hello"                                       # Hash
cast sig "transfer(address,uint256)"                      # Function selector
forge inspect ContractName abi                            # Get ABI
forge flatten src/Contract.sol                            # Flatten for verification
```

---

## 🐛 Troubleshooting

### "Insufficient funds"
```bash
# Check balance
cast balance $YOUR_ADDRESS --rpc-url polygon_zkevm_testnet

# Get more tokens from faucet
```

### "Invalid nonce"
```bash
# Check current nonce
cast nonce $YOUR_ADDRESS --rpc-url polygon_zkevm_testnet

# Reset MetaMask if needed
```

### "RPC not responding"
```bash
# Test RPC connection
cast block-number --rpc-url polygon_zkevm_testnet

# Try alternative RPC if available
```

### "Verification failed"
```bash
# Make sure API key is correct
echo $POLYGONSCAN_API_KEY

# Wait a few minutes after deployment
sleep 60

# Try manual verification
forge verify-contract --chain-id 2442 <address> <contract> --watch
```

---

## 📁 Project Structure

```
foundry-zkauth/
├── src/
│   └── ZKAuthVerifier.sol          # Main contract
├── script/
│   ├── Deploy.s.sol                # Deployment script
│   └── Interact.s.sol              # Interaction script (optional)
├── test/
│   └── ZKAuthVerifier.t.sol        # Unit tests (optional)
├── lib/
│   └── forge-std/                  # Foundry standard library
├── foundry.toml                    # Foundry configuration
├── .env.example                    # Environment template
├── .env                            # Your private keys (gitignored)
└── README.md                       # This guide
```

---

## ✅ Deployment Checklist

- [ ] Foundry installed (`forge --version`)
- [ ] Project initialized
- [ ] `.env` configured with PRIVATE_KEY
- [ ] Testnet tokens received
- [ ] Contracts compiled (`forge build`)
- [ ] Local tests passed (optional)
- [ ] Deployed to testnet
- [ ] Contract address saved
- [ ] Contract verified on explorer
- [ ] Interaction tested

---

## 🎓 Project Timeline

**Week 3-4:** Setup ✅
- [x] Install Foundry
- [x] Configure networks
- [x] Get testnet tokens

**Week 5-6:** Implementation ✅
- [x] ZKAuthVerifier contract
- [x] Deployment scripts
- [ ] Contract verification

**Week 7-8:** ZK Integration ⏳
- [ ] Circom circuit
- [ ] Proof generation
- [ ] Update verification key

**Week 9-10:** Testing ⏳
- [ ] Unit tests
- [ ] Integration tests
- [ ] Gas optimization

---

## 📚 Resources

**Foundry:**
- Docs: https://book.getfoundry.sh/
- GitHub: https://github.com/foundry-rs/foundry

**ZK Tools:**
- Circom: https://docs.circom.io/
- snarkjs: https://github.com/iden3/snarkjs

**Networks:**
- Polygon zkEVM: https://docs.polygon.technology/zkEVM/
- zkSync: https://docs.zksync.io/
- Scroll: https://docs.scroll.io/

---

**Student:** VISHAAL S  
**Roll No:** AA.SC.P2MCA24077071

**Good luck with deployment! 🚀**
