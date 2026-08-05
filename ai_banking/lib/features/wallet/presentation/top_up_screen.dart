import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/pin_utils.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/active_account_provider.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/wallet_providers.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final _controller = TextEditingController();
  String _selectedFundingSource = 'Online Banking Payment Gateway';

  static const List<String> _fundingSources = [
    'Online Banking Payment Gateway',
    'Visa / Mastercard Direct Deposit',
    'E-Wallet (GCash / Maya Portal)',
    'Bank Over-The-Counter Deposit',
  ];

  void _showPinModal(BuildContext context, double amount, String savingsAccountId) {
    String enteredPin = '';
    String? pinError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final profile = ref.read(profileControllerProvider).value;

          void onKeyPress(String digit) async {
            if (enteredPin.length < 6) {
              setModalState(() {
                pinError = null;
                enteredPin += digit;
              });

              if (enteredPin.length == 6) {
                if (profile != null && PinUtils.verifyPin(enteredPin, profile.pinHash)) {
                  Navigator.pop(modalContext);
                  await _executeTopUp(amount, savingsAccountId);
                } else {
                  setModalState(() {
                    enteredPin = '';
                    pinError = 'Incorrect Security PIN. Please try again.';
                  });
                }
              }
            }
          }

          void onBackspace() {
            if (enteredPin.isNotEmpty) {
              setModalState(() {
                pinError = null;
                enteredPin = enteredPin.substring(0, enteredPin.length - 1);
              });
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security_rounded, color: AppTheme.primaryColor, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'Authorize Top-Up',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter 6-digit PIN to deposit ₱${amount.toStringAsFixed(2)} into SmartBank AI Card',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < enteredPin.length ? AppTheme.primaryColor : Colors.white24,
                      ),
                    ),
                  ),
                ),
                if (pinError != null) ...[
                  const SizedBox(height: 12),
                  Text(pinError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 24),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PinBtn('1', () => onKeyPress('1')),
                        _PinBtn('2', () => onKeyPress('2')),
                        _PinBtn('3', () => onKeyPress('3')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PinBtn('4', () => onKeyPress('4')),
                        _PinBtn('5', () => onKeyPress('5')),
                        _PinBtn('6', () => onKeyPress('6')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PinBtn('7', () => onKeyPress('7')),
                        _PinBtn('8', () => onKeyPress('8')),
                        _PinBtn('9', () => onKeyPress('9')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 60, height: 60),
                        _PinBtn('0', () => onKeyPress('0')),
                        InkWell(
                          onTap: onBackspace,
                          borderRadius: BorderRadius.circular(30),
                          child: const SizedBox(
                            width: 60,
                            height: 60,
                            child: Icon(Icons.backspace_outlined, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _executeTopUp(double amount, String targetAccountId) async {
    final result = await ref
        .read(walletControllerProvider.notifier)
        .topUp(amount, targetAccountId);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Top-Up Error: ${failure.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      (_) {
        // Switch active card to SmartBank Savings so the updated balance displays immediately on Dashboard
        final accounts = ref.read(dashboardAccountsProvider).value ?? [];
        final savingsAcc = accounts.where((a) => a.id == targetAccountId || !a.isExternal).firstOrNull;
        if (savingsAcc != null) {
          ref.read(activeAccountProvider.notifier).select(savingsAcc);
        }

        // Invalidate to trigger background updates
        ref.invalidate(dashboardAccountsProvider);
        ref.invalidate(recentTransactionsProvider);

        if (mounted) {
          final refCode = 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: AppConstants.md),
                    const Text(
                      'Top-Up Successful!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Funds committed to database ledger',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: AppConstants.lg),

                    // Breakdown Box
                    Container(
                      padding: const EdgeInsets.all(AppConstants.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Deposited Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                '+₱${amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Destination', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const Text(
                                'SmartBank AI Card',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Reference No.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                refCode,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.xl),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Done',
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              context.pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);
    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final profile = ref.watch(profileControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Account'),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          final savingsAccount = accounts.where((a) => !a.isExternal).firstOrNull ??
              (accounts.isNotEmpty ? accounts.first : null);

          if (savingsAccount == null) {
            return const Center(child: Text('SmartBank Savings Account not found'));
          }

          return SingleChildScrollView(
            padding: AppConstants.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Destination Header
                const Text(
                  'Credited Card / Account',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: AppConstants.xs),
                AppTextField(
                  label: 'Destination Card',
                  hint: 'SmartBank AI Card (${savingsAccount.cardNumber.length >= 4 ? "**** ${savingsAccount.cardNumber.substring(savingsAccount.cardNumber.length - 4)}" : savingsAccount.accountNumber})',
                  readOnly: true,
                  prefixIcon: Icons.credit_card_rounded,
                ),
                const SizedBox(height: AppConstants.md),

                // Funding Source Selector
                const Text(
                  'Funding Source',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: AppConstants.xs),
                DropdownButtonFormField<String>(
                  value: _selectedFundingSource,
                  decoration: InputDecoration(
                    labelText: 'Select Payment Method',
                    prefixIcon: const Icon(Icons.payment_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    ),
                  ),
                  items: _fundingSources.map((src) {
                    return DropdownMenuItem(
                      value: src,
                      child: Text(src, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFundingSource = val);
                  },
                ),
                const SizedBox(height: AppConstants.md),

                // Amount
                const Text(
                  'Deposit Amount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: AppConstants.xs),
                AppTextField(
                  controller: _controller,
                  label: 'Amount (₱)',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.account_balance_wallet_rounded,
                ),
                const SizedBox(height: AppConstants.xl),

                AppButton(
                  text: 'Authorize Top-Up Deposit',
                  isLoading: walletState.isLoading,
                  onPressed: () {
                    final amount = double.tryParse(_controller.text) ?? 0.0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid deposit amount'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (profile != null && profile.pinHash != null && profile.pinHash!.isNotEmpty) {
                      _showPinModal(context, amount, savingsAccount.id);
                    } else {
                      _executeTopUp(amount, savingsAccount.id);
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

class _PinBtn extends StatelessWidget {
  const _PinBtn(this.digit, this.onTap);
  final String digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
