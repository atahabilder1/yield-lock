import { sepolia } from 'viem/chains';
import type { ContractAddresses } from '@/types/contracts';

// Contract addresses per network
export const CONTRACT_ADDRESSES: Record<number, ContractAddresses> = {
  // Sepolia testnet
  [sepolia.id]: {
    token: '0x0000000000000000000000000000000000000000', // To be updated after deployment
    staking: '0x0000000000000000000000000000000000000000', // To be updated after deployment
  },
  // Localhost for development
  31337: {
    token: '0x0000000000000000000000000000000000000000',
    staking: '0x0000000000000000000000000000000000000000',
  },
};

// Default chain for the dApp
export const DEFAULT_CHAIN = sepolia;

// Supported chains
export const SUPPORTED_CHAINS = [sepolia];

// Contract ABIs (simplified - in production you'd import from generated files)
export const TOKEN_ABI = [
  'function name() view returns (string)',
  'function symbol() view returns (string)',
  'function decimals() view returns (uint8)',
  'function totalSupply() view returns (uint256)',
  'function balanceOf(address) view returns (uint256)',
  'function allowance(address, address) view returns (uint256)',
  'function approve(address, uint256) returns (bool)',
  'function transfer(address, uint256) returns (bool)',
  'function transferFrom(address, address, uint256) returns (bool)',
  'function mint(address, uint256)',
  'function burn(uint256)',
  'function burnFrom(address, uint256)',
  'event Transfer(address indexed, address indexed, uint256)',
  'event Approval(address indexed, address indexed, uint256)',
  'event TokensMinted(address indexed, uint256)',
  'event TokensBurned(address indexed, uint256)',
] as const;

export const STAKING_ABI = [
  'function stake(uint256, uint8) returns (uint256)',
  'function unstake(uint256) returns (uint256, uint256)',
  'function claimRewards(uint256) returns (uint256)',
  'function claimAllRewards() returns (uint256)',
  'function emergencyWithdraw(uint256)',
  'function getPosition(address, uint256) view returns (tuple(uint256,uint256,uint256,uint8,uint256,bool))',
  'function getUserPositions(address) view returns (uint256[])',
  'function getPendingRewards(address, uint256) view returns (uint256)',
  'function getTotalPendingRewards(address) view returns (uint256)',
  'function getTierConfig(uint8) view returns (tuple(uint256,uint256,uint256,bool))',
  'function canUnstake(address, uint256) view returns (bool)',
  'function getUnstakeInfo(address, uint256) view returns (uint256, uint256)',
  'function getUserStakedAmount(address) view returns (uint256)',
  'function getTotalStaked() view returns (uint256)',
  'function stakingToken() view returns (address)',
  'function treasury() view returns (address)',
  'function totalStaked() view returns (uint256)',
  'function totalRewardsPaid() view returns (uint256)',
  'function emergencyMode() view returns (bool)',
  'function paused() view returns (bool)',
  'event Staked(address indexed, uint256 indexed, uint256, uint8, uint256)',
  'event Unstaked(address indexed, uint256 indexed, uint256, uint256, uint256)',
  'event RewardsClaimed(address indexed, uint256 indexed, uint256, uint256)',
  'event EmergencyWithdraw(address indexed, uint256 indexed, uint256, uint256)',
] as const;

// Lock tier configurations
export const LOCK_TIERS = {
  0: { name: 'Flexible', duration: '0 days', apy: '0%', penalty: '0%' },
  1: { name: '30 Days', duration: '30 days', apy: '5%', penalty: '2%' },
  2: { name: '90 Days', duration: '90 days', apy: '8%', penalty: '5%' },
  3: { name: '180 Days', duration: '180 days', apy: '12%', penalty: '8%' },
  4: { name: '365 Days', duration: '365 days', apy: '18%', penalty: '12%' },
} as const;

// Transaction settings
export const TX_SETTINGS = {
  gasLimit: 300000n,
  maxFeePerGas: 20000000000n, // 20 gwei
  maxPriorityFeePerGas: 2000000000n, // 2 gwei
} as const;

// UI constants
export const REFRESH_INTERVAL = 30000; // 30 seconds
export const TOKEN_DECIMALS = 18;
export const TOAST_DURATION = 5000; // 5 seconds