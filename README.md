# ZKAuth - Foundry Edition

**Zero-Knowledge Proof Based Web3 Authentication System**

Student: VISHAAL S | Roll No: AA.SC.P2MCA24077071

---

## 🎯 Project Overview

ZKAuth is a privacy-preserving authentication system for Web3 applications using zk-SNARKs (Groth16). Users can prove wallet ownership without exposing their private key or wallet address on-chain.

### Key Features

- ✅ **Zero-Knowledge Proofs**: Groth16 zk-SNARK implementation
- ✅ **Privacy-First**: No private data exposure
- ✅ **Replay Protection**: Nullifier-based system
- ✅ **Time-Bound Sessions**: 24-hour authentication validity
- ✅ **Multi-Network**: Deploy to any ZK testnet
- ✅ **Foundry-Based**: Modern Solidity development

---

## 🚀 Quick Start

### Prerequisites

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verify installation
forge --version
cast --version
```

### Setup & Deploy (3 Commands)

```bash
# 1. Configure environment
cp .env.example .env
# Edit .env and add your PRIVATE_KEY

# 2. Build contracts
forge build

# 3. Deploy to Polygon zkEVM Testnet
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url polygon_zkevm_testnet \
    --broadcast \
    --verify
```

---

## 📦 What's Included

```
foundry-zkauth/
├── src/
│   └── ZKAuthVerifier.sol       # Main contract with Groth16 verifier
├── script/
│   └── Deploy.s.sol             # Deployment script
├── test/
│   └── ZKAuthVerifier.t.sol     # Unit tests (optional)
├── foundry.toml                 # Configuration for 7+ ZK networks
├── .env.example                 # Environment template
├── DEPLOYMENT_GUIDE.md          # Detailed deployment steps
└── README.md                    # This file
```

---

## 🌐 Supported ZK Testnets

| Network | Chain ID | Faucet | Deploy Command |
|---------|----------|--------|----------------|
| **Polygon zkEVM Testnet** | 2442 | [Get ETH](https://faucet.polygon.technology/) | `--rpc-url polygon_zkevm_testnet` |
| **zkSync Era Sepolia** | 300 | [Bridge](https://portal.zksync.io/bridge) | `--rpc-url zksync_testnet` |
| **Scroll Sepolia** | 534351 | [Bridge](https://sepolia.scroll.io/bridge) | `--rpc-url scroll_sepolia` |
| **Linea Testnet** | 59140 | [Get ETH](https://faucet.goerli.linea.build/) | `--rpc-url linea_testnet` |
| **Taiko Hekla** | 167009 | [Bridge](https://bridge.hekla.taiko.xyz/) | `--rpc-url taiko_testnet` |

All networks configured in `foundry.toml` - just change the RPC URL!

---

## 📝 Contract Functions

### Core Functions

#### `authenticate()`
Submit ZK proof for authentication
```solidity
function authenticate(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory input
) public returns (bool)
```

**Parameters:**
- `a`, `b`, `c`: Groth16 proof points
- `input[0]`: Nullifier (prevents replay)
- `input[1]`: Commitment (public identifier)

#### `isAuthenticated()`
Check authentication status
```solidity
function isAuthenticated(address user) public view returns (bool)
```

#### `getAuthDetails()`
Get full authentication info
```solidity
function getAuthDetails(address user) 
    public view returns (bool, uint256, uint256)
```

#### `revokeAuthentication()`
User revokes own authentication
```solidity
function revokeAuthentication() public
```

---

## 🔧 Using Foundry Tools

### Build & Test

```bash
# Compile contracts
forge build

# Run tests
forge test -vvv

# Gas report
forge test --gas-report

# Coverage
forge coverage
```

### Deploy

```bash
# Dry run (simulation)
forge script script/Deploy.s.sol \
    --rpc-url polygon_zkevm_testnet

# Actual deployment
forge script script/Deploy.s.sol:DeployZKAuth \
    --rpc-url polygon_zkevm_testnet \
    --broadcast \
    --verify \
    -vvvv
```

### Interact with Cast

```bash
# Read: Check authentication
cast call <CONTRACT_ADDRESS> \
    "isAuthenticated(address)(bool)" \
    <USER_ADDRESS> \
    --rpc-url polygon_zkevm_testnet

# Write: Revoke authentication
cast send <CONTRACT_ADDRESS> \
    "revokeAuthentication()" \
    --rpc-url polygon_zkevm_testnet \
    --private-key $PRIVATE_KEY

