import 'package:ai_banking/features/transfer/repositories/transfer_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/pin_utils.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/qr_transfer_args.dart';
import '../providers/qr_transfer_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QrTransferReviewScreen
//
// This screen is COMPLETELY SELF-CONTAINED:
//   • Shows auto-populated recipient card (name, masked account, bank, avatar)
//   • Provides source-account selector
//   • Provides amount entry (or shows pre-filled fixed amount)
//   • Provides optional remarks field
//   • Calls executeTransfer via QrTransferNotifier (reuses existing Firestore
//     atomic transaction — same API as manual Send Money)
//   • Shows inline success state
//   • NEVER navigates to the generic /transfer form
// ─────────────────────────────────────────────────────────────────────────────

class QrTransferReviewScreen extends ConsumerStatefulWidget {
  const QrTransferReviewScreen({super.key, required this.args});

  final QrTransferArgs args;

  @override
  ConsumerState<QrTransferReviewScreen> createState() =>
      _QrTransferReviewScreenState();
}

class _QrTransferReviewScreenState
    extends ConsumerState<QrTransferReviewScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedAccountId;

  QrTransferArgs get _args => widget.args;

  @override
  void initState() {
    super.initState();
    // Pre-fill amount if the QR encoded one
    final prefilledAmt = _args.qrData.amount;
    if (prefilledAmt != null && prefilledAmt > 0) {
      _amountController.text = prefilledAmt.toStringAsFixed(2);
    }
    // Pre-fill note / reference
    if (_args.qrData.note?.isNotEmpty == true) {
      _noteController.text = _args.qrData.note!;
    } else if (_args.qrData.referenceNumber?.isNotEmpty == true) {
      _noteController.text = 'Ref: ${_args.qrData.referenceNumber}';
    }

    // Reset QR transfer state on entry (clean slate)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qrTransferNotifierProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ── PIN confirmation bottom sheet ─────────────────────────────────────────

  void _showPinModal(VoidCallback onSuccess) {
    String enteredPin = '';
    String? pinError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) => StatefulBuilder(
        builder: (modalCtx, setModal) {
          final profile = ref.read(profileControllerProvider).value;

          void onKey(String digit) {
            if (enteredPin.length >= 6) return;
            setModal(() {
              pinError = null;
              enteredPin += digit;
            });
            if (enteredPin.length == 6) {
              if (profile != null &&
                  PinUtils.verifyPin(enteredPin, profile.pinHash)) {
                Navigator.pop(modalCtx);
                onSuccess();
              } else {
                setModal(() {
                  enteredPin = '';
                  pinError = 'Incorrect PIN. Please try again.';
                });
              }
            }
          }

          void onBack() {
            if (enteredPin.isNotEmpty) {
              setModal(() {
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
                const Icon(Icons.security_rounded,
                    color: AppTheme.primaryColor, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'Confirm Security PIN',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your 6-digit PIN to authorise this transfer',
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
                        color: i < enteredPin.length
                            ? AppTheme.primaryColor
                            : Colors.white24,
                      ),
                    ),
                  ),
                ),
                if (pinError != null) ...[
                  const SizedBox(height: 12),
                  Text(pinError!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 24),
                ...[
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                ].map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: row
                          .map((d) => _PinKey(digit: d, onTap: () => onKey(d)))
                          .toList(),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 60, height: 60),
                    _PinKey(digit: '0', onTap: () => onKey('0')),
                    InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(30),
                      child: const SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.backspace_outlined,
                            color: Colors.white),
                      ),
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

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? _args.qrData.amount ?? 0.0;

    // Update notifier fields before executing
    final notifier = ref.read(qrTransferNotifierProvider.notifier);
    notifier.setAmount(amount);
    notifier.setNote(_noteController.text.trim());
    if (_selectedAccountId != null) {
      notifier.setFromAccount(_selectedAccountId!);
    }

    // Build the RecipientDetails to pass to executeTransfer.
    // We use QrTransferArgs convenience getters so backend data takes
    // precedence over QR payload data.
    final recipient = _args.recipient;

    if (recipient == null) {
      // External / unverified account — build a minimal RecipientDetails from QR
      _executeWithDetails(
        accountId: _args.qrData.recipientId,
        userId: _args.qrData.userId ?? '',
        recipientName: _args.resolvedName,
        bankName: _args.resolvedBankName,
        accountNumber: _args.resolvedAccountNumber,
        maskedCardNumber: _args.maskedAccount,
        amount: amount,
      );
      return;
    }

    final profile = ref.read(profileControllerProvider).value;
    final hasPin = profile?.pinHash?.isNotEmpty == true;

    if (hasPin) {
      _showPinModal(() => _executeWithDetails(
            accountId: recipient.accountId,
            userId: recipient.userId,
            recipientName: recipient.recipientName,
            bankName: _args.resolvedBankName,
            accountNumber: recipient.accountNumber,
            maskedCardNumber: recipient.maskedCardNumber,
            amount: amount,
          ));
    } else {
      _executeWithDetails(
        accountId: recipient.accountId,
        userId: recipient.userId,
        recipientName: recipient.recipientName,
        bankName: _args.resolvedBankName,
        accountNumber: recipient.accountNumber,
        maskedCardNumber: recipient.maskedCardNumber,
        amount: amount,
      );
    }
  }

  void _executeWithDetails({
    required String accountId,
    required String userId,
    required String recipientName,
    required String bankName,
    required String accountNumber,
    required String maskedCardNumber,
    required double amount,
  }) {
    // Import RecipientDetails inline via the provider's executeTransfer API
    ref.read(qrTransferNotifierProvider.notifier).executeTransfer(
          recipient: _RecipientDetailsAdapter(
            accountId: accountId,
            userId: userId,
            recipientName: recipientName,
            bankName: bankName,
            accountNumber: accountNumber,
            maskedCardNumber: maskedCardNumber,
          ),
          bankName: bankName,
          prefilledAmount: amount,
        );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qrState = ref.watch(qrTransferNotifierProvider);
    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final accounts = accountsAsync.value ?? [];

    // Seed default source account once data arrives
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    // ── Success state ──────────────────────────────────────────────────────
    if (qrState.isSuccess) {
      return _QrTransferSuccessView(args: _args);
    }

    final amountPrefilled =
        (_args.qrData.amount ?? 0) > 0;
    final isExternal = _args.recipient == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Recipient card ───────────────────────────────────────────
              _RecipientCard(args: _args, isExternal: isExternal),
              const SizedBox(height: AppConstants.xl),

              // ── Source account ───────────────────────────────────────────
              Text('Transfer From',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppConstants.sm),
              accountsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, e) => const Text('Failed to load accounts.',
                    style: TextStyle(color: Colors.red)),
                data: (accs) {
                  if (accs.isEmpty) {
                    return const Text('No accounts available.',
                        style: TextStyle(color: Colors.grey));
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.account_balance_wallet_rounded),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLg),
                      ),
                    ),
                    items: accs.map((acc) {
                      return DropdownMenuItem(
                        value: acc.id,
                        child: Text(
                          '${acc.label}  ·  ₱${acc.balance.toStringAsFixed(2)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: qrState.isLoading
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() => _selectedAccountId = val);
                            }
                          },
                    validator: (_) => _selectedAccountId == null
                        ? 'Please select a source account'
                        : null,
                  );
                },
              ),
              const SizedBox(height: AppConstants.xl),

              // ── Amount ───────────────────────────────────────────────────
              Text('Amount',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppConstants.sm),
              if (amountPrefilled)
                // Fixed amount embedded in QR — read-only display
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount (fixed by QR)',
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        CurrencyFormatter.format(_args.qrData.amount!),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                TextFormField(
                  controller: _amountController,
                  enabled: !qrState.isLoading,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Enter amount (₱)',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLg),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final val = double.tryParse(v.trim());
                    if (val == null || val <= 0) {
                      return 'Enter a valid amount greater than zero';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: AppConstants.md),

              // ── Remarks ──────────────────────────────────────────────────
              TextFormField(
                controller: _noteController,
                enabled: !qrState.isLoading,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Remarks (Optional)',
                  hintText: 'e.g. Payment for lunch',
                  prefixIcon: const Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppConstants.xl),

              // ── Error banner ─────────────────────────────────────────────
              if (qrState.hasError && qrState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.3),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(
                        color: theme.colorScheme.error
                            .withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: AppConstants.sm),
                      Expanded(
                        child: Text(
                          qrState.errorMessage!,
                          style: TextStyle(
                              color: theme.colorScheme.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.md),
              ],

              // ── Send button ──────────────────────────────────────────────
              AppButton(
                text: 'Send Money',
                isLoading: qrState.isLoading,
                onPressed: qrState.isLoading ? null : _submit,
              ),
              const SizedBox(height: AppConstants.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recipient card widget
// ─────────────────────────────────────────────────────────────────────────────

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({required this.args, required this.isExternal});

  final QrTransferArgs args;
  final bool isExternal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header label
          Text(
            'Recipient',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppConstants.md),

          // Identity row
          Row(
            children: [
              AppAvatar(name: args.resolvedName, size: 52),
              const SizedBox(width: AppConstants.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      args.resolvedName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      args.maskedAccount,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      args.resolvedBankName,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Verified / external badge
              if (isExternal)
                const Chip(
                  label: Text('External',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.orange),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )
              else
                const Chip(
                  label: Text('Verified',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.green),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),

          // Extra QR metadata (reference, wallet ID, etc.)
          if (args.qrData.referenceNumber != null ||
              args.qrData.walletId != null) ...[
            const Divider(height: AppConstants.xl),
            if (args.qrData.referenceNumber != null)
              _MetaRow(
                  label: 'Reference', value: args.qrData.referenceNumber!),
            if (args.qrData.walletId != null)
              _MetaRow(label: 'Wallet ID', value: args.qrData.walletId!),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIN key widget
// ─────────────────────────────────────────────────────────────────────────────

class _PinKey extends StatelessWidget {
  const _PinKey({required this.digit, required this.onTap});
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
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        alignment: Alignment.center,
        child: Text(digit,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success view (inline — no separate route needed)
// ─────────────────────────────────────────────────────────────────────────────

class _QrTransferSuccessView extends ConsumerWidget {
  const _QrTransferSuccessView({required this.args});
  final QrTransferArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(AppConstants.xl),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 100),
            ),
            const SizedBox(height: AppConstants.xl),
            Text(
              'Transfer Successful!',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),
            Text(
              'Money sent to ${args.resolvedName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: AppConstants.sm),
            const Text(
              'It will reflect in the recipient\'s account shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Spacer(),
            AppButton(
              text: 'Back to Dashboard',
              onPressed: () {
                ref.read(qrTransferNotifierProvider.notifier).reset();
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Adapter: wraps QrTransferArgs data into the RecipientDetails interface
// without adding a dependency on the transfer repository from the UI layer.
// ─────────────────────────────────────────────────────────────────────────────

class _RecipientDetailsAdapter extends RecipientDetails {
  const _RecipientDetailsAdapter({
    required super.accountId,
    required super.userId,
    required super.recipientName,
    required super.bankName,
    required super.accountNumber,
    required super.maskedCardNumber,
  }) : super(cardNetwork: 'visa');
}
