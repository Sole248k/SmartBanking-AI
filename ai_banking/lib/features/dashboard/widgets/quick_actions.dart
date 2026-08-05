import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
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
              icon: Icons.verified_user_rounded,
              label: 'Verify',
              onTap: () => context.push('/kyc'),
            ),
            _ActionButton(
              icon: Icons.pie_chart_rounded,
              label: 'Budgets',
              onTap: () => context.push('/budgets'),
            ),
            _ActionButton(
              icon: Icons.more_horiz_rounded,
              label: 'More',
              onTap: () {},
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
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: AppConstants.sm),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