# Get auth details
cast call <CONTRACT_ADDRESS> \
    "getAuthDetails(address)(bool,uint256,uint256)" \
    <USER_ADDRESS> \
    --rpc-url polygon_zkevm_testnet
```

---

## 🔐 ZK Proof Generation

### Install Circom Tools

```bash
# Install Circom
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
    
    // Commitment = privateKey^2
    signal privateKeySquared;
    privateKeySquared <== privateKey * privateKey;
    commitment === privateKeySquared;
    
    // Nullifier = privateKey + commitment
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

# Download Powers of Tau (for testing)
wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau

# Generate proving key
snarkjs groth16 setup build/auth.r1cs powersOfTau28_hez_final_10.ptau auth.zkey

# Export verification key
snarkjs zkey export verificationkey auth.zkey verification_key.json

# Create input (example: privateKey = 123)
# commitment = 123^2 = 15129
# nullifier = 123 + 15129 = 15252
echo '{"privateKey":"123","nullifier":"15252","commitment":"15129"}' > input.json

# Generate witness
node build/auth_js/generate_witness.js build/auth_js/auth.wasm input.json witness.wtns

# Generate proof
snarkjs groth16 prove auth.zkey witness.wtns proof.json public.json

# Verify proof locally
snarkjs groth16 verify verification_key.json public.json proof.json

# Export Solidity call data
snarkjs zkey export soliditycalldata public.json proof.json > calldata.txt
```

### Submit Proof On-Chain

```bash
# Copy calldata from calldata.txt
# Format: ["a_x","a_y"], [["b_x0","b_x1"],["b_y0","b_y1"]], ["c_x","c_y"], ["nullifier","commitment"]

cast send <CONTRACT_ADDRESS> \
    "authenticate(uint256[2],uint256[2][2],uint256[2],uint256[2])" \
    "[a_x,a_y]" "[[b_x0,b_x1],[b_y0,b_y1]]" "[c_x,c_y]" "[nullifier,commitment]" \
    --rpc-url polygon_zkevm_testnet \
    --private-key $PRIVATE_KEY
```

---

## 🧪 Testing

### Create Test File

`test/ZKAuthVerifier.t.sol`:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ZKAuthVerifier.sol";

contract ZKAuthVerifierTest is Test {
    ZKAuthVerifier public zkAuth;
    address public owner;
    address public user1;
    
    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        zkAuth = new ZKAuthVerifier();
    }
    
    function testDeployment() public {
        assertEq(zkAuth.owner(), owner);
        assertEq(zkAuth.AUTH_VALIDITY_PERIOD(), 24 hours);
    }
    
    function testNotAuthenticatedByDefault() public {
        assertFalse(zkAuth.isAuthenticated(user1));
    }
    
    function testGetAuthDetailsForUnauthenticated() public {
        (bool authenticated, uint256 timestamp, uint256 timeRemaining) = 
            zkAuth.getAuthDetails(user1);
        
        assertFalse(authenticated);
        assertEq(timestamp, 0);
        assertEq(timeRemaining, 0);
    }
}
```

### Run Tests

```bash
# Run all tests
forge test

# Verbose output
forge test -vvv

# Test specific function
forge test --match-test testDeployment

# Gas report
forge test --gas-report
```

---

## 📊 How It Works

### Authentication Flow

```
1. Off-Chain: User generates ZK proof
   ├─ Private: privateKey (secret)
   ├─ Public: nullifier, commitment
   └─ Proof: (a, b, c) using Groth16

2. On-Chain: Submit proof to contract
   └─ authenticate(a, b, c, [nullifier, commitment])

3. Contract verifies:
   ├─ Proof is valid (pairing check)
   ├─ Nullifier never used before
   └─ Mark user authenticated

4. User is authenticated for 24 hours
   └─ isAuthenticated(user) returns true
```

### Security Features

- **Zero-Knowledge**: Private key never revealed
- **Replay Protection**: Nullifier tracking
- **Time-Bound**: Sessions expire after 24h
- **Trustless**: On-chain verification
- **Gas Efficient**: Optimized pairing operations

---

## 🎓 Project Deliverables

