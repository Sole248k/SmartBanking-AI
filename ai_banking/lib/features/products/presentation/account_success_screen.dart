import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class AccountSuccessScreen extends StatelessWidget {
  const AccountSuccessScreen({super.key, required this.successData});

  final Map<String, dynamic> successData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final account = successData['account'] as Account;
    final initialDeposit = successData['initialDeposit'] as double;
    final createdAtRaw = successData['createdAt'] as String?;
    final dateCreated = createdAtRaw != null
        ? DateTime.parse(createdAtRaw).toLocal().toString().split(' ')[0]
        : DateTime.now().toLocal().toString().split(' ')[0];

    final accountTypeName = account.type == AccountType.savings ? 'Savings Account' : 'Current Account';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppConstants.xl),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 72,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: AppConstants.lg),
              Text(
                'Account Successfully Created',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.xs),
              Text(
                'Your new account is active and ready for banking.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.xxl),

              AppCard(
                child: Column(
                  children: [
                    _DetailRow(label: 'Account Name', value: account.label),
                    const Divider(),
                    _DetailRow(label: 'Account Number', value: account.accountNumber),
                    const Divider(),
                    _DetailRow(label: 'Account Type', value: accountTypeName),
                    const Divider(),
                    _DetailRow(
                      label: 'Initial Deposit',
                      value: CurrencyFormatter.format(initialDeposit),
                      isBold: true,
                    ),
                    const Divider(),
                    _DetailRow(label: 'Date Created', value: dateCreated),
                  ],
                ),
              ),

              const Spacer(),
              AppButton(
                text: 'Return Home',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: AppConstants.md),
              AppButton(
                text: 'View Account Details',
                variant: AppButtonVariant.outline,
                icon: Icons.credit_card_rounded,
                onPressed: () => context.go(
                  '/card-management/details',
                  extra: account,
                ),
              ),
              const SizedBox(height: AppConstants.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(width: AppConstants.md),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
