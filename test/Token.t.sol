// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;
    address public owner;
    address public user1;
    address public user2;
    address public treasury;

    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10**18;
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10**18;

    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        treasury = makeAddr("treasury");

        vm.prank(owner);
        token = new Token(owner);
    }

    function test_InitialState() public {
        assertEq(token.name(), "YieldLock");
        assertEq(token.symbol(), "YLD");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
        assertEq(token.owner(), owner);
        assertEq(token.INITIAL_SUPPLY(), INITIAL_SUPPLY);
        assertEq(token.MAX_SUPPLY(), MAX_SUPPLY);
    }

    function test_Mint() public {
        uint256 mintAmount = 100 * 10**18;

        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit TokensMinted(user1, mintAmount);
        token.mint(user1, mintAmount);

        assertEq(token.balanceOf(user1), mintAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
    }

    function test_MintOnlyOwner() public {
        uint256 mintAmount = 100 * 10**18;

        vm.prank(user1);
        vm.expectRevert();
        token.mint(user1, mintAmount);
    }

    function test_MintToZeroAddress() public {
        uint256 mintAmount = 100 * 10**18;

        vm.prank(owner);
        vm.expectRevert("Token: cannot mint to zero address");
        token.mint(address(0), mintAmount);
    }

    function test_MintExceedsMaxSupply() public {
        uint256 excessiveAmount = MAX_SUPPLY - INITIAL_SUPPLY + 1;

        vm.prank(owner);
        vm.expectRevert("Token: would exceed max supply");
        token.mint(user1, excessiveAmount);
    }

    function test_MintUpToMaxSupply() public {
        uint256 remainingSupply = MAX_SUPPLY - INITIAL_SUPPLY;

        vm.prank(owner);
        token.mint(user1, remainingSupply);

        assertEq(token.totalSupply(), MAX_SUPPLY);
        assertEq(token.balanceOf(user1), remainingSupply);
    }

    function test_Burn() public {
        uint256 burnAmount = 100 * 10**18;

        // Give user1 some tokens first
        vm.prank(owner);
        token.transfer(user1, burnAmount);

        vm.prank(user1);
        vm.expectEmit(true, false, false, true);
        emit TokensBurned(user1, burnAmount);
        token.burn(burnAmount);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - burnAmount);
    }

    function test_BurnZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert("Token: amount must be greater than 0");
        token.burn(0);
    }

    function test_BurnInsufficientBalance() public {
        uint256 burnAmount = 100 * 10**18;

        vm.prank(user1);
        vm.expectRevert("Token: insufficient balance to burn");
        token.burn(burnAmount);
    }

    function test_BurnFrom() public {
        uint256 burnAmount = 100 * 10**18;

        // Give user1 some tokens
        vm.prank(owner);
        token.transfer(user1, burnAmount);

        // User1 approves user2 to burn tokens
        vm.prank(user1);
        token.approve(user2, burnAmount);

        vm.prank(user2);
        vm.expectEmit(true, false, false, true);
        emit TokensBurned(user1, burnAmount);
        token.burnFrom(user1, burnAmount);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - burnAmount);
        assertEq(token.allowance(user1, user2), 0);
    }

    function test_BurnFromZeroAmount() public {
        vm.prank(user2);
        vm.expectRevert("Token: amount must be greater than 0");
        token.burnFrom(user1, 0);
    }

    function test_BurnFromZeroAddress() public {
        uint256 burnAmount = 100 * 10**18;

        vm.prank(user2);
        vm.expectRevert("Token: cannot burn from zero address");
        token.burnFrom(address(0), burnAmount);
    }

    function test_BurnFromInsufficientAllowance() public {
        uint256 burnAmount = 100 * 10**18;

        // Give user1 some tokens but no allowance
        vm.prank(owner);
        token.transfer(user1, burnAmount);

        vm.prank(user2);
        vm.expectRevert("Token: insufficient allowance to burn");
        token.burnFrom(user1, burnAmount);
    }

    function test_BurnFromPartialAllowance() public {
        uint256 balance = 200 * 10**18;
        uint256 allowanceAmount = 100 * 10**18;
        uint256 burnAmount = 150 * 10**18;

        // Give user1 tokens and partial allowance
        vm.prank(owner);
        token.transfer(user1, balance);

        vm.prank(user1);
        token.approve(user2, allowanceAmount);

        vm.prank(user2);
        vm.expectRevert("Token: insufficient allowance to burn");
        token.burnFrom(user1, burnAmount);
    }

    function test_StandardERC20Functions() public {
        uint256 transferAmount = 1000 * 10**18;

        // Test transfer
        vm.prank(owner);
        token.transfer(user1, transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);

        // Test approve and transferFrom
        vm.prank(user1);
        token.approve(user2, transferAmount);
        assertEq(token.allowance(user1, user2), transferAmount);

        vm.prank(user2);
        token.transferFrom(user1, treasury, transferAmount);
        assertEq(token.balanceOf(treasury), transferAmount);
        assertEq(token.balanceOf(user1), 0);
    }

    function test_OwnershipTransfer() public {
        vm.prank(owner);
        token.transferOwnership(user1);

        assertEq(token.owner(), user1);

        // Old owner can't mint anymore
        vm.prank(owner);
        vm.expectRevert();
        token.mint(user2, 100 * 10**18);

        // New owner can mint
        vm.prank(user1);
        token.mint(user2, 100 * 10**18);
        assertEq(token.balanceOf(user2), 100 * 10**18);
    }

    function testFuzz_Mint(uint256 amount) public {
        // Bound the amount to prevent overflow and respect max supply
        amount = bound(amount, 1, MAX_SUPPLY - INITIAL_SUPPLY);

        vm.prank(owner);
        token.mint(user1, amount);

        assertEq(token.balanceOf(user1), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + amount);
    }

    function testFuzz_Burn(uint256 amount) public {
        // First give user1 the max possible tokens
        uint256 userBalance = INITIAL_SUPPLY / 2;
        vm.prank(owner);
        token.transfer(user1, userBalance);

        // Bound the burn amount
        amount = bound(amount, 1, userBalance);

        vm.prank(user1);
        token.burn(amount);

        assertEq(token.balanceOf(user1), userBalance - amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - amount);
    }

    function test_ComplexScenario() public {
        // Multi-step scenario testing
        uint256 mintAmount = 500_000 * 10**18;
        uint256 transferAmount = 100_000 * 10**18;
        uint256 burnAmount = 50_000 * 10**18;

        // 1. Mint tokens to user1
        vm.prank(owner);
        token.mint(user1, mintAmount);

        // 2. User1 transfers to user2
        vm.prank(user1);
        token.transfer(user2, transferAmount);

        // 3. User2 burns some tokens
        vm.prank(user2);
        token.burn(burnAmount);

        // 4. Check final state
        assertEq(token.balanceOf(user1), mintAmount - transferAmount);
        assertEq(token.balanceOf(user2), transferAmount - burnAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount - burnAmount);
    }
}