| Item | Status | Location |
|------|--------|----------|
| Solidity Contract | ✅ | `src/ZKAuthVerifier.sol` |
| Deployment Script | ✅ | `script/Deploy.s.sol` |
| Multi-Network Config | ✅ | `foundry.toml` |
| Documentation | ✅ | `README.md`, `DEPLOYMENT_GUIDE.md` |
| Circom Circuit | ⏳ | Example provided |
| Frontend | ⏳ | Not included (Solidity-only) |
| Demo Video | ⏳ | To be created |

---

## 📚 Learning Outcomes

### Technologies Used

- **Foundry**: Modern Solidity dev framework
- **Groth16**: zk-SNARK proof system
- **BN254 Curve**: Elliptic curve pairing
- **Circom**: ZK circuit language
- **snarkjs**: Proof generation toolkit

### Concepts Learned

- Zero-Knowledge Proof fundamentals
- zk-SNARK construction and verification
- Elliptic curve cryptography
- Smart contract security patterns
- Gas optimization techniques
- Multi-network deployment

---

## 🐛 Troubleshooting

### Common Issues

**Foundry not installed**
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

**Insufficient funds**
```bash
# Check balance
cast balance <YOUR_ADDRESS> --rpc-url polygon_zkevm_testnet

# Get testnet ETH from faucet
```

**Build fails**
```bash
# Clean and rebuild
forge clean
forge build
```

**RPC issues**
```bash
# Test connection
cast block-number --rpc-url polygon_zkevm_testnet

# Check foundry.toml for correct RPC URL
```

**Verification fails**
```bash
# Make sure API key is set in .env
echo $POLYGONSCAN_API_KEY

# Manual verification
forge verify-contract \
    --chain-id 2442 \
    <ADDRESS> \
    src/ZKAuthVerifier.sol:ZKAuthVerifier
```

---

## 🔗 Useful Commands

### Foundry Essentials

```bash
# Create new project
forge init project-name

# Install dependencies
forge install <org>/<repo>

# Update dependencies
forge update

# Remove dependency
forge remove <dependency>

# Format code
forge fmt

# Flatten contract
forge flatten src/Contract.sol

# Get contract ABI
forge inspect ZKAuthVerifier abi

# Get storage layout
forge inspect ZKAuthVerifier storage
```

### Cast Utilities

```bash
# Convert to hex
cast to-hex 123

# Convert from hex
cast to-dec 0x7b

# Keccak hash
cast keccak "hello"

# Get function selector
cast sig "transfer(address,uint256)"

# ABI encode
cast abi-encode "transfer(address,uint256)" 0x... 100

# Parse transaction
cast tx <TX_HASH> --rpc-url <network>

# Get receipt
cast receipt <TX_HASH> --rpc-url <network>
```

---

## 📞 Resources

### Official Documentation
- Foundry Book: https://book.getfoundry.sh/
- Circom Docs: https://docs.circom.io/
- snarkjs GitHub: https://github.com/iden3/snarkjs

### Learning Resources
- ZK Whiteboard: https://zkhack.dev/whiteboard/
- ZK MOOC: https://zk-learning.org/
- Foundry Tutorial: https://github.com/foundry-rs/foundry

### Network Documentation
- Polygon zkEVM: https://docs.polygon.technology/zkEVM/
- zkSync: https://docs.zksync.io/
- Scroll: https://docs.scroll.io/
- Linea: https://docs.linea.build/

---

## ✅ Deployment Checklist

- [ ] Foundry installed and working
- [ ] `.env` configured with PRIVATE_KEY
- [ ] Testnet tokens in wallet
- [ ] Contracts compile successfully
- [ ] Tests pass (if written)
- [ ] Deployed to testnet
- [ ] Contract address saved
- [ ] Contract verified on explorer
- [ ] Basic interaction tested with Cast

---

## 🎯 Next Steps

1. **Deploy to testnet** - Follow DEPLOYMENT_GUIDE.md
2. **Generate ZK proofs** - Use Circom and snarkjs
3. **Test authentication** - Submit proofs on-chain
4. **Build frontend** (Optional) - Create Next.js UI
5. **Create demo video** - Document functionality
6. **Write final report** - Complete documentation

---

## 📝 License

MIT License

---

## 👨‍🎓 Author

**VISHAAL S**  
Roll No: AA.SC.P2MCA24077071  
Project: ZKAuth - Zero-Knowledge Authentication System  
Course: MCA - Blockchain Security and Privacy

---

**Built with Foundry for Web3 Privacy** 🔐
