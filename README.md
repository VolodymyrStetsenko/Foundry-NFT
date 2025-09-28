
---

# Foundry NFT — IPFS & On-Chain SVG (Dynamic)

![CI](https://github.com/VolodymyrStetsenko/Foundry-NFT/actions/workflows/ci.yml/badge.svg)
![Solidity](https://img.shields.io/badge/Solidity-0.8.20-363636.svg)

This repository contains two NFT implementations built with **Foundry** as part of my learning path through the **Cyfrin Updraft – Foundry Fundamentals** course by Patrick Collins.
Unlike a straight copy, this repo includes hands-on work to **extract Token URIs**, **host SVGs fully on-chain**, refine **file system permissions**, and expand **test coverage** with extra scenarios.

## Table of Contents

* [Overview](#overview)
* [What’s Unique in This Repo](#whats-unique-in-this-repo)
* [Project Structure](#project-structure)
* [Getting Started](#getting-started)

  * [Requirements](#requirements)
  * [Quickstart](#quickstart)
* [Usage](#usage)

  * [Local Anvil](#local-anvil)
  * [Deploy Scripts](#deploy-scripts)
  * [Formatting](#formatting)
* [Testing & Coverage](#testing--coverage)
* [Deployment Proof](#deployment-proof-sepolia-testnet)
* [Security Notes](#security-notes)
* [Acknowledgements](#acknowledgements)
* [Contact](#contact)
* [License](#license)

## Overview

The repo showcases two NFT flavors:

* **Basic NFT (IPFS-hosted metadata)** — standard ERC-721 where `tokenURI` points to IPFS JSON.
* **Mood NFT (100% on-chain SVG, dynamic)** — the image is stored & rendered fully on-chain and can flip between **Happy** ↔ **Sad**.

Both are implemented with clean scripts and tests using **Foundry** (`forge`, `cast`, `anvil`). CI runs on GitHub Actions to format, build, and test every change.

## What’s Unique in This Repo

* **Robust TokenURI extraction & logging**
  Added utilities/tests to print and validate the exact `data:` URIs returned by contracts.
* **Secure file access for SVGs**
  `foundry.toml` limits `fs_permissions` to **project-local** folders only:

  ```toml
  fs_permissions = [
      { access = "read", path = "./images/" },
      { access = "read", path = "./broadcast" },
  ]
  ```

  This avoids blanket `.` reads and makes intent explicit.
* **Absolute-path safety in scripts**
  The deploy script uses `vm.projectRoot()` to build absolute paths before calling `vm.readFile`, minimizing relative-path surprises:

  ```solidity
  // Build absolute paths to SVGs 
  string memory root = vm.projectRoot();
  string memory sadPath = string.concat(root, "/images/dynamicNft/sad.svg");
  string memory happyPath = string.concat(root, "/images/dynamicNft/happy.svg");
  ```
* **Expanded tests**
  Beyond the course basics, tests now cover:

  * `approve` + `transferFrom` flow
  * `ownerOf` after mint
  * revert on `tokenURI` for non-existent token
  * double flip (Sad → Happy)
* **CI pipeline**
  GitHub Actions workflow enforces `forge fmt --check`, `forge build`, and `forge test`.

## Project Structure

```
.
├── src/
│   ├── BasicNft.sol          # IPFS-based ERC721
│   └── MoodNft.sol           # On-chain SVG (dynamic)
├── script/
│   ├── DeployBasicNft.s.sol
│   ├── DeployMoodNft.s.sol   # reads ./images/dynamicNft/*.svg via projectRoot()
│   └── Interactions.s.sol
├── test/
│   ├── BasicNftTest.t.sol    # approve/transfer, ownerOf, tokenURI, etc.
│   └── MoodNftTest.t.sol     # mint, flip, events, tokenURI
├── images/
│   └── dynamicNft/
│       ├── happy.svg
│       └── sad.svg
├── .github/workflows/ci.yml  # Foundry CI: fmt, build, test
└── foundry.toml
```

## Getting Started

### Requirements

* **Git**

  ```bash
  git --version
  ```
* **Foundry** (forge, cast, anvil)
  Install: [https://book.getfoundry.sh/getting-started/installation](https://book.getfoundry.sh/getting-started/installation)

  ```bash
  forge --version
  ```

### Quickstart

```bash
git clone https://github.com/VolodymyrStetsenko/Foundry-NFT
cd Foundry-NFT

forge install
forge build
forge test
```

## Usage

### Local Anvil

1. Start a local node in a separate terminal:

```bash
anvil
```

2. Deploy (defaults to local unless you pass a network):

```bash
forge script script/DeployBasicNft.s.sol --broadcast --rpc-url http://127.0.0.1:8545
forge script script/DeployMoodNft.s.sol  --broadcast --rpc-url http://127.0.0.1:8545
```

> **Note:** This project does not include public testnet/mainnet deployments by design. Use your own `.env` and RPC if you choose to deploy externally.

### Deploy Scripts

* **Basic NFT** mints a standard ERC-721 with IPFS metadata.
* **Mood NFT** reads `happy.svg` / `sad.svg`, converts them to `data:` URIs, and deploys a dynamic on-chain SVG NFT.

Key snippet (DeployMoodNft):

```solidity
// Convert SVG to data:image/svg+xml;base64 and pass to constructor
MoodNft moodNft = new MoodNft(
    svgToImageURI(sadSvg),
    svgToImageURI(happySvg)
);
```

### Formatting

To avoid formatting template files from dependencies, format **only your code**:

```bash
forge fmt ./src ./script ./test
forge fmt --check ./src ./script ./test
```

## Testing & Coverage

Run tests:

```bash
forge test
```

Generate coverage (summary):

```bash
forge coverage --report summary
```

Generate LCOV (for local review or future integration with Codecov):

```bash
forge coverage --report lcov
```

> Latest local snapshot showed all tests passing (12/12) and line coverage ~**62%** overall. Coverage excludes complex integration bits and example scripts by design; feel free to extend tests further.

---

## Deployment Proof (Sepolia Testnet)

> This section provides on-chain proof that both NFTs were deployed and interacted with on the Sepolia testnet.  
> It includes contract addresses, Etherscan links, and exact transactions for minting and flipping the dynamic NFT.

### Contracts

- **BasicNft (IPFS metadata)** — `0x44060e503682015Ef0912ef97d25067e6FE0c1c7`  
  Etherscan: https://sepolia.etherscan.io/address/0x44060e503682015ef0912ef97d25067e6fe0c1c7

- **MoodNft (100% on-chain SVG, dynamic)** — `0x659A96E8ECba88c79C8edeEab2f3A701c12D1392`  
  Etherscan: https://sepolia.etherscan.io/address/0x659a96e8ecba88c79c8edeeab2f3a701c12d1392

### Key Transactions

- **Mint BasicNft (tokenId = 0)**  
  Tx: https://sepolia.etherscan.io/tx/0xa933e5a190252a770c8818b42a430bc6ed3100ffb467d0bf62d1c9d93731e01a

- **Mint MoodNft (tokenId = 0)**  
  Tx: https://sepolia.etherscan.io/tx/0xe6f803ce4b647fdb684145dca155de62b640c933e636650732c76815687a131e

- **Flip MoodNft (Happy → Sad)**  
  Tx: https://sepolia.etherscan.io/tx/0x2f22d309d01e137b21667a24c1bfc038788c3c7a3fff200e7f0bd780f771e1ab

### How to Verify Manually

**BasicNft → `tokenURI(0)`** returns the IPFS JSON:
```

ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json

````

**MoodNft → `tokenURI(0)`** returns an on-chain data URI with Base64-encoded JSON where
`image` is `data:image/svg+xml;base64,...`.

On Etherscan → **Contract** → **Read Contract**:
- Call `ownerOf(0)` to confirm owner address.
- Call `tokenURI(0)` to see metadata URI.

### Reproduce Interactions Locally (cast)

> Requires `.env` with `SEPOLIA_RPC_URL` and `PRIVATE_KEY` (test key, **no real funds**).

```bash
# Load env (Linux/macOS)
set -a && source .env && set +a

# Convenience variables
export RPC="$SEPOLIA_RPC_URL"
export PK="$PRIVATE_KEY"

# Your deployed contracts
export BASIC=0x44060e503682015Ef0912ef97d25067e6FE0c1c7
export MOOD=0x659A96E8ECba88c79C8edeEab2f3A701c12D1392

# Mint BasicNft (tokenId = 0)
cast send $BASIC "mintNft(string)" \
  "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json" \
  --rpc-url $RPC --private-key $PK

# Check owner and tokenURI
cast call $BASIC "ownerOf(uint256)(address)" 0 --rpc-url $RPC
cast call $BASIC "tokenURI(uint256)(string)" 0 --rpc-url $RPC

# Mint MoodNft (tokenId = 0)
cast send $MOOD "mintNft()" --rpc-url $RPC --private-key $PK

# Check tokenURI (Happy)
cast call $MOOD "tokenURI(uint256)(string)" 0 --rpc-url $RPC

# Flip to Sad and verify tokenURI changed
cast send $MOOD "flipMood(uint256)" 0 --rpc-url $RPC --private-key $PK
cast call $MOOD "tokenURI(uint256)(string)" 0 --rpc-url $RPC
````

> Note: Some wallets on testnets do not index NFTs reliably. Etherscan’s **Token Tracker** and direct `tokenURI` reads are the most deterministic way to verify.

---

## Security Notes

* **Learning project** — not audited. Do **not** use with real funds.
* **File permissions** are restricted in `foundry.toml` to reduce attack surface during `vm.readFile`.
* **On-chain SVG** approach is great for permanence, but mind gas costs and potential size limits when scaling artwork.

## Acknowledgements

* Built while following **Patrick Collins** and **Cyfrin Updraft – Foundry Fundamentals**
  Course: [https://updraft.cyfrin.io/courses/foundry](https://updraft.cyfrin.io/courses/foundry)

Some ideas mirror the course material, but this repository includes my own configuration, permission hardening, test extensions, CI setup, and documentation.

## Contact

* X (Twitter): [https://x.com/carstetsen](https://x.com/carstetsen)
* Telegram: [https://t.me/Zero2Auditor](https://t.me/Zero2Auditor)
* LinkedIn: [https://www.linkedin.com/in/volodymyr-stetsenko-656014246/](https://www.linkedin.com/in/volodymyr-stetsenko-656014246/)

## License

MIT.

---

