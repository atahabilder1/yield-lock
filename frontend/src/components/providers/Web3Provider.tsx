'use client';

import { ReactNode } from 'react';
import { WagmiConfig } from 'wagmi';
import { RainbowKitProvider, darkTheme, lightTheme } from '@rainbow-me/rainbowkit';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { wagmiConfig, chains } from '@/lib/web3';

// Create a client for React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      cacheTime: 1000 * 60 * 10, // 10 minutes
      retry: 3,
      refetchOnWindowFocus: false,
    },
  },
});

interface Web3ProviderProps {
  children: ReactNode;
}

export default function Web3Provider({ children }: Web3ProviderProps) {
  return (
    <QueryClientProvider client={queryClient}>
      <WagmiConfig config={wagmiConfig}>
        <RainbowKitProvider
          chains={chains}
          theme={{
            lightMode: lightTheme({
              accentColor: '#0ea5e9',
              accentColorForeground: 'white',
              borderRadius: 'medium',
              fontStack: 'system',
            }),
            darkMode: darkTheme({
              accentColor: '#0ea5e9',
              accentColorForeground: 'white',
              borderRadius: 'medium',
              fontStack: 'system',
            }),
          }}
          appInfo={{
            appName: 'YieldLock',
            disclaimer: ({ Text, Link }) => (
              <Text>
                By connecting your wallet, you agree to the{' '}
                <Link href="/terms">Terms of Service</Link> and acknowledge that
                you have read and understand the{' '}
                <Link href="/privacy">Privacy Policy</Link>.
              </Text>
            ),
          }}
          showRecentTransactions={true}
        >
          {children}
        </RainbowKitProvider>
      </WagmiConfig>
    </QueryClientProvider>
  );
}