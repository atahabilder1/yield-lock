# 🔒 YieldLock — ERC-20 Staking dApp

> A next-generation DeFi staking protocol that rewards long-term ERC-20 token holders while penalizing early withdrawals — built with Solidity, Foundry, and Next.js.

[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?style=flat&logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-000000?style=flat)](https://book.getfoundry.sh/)
[![Next.js](https://img.shields.io/badge/Frontend-Next.js%2014-000000?style=flat&logo=next.js)](https://nextjs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Live Demo:** Coming Soon | **Deployed on:** Sepolia Testnet

---

## 🌟 What is YieldLock?

**YieldLock** is a decentralized finance (DeFi) protocol that enables users to stake ERC-20 tokens and earn rewards based on lock duration. The longer the lock period, the higher the APY. Early withdrawals trigger a penalty, creating a trustless, incentive-aligned staking mechanism entirely governed by smart contracts.

It’s like a **“crypto time deposit”** — but without banks, paperwork, or intermediaries.

---

## ✨ Core Features

- ⏱️ **Time-Based Staking:** Choose from five lock durations with increasing APYs.  
- 📈 **Dynamic Rewards:** Real-time reward accrual based on staking duration.  
- 🔄 **Flexible Claiming:** Claim earned rewards anytime without unstaking.  
- 🛡️ **Security-First Contracts:** Built with OpenZeppelin libraries and protected against reentrancy.  
- 🧑‍💼 **Admin Controls:** Update APY, penalties, and lock terms without redeploying.  
- 📊 **Detailed Analytics:** View positions, rewards, penalties, and history from a responsive dashboard.  

---

## 🏗️ System Architecture (Overview)

YieldLock uses a modular, full-stack design for scalability and maintainability:

```
┌───────────────────────────────────────────────┐
│                  Frontend (Next.js)           │
│  Wallet Connection │ Dashboard │ Admin Panel  │
└───────────────────────────────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────────┐
│           Web3 Integration Layer              │
│ wagmi + RainbowKit + viem + TanStack Query    │
└───────────────────────────────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────────┐
│              Ethereum Blockchain              │
│ Token.sol │ Staking.sol │ IStaking.sol        │
└───────────────────────────────────────────────┘
```

📘 For detailed architecture and code explanations, see [Technical Overview](./docs/technical-overview.md).

---

## 💰 Staking Tiers

| Lock Period | APY | Early Withdrawal Penalty |
|------------|-----|--------------------------|
| Flexible   | 0%  | 0%                       |
| 30 Days    | 5%  | 2%                       |
| 90 Days    | 8%  | 5%                       |
| 180 Days   | 12% | 8%                       |
| 365 Days   | 18% | 12%                      |

📊 More on reward calculation: [Tokenomics](./docs/tokenomics.md)

---

## ⚙️ Getting Started

### 🧰 Prerequisites

- Node.js ≥ 18  
- Foundry (Forge, Cast, Anvil)  
- MetaMask wallet  
- Infura or Alchemy RPC URL

---

### 🧪 Installation

```bash
git clone https://github.com/atahabilder1/yield-lock.git
cd yield-lock

forge install
npm install
```

Create a `.env` file:

```bash
cp .env.example .env
nano .env
```

---

### 🚀 Local Development

Run a local blockchain and deploy contracts:

```bash
anvil
forge test -vv
forge script script/DeployStaking.s.sol --rpc-url http://localhost:8545 --broadcast
```

Run the frontend:

```bash
cd frontend
npm run dev
```

Visit → [http://localhost:3000](http://localhost:3000)

---

## 🛡️ Security Highlights

- ✅ **ReentrancyGuard** – Prevents reentrancy attacks  
- ✅ **Checks-Effects-Interactions** – Safe external calls  
- ✅ **Access Control** – Owner-only critical functions  
- ✅ **Emergency Controls** – System-wide pause and emergency withdrawals  

See [SECURITY.md](./SECURITY.md) for full details and our bug bounty program.

---

## 🧪 Testing & Validation

Comprehensive test suite:

```bash
forge test -vv
forge test --gas-report
```

- 39+ tests across Token and Staking contracts  
- 100% smart contract coverage  
- Fuzz testing for edge cases  
- Gas usage reporting and optimization checks

---

## 🔮 Roadmap

- 🏛️ DAO governance for parameter management  
- 📱 Native iOS/Android apps  
- 🌉 Multi-chain support (Polygon, Arbitrum, Base)  
- 🪙 NFT-based staking positions  
- 🤖 AI-powered APY optimization

See the full vision: [Technical Overview → Roadmap](./docs/technical-overview.md#-future-roadmap)

---

## 📚 Full Documentation

- 📘 [Technical Overview](./docs/technical-overview.md)  
- 🚀 [Deployment Guide](./docs/deployment-guide.md)  
- 🎨 [Frontend Architecture](./docs/frontend-architecture.md)  
- 📊 [Tokenomics](./docs/tokenomics.md)

---

## 📜 License

This project is released under the [MIT License](https://opensource.org/licenses/MIT).

---

**Built with ❤️ by [Anik Tahabilder](https://github.com/atahabilder1)**  
