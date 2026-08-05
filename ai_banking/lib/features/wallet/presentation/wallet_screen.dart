import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shimmer.dart';
import '../providers/wallet_providers.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletControllerProvider);
          return Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              walletAsync.when(
                data: (wallet) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.xl),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Balance',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppConstants.sm),
                      Text(
                        '₱ ${wallet.balance.toStringAsFixed(2)}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const AppShimmer(
                  width: double.infinity,
                  height: 160,
                  borderRadius: AppConstants.radiusXl,
                ),
                error: (err, stack) => Text('Error: $err'),
              ),
              const SizedBox(height: AppConstants.xl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Top Up',
                      icon: Icons.add_rounded,
                      onPressed: () => context.push('/wallet/top-up'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.md),
                  Expanded(
                    child: AppButton(
                      text: 'Withdraw',
                      icon: Icons.account_balance_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.xxl),
              Text(
                'Wallet History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.md),
              AppCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.xl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: AppConstants.md),
                        const Text(
                          'No wallet transactions yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
