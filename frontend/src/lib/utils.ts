import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { formatUnits, parseUnits } from 'viem';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Format token amounts for display
export function formatTokenAmount(
  amount: bigint,
  decimals: number = 18,
  displayDecimals: number = 4
): string {
  const formatted = formatUnits(amount, decimals);
  const num = parseFloat(formatted);

  if (num === 0) return '0';
  if (num < 0.0001) return '< 0.0001';

  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits: 0,
    maximumFractionDigits: displayDecimals,
  }).format(num);
}

// Parse token amounts from user input
export function parseTokenAmount(amount: string, decimals: number = 18): bigint {
  try {
    // Remove any non-numeric characters except decimal point
    const cleaned = amount.replace(/[^0-9.]/g, '');
    if (!cleaned || cleaned === '.') return 0n;

    return parseUnits(cleaned, decimals);
  } catch {
    return 0n;
  }
}

// Format percentage values
export function formatPercentage(value: number, decimals: number = 2): string {
  return new Intl.NumberFormat('en-US', {
    style: 'percent',
    minimumFractionDigits: 0,
    maximumFractionDigits: decimals,
  }).format(value / 100);
}

// Format duration from seconds to human readable
export function formatDuration(seconds: bigint): string {
  const num = Number(seconds);
  if (num === 0) return 'Flexible';

  const days = Math.floor(num / (24 * 60 * 60));

  if (days === 0) {
    const hours = Math.floor(num / (60 * 60));
    if (hours === 0) {
      const minutes = Math.floor(num / 60);
      return `${minutes}m`;
    }
    return `${hours}h`;
  }

  if (days < 30) return `${days}d`;
  if (days < 365) return `${Math.floor(days / 30)}mo`;
  return `${Math.floor(days / 365)}y`;
}

// Calculate time remaining until lock expires
export function calculateTimeRemaining(stakedAt: bigint, lockDuration: bigint): {
  isLocked: boolean;
  timeRemaining: bigint;
  progress: number;
} {
  const now = BigInt(Math.floor(Date.now() / 1000));
  const unlockTime = stakedAt + lockDuration;

  if (lockDuration === 0n) {
    return { isLocked: false, timeRemaining: 0n, progress: 100 };
  }

  if (now >= unlockTime) {
    return { isLocked: false, timeRemaining: 0n, progress: 100 };
  }

  const timeRemaining = unlockTime - now;
  const timeElapsed = now - stakedAt;
  const progress = Number((timeElapsed * 100n) / lockDuration);

  return { isLocked: true, timeRemaining, progress: Math.min(progress, 100) };
}

// Format time remaining
export function formatTimeRemaining(seconds: bigint): string {
  const num = Number(seconds);

  const days = Math.floor(num / (24 * 60 * 60));
  const hours = Math.floor((num % (24 * 60 * 60)) / (60 * 60));
  const minutes = Math.floor((num % (60 * 60)) / 60);

  if (days > 0) return `${days}d ${hours}h`;
  if (hours > 0) return `${hours}h ${minutes}m`;
  return `${minutes}m`;
}

// Calculate APY for display
export function calculateDisplayAPY(apyBps: bigint): number {
  return Number(apyBps) / 100; // Convert from basis points to percentage
}

// Calculate penalty for display
export function calculateDisplayPenalty(penaltyBps: bigint): number {
  return Number(penaltyBps) / 100; // Convert from basis points to percentage
}

// Truncate address for display
export function truncateAddress(address: string, chars: number = 4): string {
  if (!address) return '';
  return `${address.slice(0, 2 + chars)}...${address.slice(-chars)}`;
}

// Format large numbers with K, M, B suffixes
export function formatCompactNumber(num: number): string {
  if (num < 1000) return num.toString();
  if (num < 1000000) return (num / 1000).toFixed(1) + 'K';
  if (num < 1000000000) return (num / 1000000).toFixed(1) + 'M';
  return (num / 1000000000).toFixed(1) + 'B';
}

// Validate address format
export function isValidAddress(address: string): boolean {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
}

// Get explorer URL for address or transaction
export function getExplorerUrl(hashOrAddress: string, type: 'address' | 'tx' = 'address'): string {
  const baseUrl = 'https://sepolia.etherscan.io';
  return `${baseUrl}/${type}/${hashOrAddress}`;
}

// Sleep utility for async operations
export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Debounce utility
export function debounce<T extends (...args: any[]) => void>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout;
  return (...args: Parameters<T>) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
}