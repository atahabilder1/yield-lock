// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IStaking.sol";

/**
 * @title YieldLock Staking Contract
 * @dev Implements time-locked staking with rewards and early withdrawal penalties
 * @dev Uses reward index mechanism for efficient reward calculations
 */
contract Staking is IStaking, Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Constants
    uint256 public constant SECONDS_PER_YEAR = 365 days;
    uint256 public constant BASIS_POINTS = 10_000;
    uint256 public constant MAX_APY = 50_00; // 50% max APY
    uint256 public constant MAX_PENALTY = 20_00; // 20% max penalty

    // State variables
    IERC20 public immutable stakingToken;
    address public treasury;
    bool public emergencyMode;

    // Position tracking
    mapping(address => mapping(uint256 => StakePosition)) public positions;
    mapping(address => uint256[]) public userPositions;
    mapping(address => uint256) public userPositionCount;
    uint256 public totalPositions;

    // Tier configurations
    mapping(LockTier => TierConfig) public tierConfigs;

    // Global staking metrics
    uint256 public totalStaked;
    uint256 public totalRewardsPaid;

    // Reward calculation
    uint256 public globalRewardIndex;
    uint256 public lastUpdateTime;

    /**
     * @dev Constructor
     * @param _stakingToken The ERC20 token to be staked
     * @param _treasury Address to receive penalties
     * @param _initialOwner Initial owner of the contract
     */
    constructor(
        address _stakingToken,
        address _treasury,
        address _initialOwner
    ) Ownable(_initialOwner) {
        require(_stakingToken != address(0), "Staking: invalid token address");
        require(_treasury != address(0), "Staking: invalid treasury address");

        stakingToken = IERC20(_stakingToken);
        treasury = _treasury;
        lastUpdateTime = block.timestamp;

        // Initialize tier configurations with default values
        _initializeTierConfigs();
    }

    /**
     * @dev Initialize default tier configurations
     */
    function _initializeTierConfigs() private {
        // Flexible: 0% APY, 0% penalty, no lock
        tierConfigs[LockTier.FLEXIBLE] = TierConfig({
            lockDuration: 0,
            apy: 0,
            penaltyBps: 0,
            enabled: true
        });

        // 30 days: 5% APY, 2% penalty
        tierConfigs[LockTier.TIER_30] = TierConfig({
            lockDuration: 30 days,
            apy: 5_00, // 5%
            penaltyBps: 2_00, // 2%
            enabled: true
        });

        // 90 days: 8% APY, 5% penalty
        tierConfigs[LockTier.TIER_90] = TierConfig({
            lockDuration: 90 days,
            apy: 8_00, // 8%
            penaltyBps: 5_00, // 5%
            enabled: true
        });

        // 180 days: 12% APY, 8% penalty
        tierConfigs[LockTier.TIER_180] = TierConfig({
            lockDuration: 180 days,
            apy: 12_00, // 12%
            penaltyBps: 8_00, // 8%
            enabled: true
        });

        // 365 days: 18% APY, 12% penalty
        tierConfigs[LockTier.TIER_365] = TierConfig({
            lockDuration: 365 days,
            apy: 18_00, // 18%
            penaltyBps: 12_00, // 12%
            enabled: true
        });
    }

    /**
     * @dev Stake tokens with specified lock tier
     * @param amount Amount of tokens to stake
     * @param tier Lock tier for the stake
     * @return positionId Unique identifier for the stake position
     */
    function stake(uint256 amount, LockTier tier)
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256 positionId)
    {
        require(amount > 0, "Staking: amount must be greater than 0");
        require(tierConfigs[tier].enabled, "Staking: tier not enabled");
        require(!emergencyMode, "Staking: emergency mode active");

        _updateGlobalRewardIndex();

        // Generate position ID
        positionId = userPositionCount[msg.sender];
        userPositionCount[msg.sender]++;
        totalPositions++;

        // Create position
        positions[msg.sender][positionId] = StakePosition({
            amount: amount,
            stakedAt: block.timestamp,
            lastClaimedAt: block.timestamp,
            tier: tier,
            rewardIndex: globalRewardIndex,
            active: true
        });

        // Add to user positions array
        userPositions[msg.sender].push(positionId);

        // Update global state
        totalStaked += amount;

        // Transfer tokens
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, positionId, amount, tier, block.timestamp);
    }

    /**
     * @dev Unstake tokens from a position
     * @param positionId ID of the position to unstake
     * @return amount Amount of tokens returned
     * @return penalty Penalty amount deducted
     */
    function unstake(uint256 positionId)
        external
        override
        nonReentrant
        returns (uint256 amount, uint256 penalty)
    {
        StakePosition storage position = positions[msg.sender][positionId];
        require(position.active, "Staking: position not active");
        require(!emergencyMode, "Staking: use emergency withdraw in emergency mode");

        _updateGlobalRewardIndex();

        // Claim any pending rewards first
        _claimPositionRewards(msg.sender, positionId);

        // Calculate penalty for early withdrawal
        TierConfig memory config = tierConfigs[position.tier];
        bool isEarlyWithdrawal = block.timestamp < position.stakedAt + config.lockDuration;

        amount = position.amount;
        penalty = 0;

        if (isEarlyWithdrawal && config.penaltyBps > 0) {
            penalty = (amount * config.penaltyBps) / BASIS_POINTS;
            amount -= penalty;

            // Send penalty to treasury
            if (penalty > 0) {
                stakingToken.safeTransfer(treasury, penalty);
            }
        }

        // Update global state
        totalStaked -= position.amount;

        // Deactivate position
        position.active = false;

        // Transfer tokens back to user
        if (amount > 0) {
            stakingToken.safeTransfer(msg.sender, amount);
        }

        emit Unstaked(msg.sender, positionId, amount, penalty, block.timestamp);
    }

    /**
     * @dev Claim rewards for a specific position
     * @param positionId ID of the position to claim rewards for
     * @return reward Amount of rewards claimed
     */
    function claimRewards(uint256 positionId)
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256 reward)
    {
        require(positions[msg.sender][positionId].active, "Staking: position not active");

        _updateGlobalRewardIndex();
        reward = _claimPositionRewards(msg.sender, positionId);
    }

    /**
     * @dev Claim rewards for all user positions
     * @return totalRewards Total amount of rewards claimed
     */
    function claimAllRewards()
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256 totalRewards)
    {
        _updateGlobalRewardIndex();

        uint256[] memory userPositionIds = userPositions[msg.sender];
        for (uint256 i = 0; i < userPositionIds.length; i++) {
            uint256 positionId = userPositionIds[i];
            if (positions[msg.sender][positionId].active) {
                totalRewards += _claimPositionRewards(msg.sender, positionId);
            }
        }
    }

    /**
     * @dev Emergency withdraw without rewards (only in emergency mode)
     * @param positionId ID of the position to emergency withdraw
     */
    function emergencyWithdraw(uint256 positionId) external override nonReentrant {
        require(emergencyMode, "Staking: not in emergency mode");

        StakePosition storage position = positions[msg.sender][positionId];
        require(position.active, "Staking: position not active");

        uint256 amount = position.amount;

        // Update global state
        totalStaked -= amount;

        // Deactivate position
        position.active = false;

        // Transfer tokens back to user (no rewards, no penalties in emergency)
        stakingToken.safeTransfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, positionId, amount, block.timestamp);
    }

    /**
     * @dev Internal function to claim rewards for a position
     * @param user Address of the user
     * @param positionId ID of the position
     * @return reward Amount of rewards claimed
     */
    function _claimPositionRewards(address user, uint256 positionId)
        private
        returns (uint256 reward)
    {
        StakePosition storage position = positions[user][positionId];
        reward = _calculatePositionRewards(user, positionId);

        if (reward > 0) {
            position.lastClaimedAt = block.timestamp;
            position.rewardIndex = globalRewardIndex;
            totalRewardsPaid += reward;

            // Mint rewards (assuming the staking token contract supports minting)
            // For simplicity, we'll transfer from the contract's balance
            // In production, you might want to mint new tokens or have a reward pool
            stakingToken.safeTransfer(user, reward);

            emit RewardsClaimed(user, positionId, reward, block.timestamp);
        }
    }

    /**
     * @dev Update global reward index based on time elapsed
     */
    function _updateGlobalRewardIndex() private {
        if (totalStaked == 0) {
            lastUpdateTime = block.timestamp;
            return;
        }

        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        if (timeElapsed > 0) {
            // This is a simplified reward calculation
            // In a more sophisticated system, you'd weight by tier APYs
            uint256 avgApy = _calculateAverageAPY();
            uint256 rewardRate = (avgApy * timeElapsed) / (SECONDS_PER_YEAR * BASIS_POINTS);
            globalRewardIndex += rewardRate;
            lastUpdateTime = block.timestamp;
        }
    }

    /**
     * @dev Calculate average APY across all active positions (simplified)
     */
    function _calculateAverageAPY() private view returns (uint256) {
        // Simplified: return a weighted average based on tier configurations
        // In production, you'd weight by actual staked amounts per tier
        return 10_00; // 10% default for this example
    }

    /**
     * @dev Calculate pending rewards for a position
     * @param user Address of the user
     * @param positionId ID of the position
     * @return reward Pending reward amount
     */
    function _calculatePositionRewards(address user, uint256 positionId)
        private
        view
        returns (uint256 reward)
    {
        StakePosition memory position = positions[user][positionId];
        if (!position.active) return 0;

        TierConfig memory config = tierConfigs[position.tier];
        if (config.apy == 0) return 0;

        uint256 timeStaked = block.timestamp - position.lastClaimedAt;
        uint256 annualReward = (position.amount * config.apy) / BASIS_POINTS;
        reward = (annualReward * timeStaked) / SECONDS_PER_YEAR;
    }

    // View functions implementation
    function getPosition(address user, uint256 positionId)
        external
        view
        override
        returns (StakePosition memory)
    {
        return positions[user][positionId];
    }

    function getUserPositions(address user)
        external
        view
        override
        returns (uint256[] memory)
    {
        return userPositions[user];
    }

    function getPendingRewards(address user, uint256 positionId)
        external
        view
        override
        returns (uint256)
    {
        return _calculatePositionRewards(user, positionId);
    }

    function getTotalPendingRewards(address user)
        external
        view
        override
        returns (uint256 totalRewards)
    {
        uint256[] memory userPositionIds = userPositions[user];
        for (uint256 i = 0; i < userPositionIds.length; i++) {
            totalRewards += _calculatePositionRewards(user, userPositionIds[i]);
        }
    }

    function getTierConfig(LockTier tier)
        external
        view
        override
        returns (TierConfig memory)
    {
        return tierConfigs[tier];
    }

    function canUnstake(address user, uint256 positionId)
        external
        view
        override
        returns (bool)
    {
        StakePosition memory position = positions[user][positionId];
        if (!position.active) return false;

        TierConfig memory config = tierConfigs[position.tier];
        return block.timestamp >= position.stakedAt + config.lockDuration;
    }

    function getUnstakeInfo(address user, uint256 positionId)
        external
        view
        override
        returns (uint256 amount, uint256 penalty)
    {
        StakePosition memory position = positions[user][positionId];
        if (!position.active) return (0, 0);

        amount = position.amount;

        TierConfig memory config = tierConfigs[position.tier];
        bool isEarlyWithdrawal = block.timestamp < position.stakedAt + config.lockDuration;

        if (isEarlyWithdrawal && config.penaltyBps > 0) {
            penalty = (amount * config.penaltyBps) / BASIS_POINTS;
            amount -= penalty;
        }
    }

    function getUserStakedAmount(address user)
        external
        view
        override
        returns (uint256 totalAmount)
    {
        uint256[] memory userPositionIds = userPositions[user];
        for (uint256 i = 0; i < userPositionIds.length; i++) {
            StakePosition memory position = positions[user][userPositionIds[i]];
            if (position.active) {
                totalAmount += position.amount;
            }
        }
    }

    function getTotalStaked() external view override returns (uint256) {
        return totalStaked;
    }

    // Admin functions
    function updateTierConfig(
        LockTier tier,
        uint256 lockDuration,
        uint256 apy,
        uint256 penaltyBps,
        bool enabled
    ) external override onlyOwner {
        require(apy <= MAX_APY, "Staking: APY too high");
        require(penaltyBps <= MAX_PENALTY, "Staking: penalty too high");

        tierConfigs[tier] = TierConfig({
            lockDuration: lockDuration,
            apy: apy,
            penaltyBps: penaltyBps,
            enabled: enabled
        });

        emit TierConfigUpdated(tier, lockDuration, apy, penaltyBps, enabled);
    }

    function pause() external override onlyOwner {
        _pause();
    }

    function unpause() external override onlyOwner {
        _unpause();
    }

    function setEmergencyMode(bool enabled) external override onlyOwner {
        emergencyMode = enabled;
    }

    /**
     * @dev Update treasury address
     * @param newTreasury New treasury address
     */
    function updateTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "Staking: invalid treasury address");
        treasury = newTreasury;
    }

    /**
     * @dev Recover accidentally sent tokens (not staking tokens)
     * @param token Token to recover
     * @param amount Amount to recover
     */
    function recoverTokens(address token, uint256 amount) external onlyOwner {
        require(token != address(stakingToken), "Staking: cannot recover staking token");
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}