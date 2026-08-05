import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/providers/dashboard_providers.dart';
import '../../providers/transfer_providers.dart';

class TransferConfirmation extends ConsumerWidget {
  const TransferConfirmation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferControllerProvider);
    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final beneficiary = transferState.selectedBeneficiary!;
    final theme = Theme.of(context);

    final fromAccountLabel = accountsAsync.when(
      data: (accounts) => accounts.isNotEmpty ? '${accounts.first.label} (${accounts.first.accountNumber})' : 'Main Account',
      loading: () => 'Loading...',
      error: (_, _) => 'Error',
    );

    return Padding(
      padding: AppConstants.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Transfer',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.lg),
          AppCard(
            child: Column(
              children: [
                _Row(label: 'From', value: fromAccountLabel),
                const Divider(height: AppConstants.xl),
                _Row(label: 'To', value: beneficiary.name),
                _Row(label: 'Bank', value: beneficiary.bankName),
                _Row(label: 'Account', value: beneficiary.accountNumber),
                const Divider(height: AppConstants.xl),
                _Row(
                  label: 'Amount',
                  value: '₱${transferState.amount.toStringAsFixed(2)}',
                  valueStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (transferState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.md),
              child: Text(
                transferState.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          AppButton(
            text: 'Confirm Transfer',
            isLoading: transferState.isLoading,
            onPressed: () {
              ref.read(transferControllerProvider.notifier).confirmTransfer();
            },
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {

  const _Row({required this.label, required this.value, this.valueStyle});
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          Text(value, style: valueStyle ?? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
