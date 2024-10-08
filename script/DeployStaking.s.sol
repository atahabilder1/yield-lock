// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";
import {Staking} from "../src/Staking.sol";
import {IStaking} from "../src/interfaces/IStaking.sol";

/**
 * @title Deploy Staking Script
 * @dev Deploys the complete YieldLock staking system
 * @dev Usage: forge script script/DeployStaking.s.sol --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast
 */
contract DeployStaking is Script {
    function run() external returns (Token token, Staking staking) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // Treasury address (you can set this to a multisig in production)
        address treasury = vm.envOr("TREASURY_ADDRESS", deployer);

        console.log("Deploying YieldLock Staking System...");
        console.log("Deployer address:", deployer);
        console.log("Treasury address:", treasury);
        console.log("Deployer balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Token contract
        console.log("\n1. Deploying Token contract...");
        token = new Token(deployer);
        console.log("Token deployed to:", address(token));

        // 2. Deploy Staking contract
        console.log("\n2. Deploying Staking contract...");
        staking = new Staking(address(token), treasury, deployer);
        console.log("Staking deployed to:", address(staking));

        // 3. Setup initial configuration
        console.log("\n3. Setting up initial configuration...");

        // Mint some tokens to the staking contract for rewards
        uint256 rewardPoolAmount = 5_000_000 * 10**18; // 5M tokens for rewards
        token.mint(address(staking), rewardPoolAmount);
        console.log("Minted", rewardPoolAmount, "tokens to staking contract for rewards");

        // Optionally mint some tokens to deployer for testing
        uint256 testTokens = 100_000 * 10**18; // 100K tokens for testing
        token.mint(deployer, testTokens);
        console.log("Minted", testTokens, "tokens to deployer for testing");

        vm.stopBroadcast();

        // 4. Display deployment summary
        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("Token Contract:", address(token));
        console.log("  - Name:", token.name());
        console.log("  - Symbol:", token.symbol());
        console.log("  - Total Supply:", token.totalSupply());
        console.log("  - Owner:", token.owner());

        console.log("\nStaking Contract:", address(staking));
        console.log("  - Staking Token:", address(staking.stakingToken()));
        console.log("  - Treasury:", staking.treasury());
        console.log("  - Owner:", staking.owner());
        console.log("  - Emergency Mode:", staking.emergencyMode());
        console.log("  - Paused:", staking.paused());

        // Display tier configurations
        _displayTierConfigs(staking);

        // Save deployment info
        _saveDeploymentInfo(address(token), address(staking), deployer, treasury);

        return (token, staking);
    }

    function _displayTierConfigs(Staking staking) private view {
        console.log("\n=== TIER CONFIGURATIONS ===");

        IStaking.LockTier[5] memory tiers = [
            IStaking.LockTier.FLEXIBLE,
            IStaking.LockTier.TIER_30,
            IStaking.LockTier.TIER_90,
            IStaking.LockTier.TIER_180,
            IStaking.LockTier.TIER_365
        ];

        string[5] memory tierNames = ["Flexible", "30 Days", "90 Days", "180 Days", "365 Days"];

        for (uint i = 0; i < tiers.length; i++) {
            IStaking.TierConfig memory config = staking.getTierConfig(tiers[i]);
            console.log(string.concat(tierNames[i], ":"));
            console.log("  Lock Duration:", config.lockDuration, "seconds");
            console.log("  APY:", config.apy, "bps");
            console.log("  Penalty:", config.penaltyBps, "bps");
            console.log("  Enabled:", config.enabled);
        }
    }

    function _saveDeploymentInfo(
        address tokenAddress,
        address stakingAddress,
        address owner,
        address treasury
    ) private {
        string memory deploymentInfo = string.concat(
            "# YieldLock Complete Deployment\n\n",
            "## Network Information\n",
            "- Network: Sepolia Testnet\n",
            "- Deployed At: ", vm.toString(block.timestamp), "\n",
            "- Block Number: ", vm.toString(block.number), "\n",
            "- Deployer: ", vm.toString(owner), "\n\n",
            "## Contract Addresses\n",
            "- Token Contract: `", vm.toString(tokenAddress), "`\n",
            "- Staking Contract: `", vm.toString(stakingAddress), "`\n",
            "- Treasury: `", vm.toString(treasury), "`\n\n",
            "## Contract Verification\n",
            "```bash\n",
            "# Verify Token contract\n",
            "forge verify-contract ", vm.toString(tokenAddress), " src/Token.sol:Token --chain sepolia\n\n",
            "# Verify Staking contract\n",
            "forge verify-contract ", vm.toString(stakingAddress), " src/Staking.sol:Staking --chain sepolia --constructor-args $(cast abi-encode \"constructor(address,address,address)\" ", vm.toString(tokenAddress), " ", vm.toString(treasury), " ", vm.toString(owner), ")\n",
            "```\n\n",
            "## Usage\n",
            "1. Users can approve the staking contract to spend their tokens\n",
            "2. Users can stake tokens in different tiers (Flexible, 30d, 90d, 180d, 365d)\n",
            "3. Users earn rewards based on APY and time staked\n",
            "4. Early withdrawal applies penalties based on tier\n",
            "5. Admin can pause/unpause, update configurations, and handle emergencies\n"
        );

        vm.writeFile("./deployments/complete-deployment.md", deploymentInfo);
        console.log("\nDeployment info saved to ./deployments/complete-deployment.md");
    }
}