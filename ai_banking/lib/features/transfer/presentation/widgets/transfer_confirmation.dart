import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/providers/dashboard_providers.dart';
import '../../providers/transfer_providers.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/profile_providers.dart';
import '../../../../core/utils/pin_utils.dart';
import '../../../../app/theme/app_theme.dart';

class TransferConfirmation extends ConsumerWidget {
  const TransferConfirmation({super.key});

  void _showPinModal(BuildContext context, WidgetRef ref) {
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

          void onKeyPress(String digit) {
            if (enteredPin.length < 6) {
              setModalState(() {
                pinError = null;
                enteredPin += digit;
              });

              if (enteredPin.length == 6) {
                if (profile != null && PinUtils.verifyPin(enteredPin, profile.pinHash)) {
                  Navigator.pop(modalContext);
                  ref.read(transferControllerProvider.notifier).confirmTransfer();
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
                  'Confirm Security PIN',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your 6-digit PIN to authorize fund transfer',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferControllerProvider);
    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final profile = ref.watch(profileControllerProvider).value;
    final theme = Theme.of(context);

    final fromAccountLabel = accountsAsync.when(
      data: (accounts) {
        final match = accounts.firstWhere(
          (a) => a.id == transferState.fromAccountId,
          orElse: () => accounts.first,
        );
        return '${match.label} (${match.accountNumber})';
      },
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
                _Row(label: 'From Account', value: fromAccountLabel),
                const Divider(height: AppConstants.xl),
                _Row(label: 'To Recipient', value: transferState.recipientName),
                _Row(label: 'Bank / Network', value: transferState.bankName),
                _Row(label: 'Account / Card', value: transferState.recipientAccountNumber),
                if (transferState.note != null && transferState.note!.isNotEmpty)
                  _Row(label: 'Note', value: transferState.note!),
                const Divider(height: AppConstants.xl),
                _Row(
                  label: 'Total Amount',
                  value: CurrencyFormatter.format(transferState.amount),
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
            text: 'Confirm & Authorize Transfer',
            isLoading: transferState.isLoading,
            onPressed: () {
              if (profile != null && profile.pinHash != null && profile.pinHash!.isNotEmpty) {
                _showPinModal(context, ref);
              } else {
                ref.read(transferControllerProvider.notifier).confirmTransfer();
              }
            },
          ),
        ],
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
