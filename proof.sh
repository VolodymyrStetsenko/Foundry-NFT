#!/usr/bin/env bash
set -euo pipefail

# Load env
set -a && source .env && set +a

RPC="${SEPOLIA_RPC_URL}"
BASIC=0x44060e503682015ef0912ef97d25067e6fe0c1c7
MOOD=0x659a96e8ecba88c79c8edeeab2f3a701c12d1392
ME=0xF6d3a3104b75b0BD2498856C1283e7120c315AeC

echo "=== ENV ==="
echo "RPC   : ${RPC:0:40}..."
echo "BASIC : $BASIC"
echo "MOOD  : $MOOD"
echo "ME    : $ME"
echo

echo "=== PROOF: CODE EXISTS ==="
echo -n "BasicNft codesize: "; cast code $BASIC --rpc-url "$RPC" | awk '{print length($0)}'
echo -n "MoodNft  codesize: "; cast code $MOOD  --rpc-url "$RPC" | awk '{print length($0)}'
echo

echo "=== BASIC NFT ==="
echo -n "ownerOf(0): "; cast call $BASIC "ownerOf(uint256)(address)" 0 --rpc-url "$RPC"
echo -n "tokenURI(0) [IPFS]: "; cast call $BASIC "tokenURI(uint256)(string)" 0 --rpc-url "$RPC"
echo

echo "=== MOOD NFT ==="
echo -n "ownerOf(0): "; cast call $MOOD "ownerOf(uint256)(address)" 0 --rpc-url "$RPC"
echo -n "tokenURI(0) [data:... base64] (first 120 chars): "
cast call $MOOD "tokenURI(uint256)(string)" 0 --rpc-url "$RPC" | cut -c1-120
echo

echo "=== BROADCAST (DEPLOY TXS) ==="
jq -r '.transactions[] | select(.transactionType=="CREATE") | "BASIC tx: \(.hash) | addr: \(.contractAddress)"' \
  broadcast/DeployBasicNft.s.sol/11155111/run-latest.json || true

jq -r '.transactions[] | select(.transactionType=="CREATE") | "MOOD  tx: \(.hash) | addr: \(.contractAddress)"' \
  broadcast/DeployMoodNft.s.sol/11155111/run-latest.json || true
