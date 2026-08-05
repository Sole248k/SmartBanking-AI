import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/privacy_sensitive_text.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/balance_card.dart';

class AccountDetailsScreen extends ConsumerWidget {

  const AccountDetailsScreen({super.key, required this.account});
  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(account.label),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(account: account),
            const SizedBox(height: AppConstants.xl),
            
            if (kDebugMode) ...[
              AppButton(
                text: 'Add Funds (Debug)',
                icon: Icons.add_circle_outline_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: () => _showAddFundsDialog(context, ref),
              ),
              const SizedBox(height: AppConstants.xl),
            ],
            
            Text(
              'Card Details',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.md),
            AppCard(
              child: Column(
                children: [
                  _DetailRow(label: 'Cardholder', value: account.holderName),
                  const Divider(height: AppConstants.lg),
                  _DetailRow(
                    label: 'Card Number',
                    value: account.cardNumber,
                    isSensitive: true,
                  ),
                  const Divider(height: AppConstants.lg),
                  Row(
                    children: [
                      Expanded(child: _DetailRow(label: 'Expiry', value: account.expiryDate)),
                      Expanded(child: _DetailRow(label: 'CVV', value: account.cvv, isSensitive: true)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.xl),
            Text(
              'Management',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.md),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.ac_unit_rounded, color: Colors.blue),
                    title: const Text('Freeze Card'),
                    subtitle: const Text('Temporarily disable this card'),
                    trailing: Switch.adaptive(value: account.status == AccountStatus.frozen, onChanged: (val) {}),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: const Text('Change PIN'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_input_component_rounded),
                    title: const Text('Limits'),
                    subtitle: const Text('Daily spending and withdrawal limits'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showAddFundsDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Test Funds'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                await ref.read(transactionRepositoryProvider).addFunds(account.id, amount);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {

  const _DetailRow({required this.label, required this.value, this.isSensitive = false});
  final String label;
  final String value;
  final bool isSensitive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          isSensitive
            ? PrivacySensitiveText(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))
            : Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }
}
