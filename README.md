# 👨‍💻 About the Developer

<p align="center">
  <img src="https://gateway.lighthouse.storage/ipfs/bafybeidlpfu7vy2rgevvo2msiebtvjfjtejlgjsgjja4jixly45sq3woii/profile.jpeg" alt="Mohammad Ayaan Siddiqui" width="200" />
</p>

Assalamualaikum guys! 🙌 This is Mohammad Ayaan Siddiqui (♦moayaan.eth♦). I’m a **Full Stack Blockchain Developer** , **Crypto Investor** and **MBA in Blockchain Management** with **over 2 years of experience** rocking the Web3 world! 🚀 I’ve worn many hats:

- Research Intern at a Hong Kong-based firm 🇭🇰
- Technical Co-Founder at a Netherlands-based firm 🇳🇱
- Full Stack Intern at a Singapore-based crypto hardware wallet firm 🇸🇬
- Blockchain Developer at a US-based Bitcoin DeFi project 🇺🇸
- PG Diploma in Blockchain Management from Cambridge International Qualifications (CIQ) 🇬🇧
- MBA in Blockchain Management from University of Studies Guglielmo Marconi, Italy 🇮🇹

Let’s connect and build something epic! Find me at [moayaan.com](https://moayaan.com) 🌐

If you liked this project, please donate to Gaza 🇵🇸 [UNRWA Donation Link](https://donate.unrwa.org/-landing-page/en_EN)

Happy coding, fam! 😎✨

---

# 🥯 Merkle Airdrop & Signature Verification

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.24-363636.svg)
![Foundry](https://img.shields.io/badge/Built%20with-Foundry-orange)

A gas-efficient, secure airdrop system using **Merkle Trees** for whitelist verification and **EIP-712 Signatures** for secure claiming. Built with Foundry. 🚀

---

## 🏗️ Project Overview

This project implements a secure token airdrop system where:

- 🌳 **Merkle Trees** are used to store whitelisted addresses off-chain (gas efficient!)
- ✍️ **EIP-712 Signatures** allow users to sign their intent to claim, preventing replay attacks
- ⛽ **Gasless Claiming** (optional) via a relayer/gas payer mechanism
- 🥯 **BagelToken** is the ERC20 token being airdropped

---

## 📂 Codebase Structure

### `src/`

- **`MerkelAirdrop.sol`**: The main contract.
  - Verifies Merkle proofs 🔍
  - Validates EIP-712 signatures ✍️
  - Transfers tokens to claimers 💸
- **`BagelToken.sol`**: A standard ERC20 token contract with minting capabilities. 🥯

### `script/`

- **`DeployMerkelAirdrop.s.sol`**: Deploys both contracts and funds the airdrop. 🚀
- **`Interact.s.sol`**: Script to claim the airdrop programmatically. 🤖
- **`MakeMerkel.s.sol`**: Generates Merkle Root and Proofs from `input.json`. 🌳
- **`GenerateInput.s.sol`**: Generates the input file for the Merkle tree. 📝

### `test/`

- **`MerkelAirdrop.t.sol`**: Comprehensive test suite covering:
  - Valid claims ✅
  - Invalid signatures ❌
  - Gas payer functionality ⛽

---

## 🛠️ Usage & Workflow

### 1. 🚀 Deployment

Deploy contracts to a local Anvil chain using the Makefile:

```bash
make deploy
```

_This deploys contracts, mints tokens, and funds the airdrop contract!_

### 2. ✍️ Signature Generation

Generate a signature for the claim:

```bash
# Get the message hash
cast call <AIRDROP_ADDR> "getMessageHash(address,uint256)" <USER_ADDR> <AMOUNT>

# Sign the hash
cast wallet sign --no-hash <HASH> --private-key <USER_PK>
```

### 3. 💸 Claiming

Claim tokens using the `Interact` script:

```bash
forge script script/Interact.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

---

## 💻 Terminal Walkthrough (Success Story)

Here's exactly what happens when you run the full flow:

**1. Deploying the System** 🏗️

```bash
$ make deploy

# Output:
# MerkelAirdrop deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
# BagelToken deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
```

**2. Execution of Claim** ⚡

```bash
$ forge script script/Interact.s.sol ... --broadcast

# Logs:
# Claiming address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
# Claiming amount: 25000000000000000000
# v: 28
# Status: Success! 🎉
```

**3. Verification** 💰

```bash
$ cast call <TOKEN_ADDR> "balanceOf(address)" <USER_ADDR>
# Output: 0x...15af1d78b58c40000

$ cast --to-dec 0x...15af1d78b58c40000
# Output: 25000000000000000000 (25 Tokens! 🥯)
```

---

## 📜 Makefile Shortcuts

We've set up a powerful `Makefile` to automate everything:

- `make anvil`: Starts a local blockchain node 🔗
- `make deploy`: Deploys contracts & funds airdrop 🚀
- `make sign`: Generates signature for default user ✍️
- `make claim`: Executes the claim script 💸
- `make balance`: Checks user's token balance 💰
- `make test`: Runs the test suite 🧪

---

_Happy Coding! 🥯✨_
