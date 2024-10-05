// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {Staking} from "../src/Staking.sol";
import {IStaking} from "../src/interfaces/IStaking.sol";

contract StakingTest is Test {
    Token public token;
    Staking public staking;

    address public owner;
    address public treasury;
    address public user1;
    address public user2;
    address public user3;

    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10**18;
    uint256 public constant STAKE_AMOUNT = 1000 * 10**18;

    // Events to test
    event Staked(
        address indexed user,
        uint256 indexed positionId,
        uint256 amount,
        IStaking.LockTier tier,
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

    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed positionId,
        uint256 amount,
        uint256 timestamp
    );

    function setUp() public {
        owner = makeAddr("owner");
        treasury = makeAddr("treasury");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        // Deploy contracts
        vm.startPrank(owner);
        token = new Token(owner);
        staking = new Staking(address(token), treasury, owner);

        // Give staking contract some tokens for rewards
        token.mint(address(staking), 1_000_000 * 10**18);

        // Give users some tokens
        token.transfer(user1, 10_000 * 10**18);
        token.transfer(user2, 10_000 * 10**18);
        token.transfer(user3, 10_000 * 10**18);
        vm.stopPrank();

        // Users approve staking contract
        vm.prank(user1);
        token.approve(address(staking), type(uint256).max);

        vm.prank(user2);
        token.approve(address(staking), type(uint256).max);

        vm.prank(user3);
        token.approve(address(staking), type(uint256).max);
    }

    function test_InitialState() public {
        assertEq(address(staking.stakingToken()), address(token));
        assertEq(staking.treasury(), treasury);
        assertEq(staking.owner(), owner);
        assertEq(staking.totalStaked(), 0);
        assertEq(staking.emergencyMode(), false);
        assertFalse(staking.paused());

        // Check tier configurations
        IStaking.TierConfig memory flexConfig = staking.getTierConfig(IStaking.LockTier.FLEXIBLE);
        assertEq(flexConfig.lockDuration, 0);
        assertEq(flexConfig.apy, 0);
        assertEq(flexConfig.penaltyBps, 0);
        assertTrue(flexConfig.enabled);

        IStaking.TierConfig memory tier30Config = staking.getTierConfig(IStaking.LockTier.TIER_30);
        assertEq(tier30Config.lockDuration, 30 days);
        assertEq(tier30Config.apy, 5_00); // 5%
        assertEq(tier30Config.penaltyBps, 2_00); // 2%
        assertTrue(tier30Config.enabled);
    }

    function test_StakeFlexible() public {
        uint256 balanceBefore = token.balanceOf(user1);

        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit Staked(user1, 0, STAKE_AMOUNT, IStaking.LockTier.FLEXIBLE, block.timestamp);
        uint256 positionId = staking.stake(STAKE_AMOUNT, IStaking.LockTier.FLEXIBLE);

        assertEq(positionId, 0);
        assertEq(token.balanceOf(user1), balanceBefore - STAKE_AMOUNT);
        assertEq(staking.totalStaked(), STAKE_AMOUNT);

        IStaking.StakePosition memory position = staking.getPosition(user1, positionId);
        assertEq(position.amount, STAKE_AMOUNT);
        assertEq(uint256(position.tier), uint256(IStaking.LockTier.FLEXIBLE));
        assertTrue(position.active);
        assertEq(position.stakedAt, block.timestamp);
    }

    function test_StakeMultipleTiers() public {
        vm.startPrank(user1);

        // Stake in flexible tier
        uint256 pos1 = staking.stake(STAKE_AMOUNT, IStaking.LockTier.FLEXIBLE);

        // Stake in 30-day tier
        uint256 pos2 = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_30);

        // Stake in 365-day tier
        uint256 pos3 = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_365);

        vm.stopPrank();

        assertEq(pos1, 0);
        assertEq(pos2, 1);
        assertEq(pos3, 2);
        assertEq(staking.totalStaked(), STAKE_AMOUNT * 3);

        uint256[] memory userPositions = staking.getUserPositions(user1);
        assertEq(userPositions.length, 3);
        assertEq(userPositions[0], 0);
        assertEq(userPositions[1], 1);
        assertEq(userPositions[2], 2);
    }

    function test_StakeZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert("Staking: amount must be greater than 0");
        staking.stake(0, IStaking.LockTier.FLEXIBLE);
    }

    function test_StakeWhenPaused() public {
        vm.prank(owner);
        staking.pause();

        vm.prank(user1);
        vm.expectRevert();
        staking.stake(STAKE_AMOUNT, IStaking.LockTier.FLEXIBLE);
    }

    function test_StakeWhenEmergencyMode() public {
        vm.prank(owner);
        staking.setEmergencyMode(true);

        vm.prank(user1);
        vm.expectRevert("Staking: emergency mode active");
        staking.stake(STAKE_AMOUNT, IStaking.LockTier.FLEXIBLE);
    }

    function test_UnstakeFlexible() public {
        // First stake
        vm.prank(user1);
        uint256 positionId = staking.stake(STAKE_AMOUNT, IStaking.LockTier.FLEXIBLE);

        uint256 balanceBefore = token.balanceOf(user1);

        // Unstake immediately (no penalty for flexible)
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit Unstaked(user1, positionId, STAKE_AMOUNT, 0, block.timestamp);
        (uint256 amount, uint256 penalty) = staking.unstake(positionId);

        assertEq(amount, STAKE_AMOUNT);
        assertEq(penalty, 0);
        assertEq(token.balanceOf(user1), balanceBefore + STAKE_AMOUNT);
        assertEq(staking.totalStaked(), 0);

        // Position should be inactive
        IStaking.StakePosition memory position = staking.getPosition(user1, positionId);
        assertFalse(position.active);
    }

    function test_UnstakeWithPenalty() public {
        // Stake in 30-day tier
        vm.prank(user1);
        uint256 positionId = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_30);

        uint256 balanceBefore = token.balanceOf(user1);
        uint256 treasuryBalanceBefore = token.balanceOf(treasury);

        // Unstake early (should have 2% penalty)
        vm.prank(user1);
        (uint256 amount, uint256 penalty) = staking.unstake(positionId);

        uint256 expectedPenalty = (STAKE_AMOUNT * 2_00) / 10_000; // 2%
        uint256 expectedAmount = STAKE_AMOUNT - expectedPenalty;

        assertEq(penalty, expectedPenalty);
        assertEq(amount, expectedAmount);
        assertEq(token.balanceOf(user1), balanceBefore + expectedAmount);
        assertEq(token.balanceOf(treasury), treasuryBalanceBefore + expectedPenalty);
    }

    function test_UnstakeAfterLockExpired() public {
        // Stake in 30-day tier
        vm.prank(user1);
        uint256 positionId = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_30);

        // Fast forward past lock period
        vm.warp(block.timestamp + 31 days);

        uint256 balanceBefore = token.balanceOf(user1);
        uint256 pendingRewards = staking.getPendingRewards(user1, positionId);

        // Unstake after lock expired (no penalty, but rewards are claimed)
        vm.prank(user1);
        (uint256 amount, uint256 penalty) = staking.unstake(positionId);

        assertEq(amount, STAKE_AMOUNT);
        assertEq(penalty, 0);
        // Balance should include staked amount + rewards
        assertEq(token.balanceOf(user1), balanceBefore + STAKE_AMOUNT + pendingRewards);
    }

    function test_UnstakeInactivePosition() public {
        vm.prank(user1);
        vm.expectRevert("Staking: position not active");
        staking.unstake(999);
    }

    function test_RewardsCalculation() public {
        // Stake in 30-day tier (5% APY)
        vm.prank(user1);
        uint256 positionId = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_30);

        // Fast forward 30 days
        vm.warp(block.timestamp + 30 days);

        uint256 pendingRewards = staking.getPendingRewards(user1, positionId);

        // Expected reward: (amount * apy * time) / (365 days * 10000)
        // (1000e18 * 500 * 30 days) / (365 days * 10000) H 4.11e18
        assertApproxEqRel(pendingRewards, 4.11e18, 0.01e18); // 1% tolerance
    }

    function test_ClaimRewards() public {
        // Stake in 90-day tier (8% APY)
        vm.prank(user1);
        uint256 positionId = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_90);

        // Fast forward 45 days
        vm.warp(block.timestamp + 45 days);

        uint256 balanceBefore = token.balanceOf(user1);
        uint256 pendingRewards = staking.getPendingRewards(user1, positionId);

        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit RewardsClaimed(user1, positionId, pendingRewards, block.timestamp);
        uint256 claimedRewards = staking.claimRewards(positionId);

        assertEq(claimedRewards, pendingRewards);
        assertEq(token.balanceOf(user1), balanceBefore + claimedRewards);

        // Pending rewards should be 0 after claiming
        assertEq(staking.getPendingRewards(user1, positionId), 0);
    }

    function test_ClaimAllRewards() public {
        vm.startPrank(user1);

        // Create multiple positions
        uint256 pos1 = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_30);
        uint256 pos2 = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_90);
        uint256 pos3 = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_180);

        vm.stopPrank();

        // Fast forward 30 days
        vm.warp(block.timestamp + 30 days);

        uint256 totalPendingBefore = staking.getTotalPendingRewards(user1);
        uint256 balanceBefore = token.balanceOf(user1);

        vm.prank(user1);
        uint256 totalClaimed = staking.claimAllRewards();

        assertEq(totalClaimed, totalPendingBefore);
        assertEq(token.balanceOf(user1), balanceBefore + totalClaimed);
        assertEq(staking.getTotalPendingRewards(user1), 0);
    }

    function test_CanUnstake() public {
        vm.prank(user1);
        uint256 positionId = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_30);

        // Should not be able to unstake initially without penalty
        assertFalse(staking.canUnstake(user1, positionId));

        // Fast forward past lock period
        vm.warp(block.timestamp + 31 days);

        // Should be able to unstake now
        assertTrue(staking.canUnstake(user1, positionId));
    }

    function test_GetUnstakeInfo() public {
        vm.prank(user1);
        uint256 positionId = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_90);

        // Check unstake info during lock period
        (uint256 amount, uint256 penalty) = staking.getUnstakeInfo(user1, positionId);

        uint256 expectedPenalty = (STAKE_AMOUNT * 5_00) / 10_000; // 5%
        uint256 expectedAmount = STAKE_AMOUNT - expectedPenalty;

        assertEq(amount, expectedAmount);
        assertEq(penalty, expectedPenalty);

        // Fast forward past lock period
        vm.warp(block.timestamp + 91 days);

        (amount, penalty) = staking.getUnstakeInfo(user1, positionId);
        assertEq(amount, STAKE_AMOUNT);
        assertEq(penalty, 0);
    }

    function test_EmergencyWithdraw() public {
        vm.prank(user1);
        uint256 positionId = staking.stake(STAKE_AMOUNT, IStaking.LockTier.TIER_365);

        // Emergency withdraw should fail when not in emergency mode
        vm.prank(user1);
        vm.expectRevert("Staking: not in emergency mode");
        staking.emergencyWithdraw(positionId);

        // Enable emergency mode
        vm.prank(owner);
        staking.setEmergencyMode(true);

        uint256 balanceBefore = token.balanceOf(user1);

        // Emergency withdraw should work now
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit EmergencyWithdraw(user1, positionId, STAKE_AMOUNT, block.timestamp);
        staking.emergencyWithdraw(positionId);

        assertEq(token.balanceOf(user1), balanceBefore + STAKE_AMOUNT);
        assertEq(staking.totalStaked(), 0);

        // Position should be inactive
        IStaking.StakePosition memory position = staking.getPosition(user1, positionId);
        assertFalse(position.active);
    }

    function test_AdminFunctions() public {
        // Test tier config update
        vm.prank(owner);
        staking.updateTierConfig(
            IStaking.LockTier.TIER_30,
            45 days,      // new lock duration
            7_00,         // new APY (7%)
            3_00,         // new penalty (3%)
            true          // enabled
        );

        IStaking.TierConfig memory newConfig = staking.getTierConfig(IStaking.LockTier.TIER_30);
        assertEq(newConfig.lockDuration, 45 days);
        assertEq(newConfig.apy, 7_00);
        assertEq(newConfig.penaltyBps, 3_00);
        assertTrue(newConfig.enabled);

        // Test treasury update
        address newTreasury = makeAddr("newTreasury");
        vm.prank(owner);
        staking.updateTreasury(newTreasury);
        assertEq(staking.treasury(), newTreasury);

        // Test pause/unpause
        vm.prank(owner);
        staking.pause();
        assertTrue(staking.paused());

        vm.prank(owner);
        staking.unpause();
        assertFalse(staking.paused());
    }

    function test_AdminOnlyFunctions() public {
        // Non-owner trying to update config
        vm.prank(user1);
        vm.expectRevert();
        staking.updateTierConfig(IStaking.LockTier.TIER_30, 45 days, 7_00, 3_00, true);

        // Non-owner trying to pause
        vm.prank(user1);
        vm.expectRevert();
        staking.pause();

        // Non-owner trying to set emergency mode
        vm.prank(user1);
        vm.expectRevert();
        staking.setEmergencyMode(true);
    }

    function test_GetUserStakedAmount() public {
        vm.startPrank(user1);

        staking.stake(1000 * 10**18, IStaking.LockTier.FLEXIBLE);
        staking.stake(2000 * 10**18, IStaking.LockTier.TIER_30);
        staking.stake(3000 * 10**18, IStaking.LockTier.TIER_90);

        vm.stopPrank();

        uint256 totalStaked = staking.getUserStakedAmount(user1);
        assertEq(totalStaked, 6000 * 10**18);
    }

    function testFuzz_StakeAndUnstake(uint256 amount, uint8 tierIndex) public {
        // Bound inputs
        amount = bound(amount, 1e18, 5000e18); // 1 to 5000 tokens
        tierIndex = uint8(bound(tierIndex, 0, 4)); // 0-4 for tier enum

        IStaking.LockTier tier = IStaking.LockTier(tierIndex);

        // Give user enough tokens
        vm.prank(owner);
        token.mint(user1, amount);

        vm.prank(user1);
        token.approve(address(staking), amount);

        // Stake
        vm.prank(user1);
        uint256 positionId = staking.stake(amount, tier);

        // Verify stake
        assertEq(staking.totalStaked(), amount);

        IStaking.StakePosition memory position = staking.getPosition(user1, positionId);
        assertEq(position.amount, amount);
        assertEq(uint256(position.tier), uint256(tier));
        assertTrue(position.active);

        // Unstake
        vm.prank(user1);
        (uint256 returnedAmount, uint256 penalty) = staking.unstake(positionId);

        // Verify unstake
        assertEq(returnedAmount + penalty, amount);
        assertEq(staking.totalStaked(), 0);
    }
}