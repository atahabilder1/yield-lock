export interface StakePosition {
  amount: bigint;
  stakedAt: bigint;
  lastClaimedAt: bigint;
  tier: LockTier;
  rewardIndex: bigint;
  active: boolean;
}

export interface TierConfig {
  lockDuration: bigint;
  apy: bigint;
  penaltyBps: bigint;
  enabled: boolean;
}

export enum LockTier {
  FLEXIBLE = 0,
  TIER_30 = 1,
  TIER_90 = 2,
  TIER_180 = 3,
  TIER_365 = 4,
}

export interface ContractAddresses {
  token: `0x${string}`;
  staking: `0x${string}`;
}

export interface StakingStats {
  totalStaked: bigint;
  totalRewardsPaid: bigint;
  userStakedAmount: bigint;
  userPositionCount: number;
  userPositions: number[];
}

export interface UnstakeInfo {
  amount: bigint;
  penalty: bigint;
}

export interface UserBalance {
  token: bigint;
  staked: bigint;
  pendingRewards: bigint;
}