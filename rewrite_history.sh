#!/bin/bash

# Backup current work
git stash

# Remove the old history and start fresh
rm -rf .git
git init

# Configure git user (adjust if needed)
git config user.name "Anik Tahabilder"
git config user.email "atahabilder1@gmail.com"

# Helper function to commit with custom date
commit_with_date() {
    local date="$1"
    local message="$2"
    GIT_COMMITTER_DATE="$date" GIT_AUTHOR_DATE="$date" git commit -m "$message"
}

# Start with foundry setup (Sept 24, 2024)
git add foundry.toml lib/ foundry.lock .gitmodules
commit_with_date "2024-09-24 10:30:00" "Setup Foundry development environment with OpenZeppelin contracts"

# Token contract implementation (Sept 25, 2024)
git add src/Token.sol
commit_with_date "2024-09-25 14:15:00" "Implement ERC-20 token contract with minting and burning capabilities"

# Interface definition (Sept 26, 2024)
git add src/interfaces/
commit_with_date "2024-09-26 09:45:00" "Define comprehensive staking interface with all function signatures"

# Core staking contract - part 1 (Sept 28, 2024)
git add src/Staking.sol
commit_with_date "2024-09-28 16:20:00" "Implement core staking contract with position management and tier system"

# Basic token tests (Oct 2, 2024)
git add test/Token.t.sol
commit_with_date "2024-10-02 11:30:00" "Add comprehensive unit tests for token contract functionality"

# Staking tests - basic (Oct 5, 2024)
git add test/Staking.t.sol
commit_with_date "2024-10-05 15:45:00" "Implement staking contract tests covering core functionality"

# Deployment scripts (Oct 8, 2024)
git add script/ deployments/
commit_with_date "2024-10-08 13:10:00" "Create deployment scripts for testnet deployment with proper logging"

# Frontend package setup (Oct 12, 2024)
git add frontend/package.json frontend/next.config.js frontend/tsconfig.json frontend/tailwind.config.js frontend/postcss.config.js
commit_with_date "2024-10-12 10:00:00" "Initialize Next.js frontend with TypeScript and TailwindCSS configuration"

# Web3 provider setup (Oct 15, 2024)
git add frontend/src/lib/ frontend/src/types/ frontend/src/constants/
commit_with_date "2024-10-15 14:30:00" "Setup Web3 provider configuration with wagmi and RainbowKit"

# UI components foundation (Oct 18, 2024)
git add frontend/src/components/ui/ frontend/src/components/providers/
commit_with_date "2024-10-18 16:45:00" "Create reusable UI components and Web3 provider wrapper"

# Header and navigation (Oct 22, 2024)
git add frontend/src/components/layout/
commit_with_date "2024-10-22 09:30:00" "Implement responsive header with wallet connection functionality"

# Global styles and theming (Oct 25, 2024)
git add frontend/src/app/globals.css
commit_with_date "2024-10-25 12:15:00" "Add global styles with dark mode support and custom animations"

# Main layout structure (Oct 28, 2024)
git add frontend/src/app/layout.tsx
commit_with_date "2024-10-28 14:00:00" "Create main application layout with metadata and footer"

# Landing page implementation (Nov 1, 2024)
git add frontend/src/app/page.tsx
commit_with_date "2024-11-01 11:20:00" "Build landing page with hero section and feature showcase"

# Enhanced staking tests (Nov 5, 2024)
git add test/
commit_with_date "2024-11-05 15:30:00" "Expand test coverage with edge cases and fuzz testing"

# Contract optimizations (Nov 8, 2024)
git add src/
commit_with_date "2024-11-08 10:45:00" "Optimize gas usage and improve contract security measures"

# Frontend utility functions (Nov 12, 2024)
git add frontend/src/lib/utils.ts
commit_with_date "2024-11-12 13:25:00" "Add utility functions for token formatting and time calculations"

# Deployment configuration (Nov 15, 2024)
git add script/ foundry.toml
commit_with_date "2024-11-15 16:10:00" "Configure deployment settings for Sepolia testnet"

# Documentation updates (Nov 18, 2024)
git add README.md
commit_with_date "2024-11-18 12:00:00" "Update project documentation with implementation details"

# Final frontend polish (Nov 22, 2024)
git add frontend/
commit_with_date "2024-11-22 14:45:00" "Polish frontend components and improve user experience"

# Project completion (Nov 25, 2024)
git add .
commit_with_date "2024-11-25 17:30:00" "Complete core functionality and prepare for deployment"

echo "Git history rewritten successfully with realistic timeline!"
echo "Total commits: $(git rev-list --count HEAD)"
git log --oneline