// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title YieldLock Token (YLD)
 * @dev ERC20 token for the YieldLock staking ecosystem
 * @dev Implements standard ERC20 functionality with owner-controlled minting
 */
contract Token is ERC20, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10**18; // 1M tokens with 18 decimals
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10**18; // 10M max supply cap

    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    /**
     * @dev Constructor that gives msg.sender all of initial supply
     * @param initialOwner The address that will own the contract
     */
    constructor(address initialOwner) ERC20("YieldLock", "YLD") Ownable(initialOwner) {
        _mint(initialOwner, INITIAL_SUPPLY);
    }

    /**
     * @dev Mint new tokens to a specified address
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     * Requirements:
     * - Only owner can mint
     * - Cannot exceed max supply
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Token: cannot mint to zero address");
        require(totalSupply() + amount <= MAX_SUPPLY, "Token: would exceed max supply");

        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @dev Burn tokens from the caller's balance
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) external {
        require(amount > 0, "Token: amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Token: insufficient balance to burn");

        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @dev Burn tokens from a specified address (requires allowance)
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function burnFrom(address from, uint256 amount) external {
        require(amount > 0, "Token: amount must be greater than 0");
        require(from != address(0), "Token: cannot burn from zero address");

        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= amount, "Token: insufficient allowance to burn");

        _spendAllowance(from, msg.sender, amount);
        _burn(from, amount);
        emit TokensBurned(from, amount);
    }

    /**
     * @dev Returns the number of decimal places for the token
     * @return The number of decimals (18)
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }
}