import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../providers/wallet_providers.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);
    final accountsAsync = ref.watch(dashboardAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Wallet'),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No linked accounts found'));
          }
          final primaryAccount = accounts.first;

          return Padding(
            padding: AppConstants.screenPadding,
            child: Column(
              children: [
                AppTextField(
                  label: 'From Account',
                  hint: '${primaryAccount.label} (${primaryAccount.accountNumber})',
                  readOnly: true,
                  prefixIcon: Icons.account_balance_rounded,
                ),
                const SizedBox(height: AppConstants.lg),
                AppTextField(
                  controller: _controller,
                  label: 'Amount',
                  hint: '0.00',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.account_balance_wallet_rounded,
                ),
                const Spacer(),
                AppButton(
                  text: 'Confirm Top Up',
                  isLoading: walletState.isLoading,
                  onPressed: () async {
                    final amount = double.tryParse(_controller.text) ?? 0.0;
                    if (amount > 0) {
                      await ref.read(walletControllerProvider.notifier).topUp(amount, primaryAccount.id);
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
