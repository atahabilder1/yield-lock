'use client';

import { useAccount } from 'wagmi';
import { Lock, TrendingUp, Shield, Zap } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { ConnectButton } from '@rainbow-me/rainbowkit';

export default function HomePage() {
  const { isConnected } = useAccount();

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative py-20 lg:py-32 bg-gradient-to-br from-yieldlock-50 to-white dark:from-gray-900 dark:to-gray-800">
        <div className="absolute inset-0 bg-grid-pattern opacity-30"></div>
        <div className="relative container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <div className="flex justify-center mb-8">
              <div className="relative">
                <Lock className="h-16 w-16 text-yieldlock-500" />
                <Zap className="absolute -bottom-2 -right-2 h-8 w-8 text-yellow-500 animate-pulse" />
              </div>
            </div>

            <h1 className="text-4xl sm:text-6xl lg:text-7xl font-bold text-gradient mb-6">
              Stake. Earn. Lock.
            </h1>

            <p className="text-xl sm:text-2xl text-muted-foreground mb-8 max-w-3xl mx-auto">
              Maximize your yield with time-locked staking positions.
              Earn up to <span className="text-yieldlock-600 font-semibold">18% APY</span>
              {' '}by committing to longer lock periods.
            </p>

            {!isConnected ? (
              <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
                <ConnectButton.Custom>
                  {({ openConnectModal }) => (
                    <Button
                      onClick={openConnectModal}
                      variant="yieldlock"
                      size="xl"
                      className="glow-blue"
                    >
                      Connect Wallet to Start
                    </Button>
                  )}
                </ConnectButton.Custom>
                <Button variant="outline" size="xl">
                  Learn More
                </Button>
              </div>
            ) : (
              <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
                <Button
                  variant="yieldlock"
                  size="xl"
                  className="glow-blue"
                  onClick={() => document.getElementById('stake')?.scrollIntoView({ behavior: 'smooth' })}
                >
                  Start Staking
                </Button>
                <Button
                  variant="outline"
                  size="xl"
                  onClick={() => document.getElementById('dashboard')?.scrollIntoView({ behavior: 'smooth' })}
                >
                  View Dashboard
                </Button>
              </div>
            )}

            {/* Quick Stats */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-8 mt-16 max-w-4xl mx-auto">
              <div className="text-center">
                <div className="text-3xl font-bold text-yieldlock-600">5</div>
                <div className="text-sm text-muted-foreground">Lock Tiers</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-yieldlock-600">18%</div>
                <div className="text-sm text-muted-foreground">Max APY</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-yieldlock-600">0</div>
                <div className="text-sm text-muted-foreground">Platform Fees</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-background">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold mb-4">
              Why Choose YieldLock?
            </h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              Built on proven DeFi principles with security and user experience at the forefront.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center p-6 rounded-lg border bg-card hover:shadow-lg transition-shadow">
              <div className="flex justify-center mb-4">
                <TrendingUp className="h-12 w-12 text-yieldlock-500" />
              </div>
              <h3 className="text-xl font-semibold mb-3">Progressive Rewards</h3>
              <p className="text-muted-foreground">
                Earn higher APY rates by committing to longer lock periods.
                From flexible staking to 365-day locks with 18% APY.
              </p>
            </div>

            <div className="text-center p-6 rounded-lg border bg-card hover:shadow-lg transition-shadow">
              <div className="flex justify-center mb-4">
                <Shield className="h-12 w-12 text-yieldlock-500" />
              </div>
              <h3 className="text-xl font-semibold mb-3">Battle-Tested Security</h3>
              <p className="text-muted-foreground">
                Built with OpenZeppelin contracts, comprehensive test suite,
                and security best practices. Your funds are protected.
              </p>
            </div>

            <div className="text-center p-6 rounded-lg border bg-card hover:shadow-lg transition-shadow">
              <div className="flex justify-center mb-4">
                <Zap className="h-12 w-12 text-yieldlock-500" />
              </div>
              <h3 className="text-xl font-semibold mb-3">Instant Claims</h3>
              <p className="text-muted-foreground">
                Claim your rewards anytime without affecting your principal.
                Multiple positions supported for diversified strategies.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Lock Tiers Section */}
      <section className="py-20 bg-muted/30">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold mb-4">
              Choose Your Lock Tier
            </h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              Select the lock period that matches your investment strategy.
              Longer commitments earn higher rewards.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
            {[
              { tier: 'Flexible', duration: '0 days', apy: '0%', penalty: '0%', popular: false },
              { tier: '30 Days', duration: '30 days', apy: '5%', penalty: '2%', popular: false },
              { tier: '90 Days', duration: '90 days', apy: '8%', penalty: '5%', popular: true },
              { tier: '180 Days', duration: '180 days', apy: '12%', penalty: '8%', popular: false },
              { tier: '365 Days', duration: '365 days', apy: '18%', penalty: '12%', popular: false },
            ].map((tier, index) => (
              <div
                key={index}
                className={`relative p-6 rounded-lg border bg-card hover:shadow-lg transition-all ${
                  tier.popular ? 'ring-2 ring-yieldlock-500 scale-105' : ''
                }`}
              >
                {tier.popular && (
                  <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                    <span className="bg-yieldlock-500 text-white text-xs px-3 py-1 rounded-full">
                      Popular
                    </span>
                  </div>
                )}

                <div className="text-center">
                  <h3 className="text-lg font-semibold mb-2">{tier.tier}</h3>
                  <div className="text-2xl font-bold text-yieldlock-600 mb-1">{tier.apy}</div>
                  <div className="text-sm text-muted-foreground mb-4">APY</div>

                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span>Lock:</span>
                      <span>{tier.duration}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Penalty:</span>
                      <span>{tier.penalty}</span>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className="text-center mt-8">
            <p className="text-sm text-muted-foreground">
              Early withdrawal penalties apply only if you unstake before the lock period expires.
              Rewards can be claimed anytime without penalties.
            </p>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-r from-yieldlock-600 to-yieldlock-800 text-white">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl sm:text-4xl font-bold mb-4">
            Ready to Start Earning?
          </h2>
          <p className="text-xl opacity-90 mb-8 max-w-2xl mx-auto">
            Join the YieldLock community and start earning passive income
            from your ERC-20 tokens today.
          </p>

          {!isConnected ? (
            <ConnectButton.Custom>
              {({ openConnectModal }) => (
                <Button
                  onClick={openConnectModal}
                  variant="secondary"
                  size="xl"
                  className="shadow-lg"
                >
                  Connect Wallet
                </Button>
              )}
            </ConnectButton.Custom>
          ) : (
            <Button
              variant="secondary"
              size="xl"
              className="shadow-lg"
              onClick={() => document.getElementById('stake')?.scrollIntoView({ behavior: 'smooth' })}
            >
              Start Staking Now
            </Button>
          )}
        </div>
      </section>

      {/* Placeholder sections for future components */}
      <div id="stake" className="h-20"></div>
      <div id="dashboard" className="h-20"></div>
      <div id="analytics" className="h-20"></div>
    </div>
  );
}