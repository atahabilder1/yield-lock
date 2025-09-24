'use client';

import { getDefaultWallets } from '@rainbow-me/rainbowkit';
import { configureChains, createConfig } from 'wagmi';
import { sepolia } from 'viem/chains';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import { publicProvider } from 'wagmi/providers/public';
import { DEFAULT_CHAIN, SUPPORTED_CHAINS } from '@/constants/contracts';

// Configure chains and providers
const { chains, publicClient, webSocketPublicClient } = configureChains(
  SUPPORTED_CHAINS,
  [
    // Add Alchemy provider if API key is available
    ...(process.env.NEXT_PUBLIC_ALCHEMY_API_KEY
      ? [alchemyProvider({ apiKey: process.env.NEXT_PUBLIC_ALCHEMY_API_KEY })]
      : []),
    publicProvider(),
  ]
);

// Configure wallets
const { connectors } = getDefaultWallets({
  appName: 'YieldLock',
  projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID || 'fallback-project-id',
  chains,
});

// Create wagmi config
export const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
  webSocketPublicClient,
});

export { chains, DEFAULT_CHAIN };

// Helper to get current chain ID
export function getCurrentChainId(): number {
  if (typeof window === 'undefined') return DEFAULT_CHAIN.id;
  return window.ethereum?.chainId ? parseInt(window.ethereum.chainId, 16) : DEFAULT_CHAIN.id;
}

// Helper to check if current chain is supported
export function isSupportedChain(chainId: number): boolean {
  return SUPPORTED_CHAINS.some(chain => chain.id === chainId);
}