import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/constants/app_constants.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_shimmer.dart';
import '../../app/theme/theme_provider.dart';
import '../../core/services/firebase_service/database_seeder.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/providers/privacy_provider.dart';
import '../profile/providers/profile_providers.dart';
import 'providers/dashboard_providers.dart';
import 'widgets/card_carousel.dart';
import 'widgets/quick_actions.dart';
import 'widgets/transaction_item.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.xl),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: AppConstants.md),
          const Text(
            'No accounts found',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: AppConstants.sm),
          const Text(
            'Get started by seeding your database with mock data or creating a new account.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppConstants.lg),
            AppButton(
              text: 'Seed Database (Debug)',
              onPressed: () async {
                await DatabaseSeeder.seedData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database seeded successfully!')),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon,';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening,';
    } else {
      return 'Good Night,';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final profileAsync = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardAccountsProvider);
            ref.invalidate(recentTransactionsProvider);
            return Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverPadding(
                padding: AppConstants.screenPadding,
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          Text(
                            profileAsync.when(
                              data: (p) => p.fullName,
                              loading: () => 'Loading...',
                              error: (_, _) => 'SmartBank User',
                            ),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          ref.watch(appThemeModeProvider) == ThemeMode.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                        onPressed: () => ref
                            .read(appThemeModeProvider.notifier)
                            .toggleTheme(),
                      ),
                      const SizedBox(width: AppConstants.sm),
                      AppAvatar(
                        name: profileAsync.value?.fullName ?? 'User',
                        imageUrl: profileAsync.value?.avatarUrl,
                        size: 48,
                        onTap: () => context.go('/profile'),
                      ),
                    ],
                  ),
                ),
              ),

              // Card Carousel
              SliverToBoxAdapter(
                key: const ValueKey('dashboard_carousel'),
                child: accountsAsync.when(
                  data: (accounts) {
                    if (accounts.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.lg,
                        ),
                        child: _buildEmptyState(context),
                      );
                    }
                    return CardCarousel(accounts: accounts);
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.lg),
                    child: AppShimmer(
                      width: double.infinity,
                      height: 220,
                      borderRadius: AppConstants.radiusXl,
                    ),
                  ),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.lg,
                    ),
                    child: Text('Error: $err'),
                  ),
                ),
              ),

              // Quick Actions
              const SliverPadding(
                padding: AppConstants.screenPadding,
                sliver: SliverToBoxAdapter(child: QuickActions()),
              ),

              // Recent Transactions Header
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions List
              SliverPadding(
                key: const ValueKey('dashboard_transactions'),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.lg,
                ),
                sliver: transactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppConstants.xl,
                            ),
                            child: Text(
                              'No transactions yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            TransactionItem(transaction: transactions[index]),
                        childCount: transactions.length,
                      ),
                    );
                  },
                  loading: () => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: AppConstants.sm),
                        child: AppShimmer(
                          width: double.infinity,
                          height: 72,
                          borderRadius: AppConstants.radiusLg,
                        ),
                      ),
                      childCount: 5,
                    ),
                  ),
                  error: (err, stack) {
                    if (err.toString().contains('index')) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppConstants.lg),
                            child: Text(
                              'Optimizing your history... This may take a minute.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverToBoxAdapter(child: Text('Error: $err'));
                  },
                ),
              ),

              // Bottom Spacing
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai-assistant'),
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}
