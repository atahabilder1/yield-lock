// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";

/**
 * @title Deploy Token Script
 * @dev Deploys the YieldLock ERC-20 token contract
 * @dev Usage: forge script script/DeployToken.s.sol --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast
 */
contract DeployToken is Script {
    function run() external returns (Token token) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying Token contract...");
        console.log("Deployer address:", deployer);
        console.log("Deployer balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Token contract with deployer as initial owner
        token = new Token(deployer);

        vm.stopBroadcast();

        console.log("Token deployed to:", address(token));
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("Initial supply:", token.totalSupply());
        console.log("Max supply:", token.MAX_SUPPLY());
        console.log("Owner:", token.owner());

        // Save deployment info to file
        _saveDeploymentInfo(address(token), deployer);
    }

    function _saveDeploymentInfo(address tokenAddress, address owner) private {
        string memory deploymentInfo = string.concat(
            "# YieldLock Token Deployment\n",
            "Network: Sepolia Testnet\n",
            "Token Address: ", vm.toString(tokenAddress), "\n",
            "Owner: ", vm.toString(owner), "\n",
            "Deployed At: ", vm.toString(block.timestamp), "\n",
            "Block Number: ", vm.toString(block.number), "\n"
        );

        vm.writeFile("./deployments/token-deployment.md", deploymentInfo);
        console.log("Deployment info saved to ./deployments/token-deployment.md");
    }
}