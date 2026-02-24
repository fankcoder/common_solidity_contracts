
# common_solidity_contracts

Common Solidity smart contract examples for learning and development.

常见 Solidity 智能合约示例集合，用于学习与开发参考手册。

---

## 📖 Introduction | 项目介绍

This repository contains a collection of common Solidity smart contract examples, covering token minting, NFT minting, airdrops, whitelist minting, payment minting, randomness, and multi-signature wallets.

本仓库包含一系列常见的 Solidity 智能合约示例，涵盖代币铸造、NFT 铸造、空投、白名单铸造、支付铸造、随机数以及多签钱包等核心场景。

It is designed for beginners and developers who want practical contract templates and reference implementations.

本项目适用于 Solidity 学习者以及希望获得实用合约模板和参考实现的开发者。

---

## 🧩 Examples List | 示例列表

### ✅ example01 - Mint Token by ERC20  
Mint fungible tokens using ERC20 standard.  

使用 ERC20 标准铸造代币。

---

### ✅ example02 - Mint Token by ERC721  
Mint NFTs using ERC721 standard.  

使用 ERC721 标准铸造 NFT。

---

### ✅ example03 - Mint Token by ERC1155  
Mint multi-token NFTs using ERC1155 standard.  

使用 ERC1155 标准铸造多类型 NFT。

---

### ✅ example04 - Airdrop Token  
Batch airdrop ERC20 tokens to multiple addresses.  

向多个地址批量空投 ERC20 代币。

---

### ✅ example05 - Airdrop NFT  
Batch airdrop NFTs to users.  

向用户批量空投 NFT。

---

### ✅ example06 - Whitelist Mint NFT (Merkle Tree)  
Mint NFTs using Merkle Tree whitelist verification.  

通过 Merkle Tree 白名单机制铸造 NFT。

---

### ✅ example07 - Mint NFT by Paying ETH  
Mint NFTs by paying Ether (ETH).  

通过支付 ETH 铸造 NFT。

---

### ✅ example08 - Mint NFT by Paying USDT (ERC20)  
Mint NFTs by paying ERC20 tokens (e.g., USDT).  

通过支付 ERC20 代币（如 USDT）铸造 NFT。

---

### ✅ example09 - Get Unsafe Random Seed  
Generate pseudo-random numbers using block variables (not secure).  

使用不安全的伪随机数（不推荐用于生产）。

---

### ✅ example10 - Get Random Seed by Chainlink  
Generate secure and verifiable random numbers using Chainlink VRF.  

使用 Chainlink VRF 生成安全、可验证的随机数。

---

### ✅ example11 - Multi-Signature Wallet  
A basic multi-signature wallet implementation.  

基础多签钱包合约实现。

---

## ⚠️ Security Notice | 安全提示

Some examples (such as `example09_unsafe_random`) are for educational purposes only and should NOT be used in production environments.

部分示例（如 `example09_unsafe_random`）仅用于教学目的，不应直接用于生产环境。

Please review and audit the code carefully before deploying any contract on mainnet.

在部署到主网前，请务必仔细审查和审计合约代码。

---

## 🛠 Requirements | 环境要求

- Solidity ^0.8.x  
- Hardhat / Foundry / Remix (optional)  
- Node.js (if using scripts)

- Solidity ^0.8.x  
- Hardhat / Foundry / Remix（可选）  
- Node.js（如使用脚本）

---

## 🚀 How to Use | 使用方式

1. Clone this repository  
   克隆本仓库：

```bash
git clone https://github.com/yourname/common_solidity_contracts.git
```
2.   Open and study the example contracts  
    打开并学习示例合约代码
    
3.  Deploy using Remix / Hardhat / Foundry  
    使用 Remix / Hardhat / Foundry 部署合约
