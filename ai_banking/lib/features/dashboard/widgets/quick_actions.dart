import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/kyc_gatekeeper.dart';
import '../../profile/providers/profile_providers.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final kycGate = KycGateStatus.parse(profileAsync.value?.kycStatus);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionButton(
              icon: Icons.send_rounded,
              label: 'Send',
              onTap: () => context.go('/transfer'),
            ),
            _ActionButton(
              icon: Icons.call_received_rounded,
              label: 'Request',
              onTap: () => context.push('/request-money'),
            ),
            _ActionButton(
              icon: Icons.receipt_long_rounded,
              label: 'Bills',
              onTap: () => context.push('/pay-bills'),
            ),
            _ActionButton(
              icon: Icons.add_circle_outline_rounded,
              label: 'Top-up',
              onTap: () => context.push('/wallet/top-up'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionButton(
              icon: Icons.savings_rounded,
              label: 'Savings',
              onTap: () => context.push('/savings'),
            ),
            _ActionButton(
              icon: kycGate.isApproved ? Icons.check_circle_rounded : kycGate.icon,
              iconColor: kycGate.isApproved ? Colors.green : kycGate.statusColor,
              label: kycGate.isApproved ? 'Verified' : kycGate.badgeText,
              onTap: () => context.push('/kyc'),
            ),
            _ActionButton(
              icon: Icons.pie_chart_rounded,
              label: 'Budgets',
              onTap: () => context.push('/budgets'),
            ),
            _ActionButton(
              icon: Icons.show_chart_rounded,
              label: 'Invest',
              onTap: () => context.push('/invest'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(height: AppConstants.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}