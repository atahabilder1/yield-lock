# 🔒 YieldLock — ERC-20 Staking dApp

A full-stack decentralized application (dApp) that implements **ERC-20 staking** with:
- **Rewards for long-term holders**
- **Penalties for early withdrawals**
- **Secure contract design**
- **React frontend** for seamless user interaction

Deployed and tested on the **Sepolia testnet**.

---

## 📖 Table of Contents
- [🔒 YieldLock — ERC-20 Staking dApp](#-yieldlock--erc-20-staking-dapp)
  - [📖 Table of Contents](#-table-of-contents)
  - [🔎 Overview](#-overview)
  - [✨ Features](#-features)
  - [🏗 Architecture](#-architecture)
  - [📈 Tokenomics](#-tokenomics)
  - [🧰 Tech Stack](#-tech-stack)
  - [📂 Project Structure](#-project-structure)
  - [🔐 Smart Contract Design](#-smart-contract-design)
  - [🎨 Frontend Design](#-frontend-design)
  - [⚙️ Installation](#️-installation)
    - [Backend](#backend)
    - [Frontend](#frontend)
  - [🚀 Usage](#-usage)
  - [✅ Testing](#-testing)
  - [🚢 Deployment](#-deployment)
  - [🛡 Security Considerations](#-security-considerations)
  - [🔮 Future Enhancements](#-future-enhancements)
  - [📜 License](#-license)
  - [🙏 Acknowledgements](#-acknowledgements)

---

## 🔎 Overview
YieldLock is a staking system where users can **stake ERC-20 tokens** and earn rewards over time.  
Early withdrawals apply penalties, aligning incentives for **long-term holding**.  

This project demonstrates:
- **Smart contract tokenomics** (Solidity, Foundry)  
- **Frontend dApp** (React/Next.js + wagmi + RainbowKit)  
- **Testnet deployment** (Sepolia)  

---

## ✨ Features
- Stake ERC-20 tokens with time-based rewards
- Early withdrawal penalties (configurable)
- Multiple stake positions per user
- Admin-configurable parameters (APY, penalties, lock durations)
- Wallet integration (MetaMask, WalletConnect)
- Frontend dashboard for staking, claiming, and tracking rewards

---

## 🏗 Architecture
- **Backend (Foundry)**:  
  - `Token.sol` → ERC-20 contract  
  - `Staking.sol` → staking mechanics  
  - Tests written in Solidity (`forge test`)  
  - Deployment scripts (`forge script`)  

- **Frontend (Next.js)**:  
  - Wallet connection (wagmi + RainbowKit)  
  - Contract interaction (ethers.js/viem)  
  - Dashboard UI for user balances and rewards  

- **Testnet**: Sepolia (supported until ~2026)  

---

## 📈 Tokenomics
- **Reward rate**: APR/APY per lock tier  
- **Penalty**: applied if unstaking before lock expires  
- **Treasury**: penalties redirected to treasury or burned  
- **Lock tiers**: configurable (flex, 30d, 90d, 180d, 365d)  

---

## 🧰 Tech Stack
- **Smart Contracts**: Solidity (0.8.24+), Foundry (Forge, Cast, Anvil)  
- **Frontend**: React, Next.js, wagmi, RainbowKit, ethers.js/viem  
- **Contracts Security**: OpenZeppelin (ERC-20, ReentrancyGuard)  
- **Deployment**: Sepolia testnet (Alchemy/Infura RPC)  

---

## 📂 Project Structure
```
yieldlock/
│── src/              # contracts
│── test/             # tests
│── script/           # deployment
│── frontend/         # Next.js frontend
│── foundry.toml
│── README.md
```

---

## 🔐 Smart Contract Design
- **Reward Index**: tracks earned rewards efficiently  
- **Penalty Calculation**: `penalty = (amount * penaltyBps) / 10000` if unstaked early  
- **Security**:
  - ReentrancyGuard
  - Checks-Effects-Interactions pattern
  - Pausable/Ownable for admin  
- **Events**: `Staked`, `Claimed`, `Unstaked`, `PenaltyApplied`  

---

## 🎨 Frontend Design
- Built with **Next.js** + **TailwindCSS**  
- Wallet connection via **RainbowKit**  
- Contract hooks via **wagmi** + **ethers.js/viem**  
- Components:
  - **StakeForm** → input amount, choose lock tier  
  - **Dashboard** → view current stakes, rewards, penalties  
  - **ClaimButton** → claim available rewards  

---

## ⚙️ Installation

### Backend
```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Clone project
git clone https://github.com/yourusername/yieldlock.git
cd yieldlock

# Install dependencies
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

---

## 🚀 Usage
1. Deploy Token + Staking contracts (Sepolia)  
   ```bash
   forge script script/DeployStaking.s.sol --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast
   ```
2. Start frontend
   ```bash
   cd frontend
   npm run dev
   ```
3. Open [http://localhost:3000](http://localhost:3000)  

---

## ✅ Testing
```bash
forge test -vv
```
Covers:
- Stake → Claim → Unstake
- Early withdrawal penalties
- Multiple positions
- Admin parameter updates

---

## 🚢 Deployment
Deploy to Sepolia:
```bash
forge script script/DeployStaking.s.sol --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast
```

---

## 🛡 Security Considerations
- SafeERC20 + ReentrancyGuard  
- Avoid block.timestamp manipulation (use reasonable lock times)  
- Penalties configurable by governance only  
- Consider adding a timelock for parameter changes  

---

## 🔮 Future Enhancements
- NFT positions (ERC-721 stakes)  
- Auto-compounding vault  
- DAO governance for parameters  
- Subgraph for analytics  

---

## 📜 License
MIT License — free to use with attribution.  

---

## 🙏 Acknowledgements
- [Foundry](https://book.getfoundry.sh/)  
- [OpenZeppelin](https://openzeppelin.com/contracts/)  
- [RainbowKit](https://www.rainbowkit.com/)  
- [wagmi](https://wagmi.sh/)  
