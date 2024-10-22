'use client';

import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useAccount, useNetwork } from 'wagmi';
import { AlertTriangle, Lock, Zap } from 'lucide-react';
import { isSupportedChain } from '@/lib/web3';
import { cn } from '@/lib/utils';

export default function Header() {
  const { isConnected } = useAccount();
  const { chain } = useNetwork();

  const isWrongNetwork = isConnected && chain && !isSupportedChain(chain.id);

  return (
    <header className="border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 sticky top-0 z-50">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo and Brand */}
          <div className="flex items-center space-x-3">
            <div className="relative">
              <Lock className="h-8 w-8 text-yieldlock-500" />
              <Zap className="absolute -bottom-1 -right-1 h-4 w-4 text-yellow-500" />
            </div>
            <div className="flex flex-col">
              <h1 className="text-xl font-bold text-foreground">YieldLock</h1>
              <p className="text-xs text-muted-foreground hidden sm:block">
                Stake • Earn • Lock
              </p>
            </div>
          </div>

          {/* Navigation */}
          <nav className="hidden md:flex items-center space-x-8">
            <a
              href="#stake"
              className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
            >
              Stake
            </a>
            <a
              href="#dashboard"
              className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
            >
              Dashboard
            </a>
            <a
              href="#analytics"
              className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
            >
              Analytics
            </a>
          </nav>

          {/* Wallet Connection */}
          <div className="flex items-center space-x-4">
            {isWrongNetwork && (
              <div className="flex items-center space-x-2 px-3 py-1 rounded-md bg-destructive/10 text-destructive text-sm">
                <AlertTriangle className="h-4 w-4" />
                <span className="hidden sm:inline">Wrong Network</span>
              </div>
            )}

            <ConnectButton.Custom>
              {({
                account,
                chain,
                openAccountModal,
                openChainModal,
                openConnectModal,
                authenticationStatus,
                mounted,
              }) => {
                const ready = mounted && authenticationStatus !== 'loading';
                const connected =
                  ready &&
                  account &&
                  chain &&
                  (!authenticationStatus || authenticationStatus === 'authenticated');

                return (
                  <div
                    {...(!ready && {
                      'aria-hidden': true,
                      style: {
                        opacity: 0,
                        pointerEvents: 'none',
                        userSelect: 'none',
                      },
                    })}
                  >
                    {(() => {
                      if (!connected) {
                        return (
                          <button
                            onClick={openConnectModal}
                            type="button"
                            className={cn(
                              'inline-flex items-center px-4 py-2 border border-transparent',
                              'text-sm font-medium rounded-md text-white',
                              'bg-yieldlock-600 hover:bg-yieldlock-700',
                              'focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yieldlock-500',
                              'transition-colors duration-200'
                            )}
                          >
                            Connect Wallet
                          </button>
                        );
                      }

                      if (chain.unsupported) {
                        return (
                          <button
                            onClick={openChainModal}
                            type="button"
                            className={cn(
                              'inline-flex items-center px-4 py-2 border border-transparent',
                              'text-sm font-medium rounded-md text-white',
                              'bg-destructive hover:bg-destructive/90',
                              'focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-destructive',
                              'transition-colors duration-200'
                            )}
                          >
                            Wrong network
                          </button>
                        );
                      }

                      return (
                        <div className="flex items-center space-x-2">
                          <button
                            onClick={openChainModal}
                            style={{ display: 'flex', alignItems: 'center' }}
                            type="button"
                            className={cn(
                              'px-3 py-2 rounded-md text-sm font-medium',
                              'bg-secondary hover:bg-secondary/80',
                              'transition-colors duration-200',
                              'flex items-center space-x-2'
                            )}
                          >
                            {chain.hasIcon && (
                              <div
                                style={{
                                  background: chain.iconBackground,
                                  width: 16,
                                  height: 16,
                                  borderRadius: 999,
                                  overflow: 'hidden',
                                }}
                              >
                                {chain.iconUrl && (
                                  <img
                                    alt={chain.name ?? 'Chain icon'}
                                    src={chain.iconUrl}
                                    style={{ width: 16, height: 16 }}
                                  />
                                )}
                              </div>
                            )}
                            <span className="hidden sm:inline">{chain.name}</span>
                          </button>

                          <button
                            onClick={openAccountModal}
                            type="button"
                            className={cn(
                              'px-4 py-2 rounded-md text-sm font-medium',
                              'bg-primary hover:bg-primary/90 text-primary-foreground',
                              'transition-colors duration-200',
                              'flex items-center space-x-2'
                            )}
                          >
                            <span>{account.displayName}</span>
                            <span className="hidden sm:inline text-xs opacity-70">
                              {account.displayBalance
                                ? ` (${account.displayBalance})`
                                : ''}
                            </span>
                          </button>
                        </div>
                      );
                    })()}
                  </div>
                );
              }}
            </ConnectButton.Custom>
          </div>
        </div>
      </div>
    </header>
  );
}