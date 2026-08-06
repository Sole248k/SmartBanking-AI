import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/models/account.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products & Services'),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(context, 'Bank Accounts', 'Open new savings and current accounts instantly'),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.savings_rounded,
              iconColor: Colors.amber,
              title: 'New Savings Account',
              description: 'Earn high interest on your savings with zero maintaining balance.',
              ctaText: 'Apply Now',
              isEnabled: true,
              onTap: () => context.push(
                '/products/new-account',
                extra: AccountType.savings,
              ),
            ),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.account_balance_rounded,
              iconColor: Colors.blueAccent,
              title: 'New Current Account',
              description: 'Flexible checking account designed for everyday money management.',
              ctaText: 'Apply Now',
              isEnabled: true,
              onTap: () => context.push(
                '/products/new-account',
                extra: AccountType.checking,
              ),
            ),

            const SizedBox(height: AppConstants.xxl),
            _buildCategoryHeader(context, 'Loans & Lending', 'Flexible loans tailored for your financial needs'),
            const SizedBox(height: AppConstants.md),
            const _ProductCard(
              icon: Icons.home_rounded,
              iconColor: Colors.grey,
              title: 'Home Loan',
              description: 'Competitive interest rates for purchasing or constructing your home.',
              isComingSoon: true,
              isEnabled: false,
            ),
            const SizedBox(height: AppConstants.md),
            const _ProductCard(
              icon: Icons.directions_car_rounded,
              iconColor: Colors.grey,
              title: 'Car Loan',
              description: 'Fast approvals and flexible payment terms for your dream vehicle.',
              isComingSoon: true,
              isEnabled: false,
            ),
            const SizedBox(height: AppConstants.md),
            const _ProductCard(
              icon: Icons.person_pin_rounded,
              iconColor: Colors.grey,
              title: 'Personal Loan',
              description: 'Unsecured personal financing with minimal documentary requirements.',
              isComingSoon: true,
              isEnabled: false,
            ),

            const SizedBox(height: AppConstants.xxl),
            _buildCategoryHeader(context, 'Investments & Wealth', 'Grow your wealth with high-yield products'),
            const SizedBox(height: AppConstants.md),
            const _ProductCard(
              icon: Icons.trending_up_rounded,
              iconColor: Colors.grey,
              title: 'Mutual Funds',
              description: 'Professionally managed funds tailored for diverse risk appetites.',
              isComingSoon: true,
              isEnabled: false,
            ),
            const SizedBox(height: AppConstants.md),
            const _ProductCard(
              icon: Icons.lock_clock_rounded,
              iconColor: Colors.grey,
              title: 'Time Deposits',
              description: 'Lock in guaranteed high returns for fixed placement terms.',
              isComingSoon: true,
              isEnabled: false,
            ),
            const SizedBox(height: AppConstants.md),
            const _ProductCard(
              icon: Icons.pie_chart_outline_rounded,
              iconColor: Colors.grey,
              title: 'Wealth Management Products',
              description: 'Bespoke financial planning and portfolio solutions for premium clients.',
              isComingSoon: true,
              isEnabled: false,
            ),
            const SizedBox(height: AppConstants.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.ctaText,
    this.isComingSoon = false,
    this.isEnabled = true,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String? ctaText;
  final bool isComingSoon;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = isEnabled
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Card(
        elevation: isEnabled ? 2 : 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: BorderSide(
            color: isEnabled
                ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.md),
                  decoration: BoxDecoration(
                    color: (isEnabled ? iconColor : Colors.grey).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: isEnabled ? iconColor : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppConstants.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isEnabled ? theme.colorScheme.onSurface : Colors.grey[600],
                              ),
                            ),
                          ),
                          if (isComingSoon)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                              ),
                              child: const Text(
                                'Coming Soon',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isEnabled
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                              : Colors.grey[500],
                        ),
                      ),
                      if (isEnabled && ctaText != null) ...[
                        const SizedBox(height: AppConstants.sm),
                        Row(
                          children: [
                            Text(
                              ctaText!,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
