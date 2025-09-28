
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



Скажи, якщо зручно — підкину готові команди git для коміту/пушу `README.md` одразу в `main` або окремою гілкою + PR.
