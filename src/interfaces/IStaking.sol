// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IStaking
 * @dev Interface for the YieldLock staking contract
 */
interface IStaking {
    /**
     * @dev Enum representing different lock tiers
     */
    enum LockTier {
        FLEXIBLE,   // 0 - No lock, can unstake anytime
        TIER_30,    // 1 - 30 days lock
        TIER_90,    // 2 - 90 days lock
        TIER_180,   // 3 - 180 days lock
        TIER_365    // 4 - 365 days lock
    }

    /**
     * @dev Struct representing a stake position
     */
    struct StakePosition {
        uint256 amount;           // Amount of tokens staked
        uint256 stakedAt;         // Timestamp when staked
        uint256 lastClaimedAt;    // Last time rewards were claimed
        LockTier tier;            // Lock tier of this position
        uint256 rewardIndex;      // Reward index when staked
        bool active;              // Whether position is still active
    }

    /**
     * @dev Struct for lock tier configuration
     */
    struct TierConfig {
        uint256 lockDuration;     // Lock duration in seconds
        uint256 apy;              // APY in basis points (100 = 1%)
        uint256 penaltyBps;       // Early withdrawal penalty in basis points
        bool enabled;             // Whether this tier is enabled
    }

    // Events
    event Staked(
        address indexed user,
        uint256 indexed positionId,
        uint256 amount,
        LockTier tier,
        uint256 timestamp
    );

    event Unstaked(
        address indexed user,
        uint256 indexed positionId,
        uint256 amount,
        uint256 penalty,
        uint256 timestamp
    );

    event RewardsClaimed(
        address indexed user,
        uint256 indexed positionId,
        uint256 reward,
        uint256 timestamp
    );

    event TierConfigUpdated(
        LockTier indexed tier,
        uint256 lockDuration,
        uint256 apy,
        uint256 penaltyBps,
        bool enabled
    );

    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed positionId,
        uint256 amount,
        uint256 timestamp
    );

    // External functions
    function stake(uint256 amount, LockTier tier) external returns (uint256 positionId);
    function unstake(uint256 positionId) external returns (uint256 amount, uint256 penalty);
    function claimRewards(uint256 positionId) external returns (uint256 reward);
    function claimAllRewards() external returns (uint256 totalRewards);
    function emergencyWithdraw(uint256 positionId) external;

    // View functions
    function getPosition(address user, uint256 positionId) external view returns (StakePosition memory);
    function getUserPositions(address user) external view returns (uint256[] memory);
    function getPendingRewards(address user, uint256 positionId) external view returns (uint256);
    function getTotalPendingRewards(address user) external view returns (uint256);
    function getTierConfig(LockTier tier) external view returns (TierConfig memory);
    function canUnstake(address user, uint256 positionId) external view returns (bool);
    function getUnstakeInfo(address user, uint256 positionId) external view returns (uint256 amount, uint256 penalty);
    function getUserStakedAmount(address user) external view returns (uint256);
    function getTotalStaked() external view returns (uint256);

    // Admin functions
    function updateTierConfig(
        LockTier tier,
        uint256 lockDuration,
        uint256 apy,
        uint256 penaltyBps,
        bool enabled
    ) external;
    function pause() external;
    function unpause() external;
    function setEmergencyMode(bool enabled) external;
}