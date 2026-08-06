import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/kyc_gatekeeper.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_button.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/product_application_user_providers.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileControllerProvider);
    final profile = profileAsync.value;
    final kycGate = KycGateStatus.parse(profile?.kycStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products & Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'My Applications',
            onPressed: () => context.push('/products/status'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KYC Gatekeeper Banner
            _buildKycGateBanner(context, kycGate),
            const SizedBox(height: AppConstants.md),

            // Prominent My Applications Section
            _buildMyApplicationsCard(context, ref),
            const SizedBox(height: AppConstants.lg),

            _buildCategoryHeader(context, 'Bank Accounts', 'Open new savings and current accounts instantly'),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.savings_rounded,
              iconColor: Colors.amber,
              title: 'New Savings Account',
              description: 'Earn high interest on your savings with zero maintaining balance.',
              ctaText: kycGate.isApproved ? 'Apply Now' : kycGate.ctaButtonText,
              kycGateStatus: kycGate,
              isEnabled: true,
              onTap: () => _handleProductTap(
                context: context,
                kycGate: kycGate,
                productTitle: 'Savings Account',
                onProceed: () => context.push(
                  '/products/new-account',
                  extra: AccountType.savings,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.account_balance_rounded,
              iconColor: Colors.blueAccent,
              title: 'New Current Account',
              description: 'Flexible checking account designed for everyday money management.',
              ctaText: kycGate.isApproved ? 'Apply Now' : kycGate.ctaButtonText,
              kycGateStatus: kycGate,
              isEnabled: true,
              onTap: () => _handleProductTap(
                context: context,
                kycGate: kycGate,
                productTitle: 'Current Account',
                onProceed: () => context.push(
                  '/products/new-account',
                  extra: AccountType.checking,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.xxl),
            _buildCategoryHeader(context, 'Loans & Lending', 'Flexible loans tailored for your financial needs'),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.home_rounded,
              iconColor: Colors.grey,
              title: 'Home Loan',
              description: 'Competitive interest rates for purchasing or constructing your home.',
              isComingSoon: true,
              isEnabled: false,
              kycGateStatus: kycGate,
            ),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.directions_car_rounded,
              iconColor: Colors.grey,
              title: 'Car Loan',
              description: 'Fast approvals and flexible payment terms for your dream vehicle.',
              isComingSoon: true,
              isEnabled: false,
              kycGateStatus: kycGate,
            ),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.person_pin_rounded,
              iconColor: Colors.grey,
              title: 'Personal Loan',
              description: 'Unsecured personal financing with minimal documentary requirements.',
              isComingSoon: true,
              isEnabled: false,
              kycGateStatus: kycGate,
            ),

            const SizedBox(height: AppConstants.xxl),
            _buildCategoryHeader(context, 'Investments & Wealth', 'Grow your wealth with high-yield products'),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.trending_up_rounded,
              iconColor: Colors.grey,
              title: 'Mutual Funds',
              description: 'Professionally managed funds tailored for diverse risk appetites.',
              isComingSoon: true,
              isEnabled: false,
              kycGateStatus: kycGate,
            ),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.lock_clock_rounded,
              iconColor: Colors.grey,
              title: 'Time Deposits',
              description: 'Lock in guaranteed high returns for fixed placement terms.',
              isComingSoon: true,
              isEnabled: false,
              kycGateStatus: kycGate,
            ),
            const SizedBox(height: AppConstants.md),
            _ProductCard(
              icon: Icons.pie_chart_outline_rounded,
              iconColor: Colors.grey,
              title: 'Wealth Management Products',
              description: 'Bespoke financial planning and portfolio solutions for premium clients.',
              isComingSoon: true,
              isEnabled: false,
              kycGateStatus: kycGate,
            ),
            const SizedBox(height: AppConstants.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildKycGateBanner(BuildContext context, KycGateStatus kycGate) {
    final theme = Theme.of(context);
    final color = kycGate.statusColor;

    return Container(
      padding: const EdgeInsets.all(AppConstants.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(kycGate.icon, color: color, size: 28),
          const SizedBox(width: AppConstants.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kycGate.bannerTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kycGate.bannerMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                if (!kycGate.isApproved) ...[
                  const SizedBox(height: AppConstants.sm),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/kyc'),
                    icon: Icon(kycGate.icon, size: 16),
                    label: Text(kycGate.ctaButtonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyApplicationsCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appsAsync = ref.watch(myProductApplicationsProvider);
    final count = appsAsync.value?.length ?? 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
      child: InkWell(
        onTap: () => context.push('/products/status'),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppConstants.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'My Applications',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count > 0
                          ? 'Track status & progress of your $count submitted application${count > 1 ? 's' : ''}'
                          : 'View & track approval status of product applications',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleProductTap({
    required BuildContext context,
    required KycGateStatus kycGate,
    required String productTitle,
    required VoidCallback onProceed,
  }) {
    if (kycGate.isApproved) {
      onProceed();
      return;
    }

    // Show KYC Enforcement Dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
        title: Row(
          children: [
            Icon(kycGate.icon, color: kycGate.statusColor, size: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Identity Verification Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To apply for a $productTitle, banking regulations require an approved Identity Verification (KYC).',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kycGate.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: kycGate.statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                kycGate.bannerMessage,
                style: TextStyle(fontSize: 13, color: kycGate.statusColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kycGate.statusColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/kyc');
            },
            child: Text(kycGate.ctaButtonText),
          ),
        ],
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
    required this.kycGateStatus,
    this.ctaText,
    this.isComingSoon = false,
    this.isEnabled = true,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final KycGateStatus kycGateStatus;
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
                            )
                          else if (!kycGateStatus.isApproved)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: kycGateStatus.statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kycGateStatus.statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                kycGateStatus.badgeText,
                                style: TextStyle(
                                  color: kycGateStatus.statusColor,
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
                                color: isEnabled
                                    ? (kycGateStatus.isApproved
                                        ? theme.colorScheme.primary
                                        : kycGateStatus.statusColor)
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: kycGateStatus.isApproved
                                  ? theme.colorScheme.primary
                                  : kycGateStatus.statusColor,
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
