import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../transfer/providers/transfer_providers.dart';
import '../models/qr_data.dart';

/// Displays decoded QR recipient details, lets the user choose a source account
/// and enter an amount (if not pre-filled by the QR), then hands off to the
/// existing [TransferScreen] confirm step.
///
/// Changes vs previous version:
///   • Calls [TransferController.reset] before [setRecipientDetails] so no
///     stale state from a previous send-money session bleeds through.
///   • Exposes a source-account dropdown (task 5).
///   • Checks network connectivity before proceeding (task 6).
class QrTransferReviewScreen extends ConsumerStatefulWidget {
  const QrTransferReviewScreen({super.key, required this.qrData});

  final QrData qrData;

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
  bool _isProceedLoading = false;

  @override
  void initState() {
    super.initState();
    final qr = widget.qrData;
    if (qr.amount != null && qr.amount! > 0) {
      _amountController.text = qr.amount!.toStringAsFixed(2);
    }
    if (qr.note != null) _noteController.text = qr.note!;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ── Connectivity check ────────────────────────────────────────────────────

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  // ── Proceed to TransferScreen ─────────────────────────────────────────────

  Future<void> _proceed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProceedLoading = true);

    // Offline guard
    if (!await _isOnline()) {
      if (!mounted) return;
      setState(() => _isProceedLoading = false);
      _showError(
        title: 'No Internet Connection',
        message:
            'Please check your network connection and try again.',
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isProceedLoading = false);

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final qr = widget.qrData;

    // Resolve bank name: prefer bankCode, fall back to 'SmartBank AI'
    final bankName =
        (qr.bankCode != null && qr.bankCode!.isNotEmpty)
            ? qr.bankCode!
            : 'SmartBank AI';

    final note = _noteController.text.trim().isEmpty
        ? (qr.referenceNumber != null ? 'Ref: ${qr.referenceNumber}' : null)
        : _noteController.text.trim();

    final controller = ref.read(transferControllerProvider.notifier);

    // ── Task 3: Reset any stale transfer state before populating ─────────────
    controller.reset();

    // ── Task 5: Pass chosen source account ────────────────────────────────────
    controller.setRecipientDetails(
      fromAccountId: _selectedAccountId,
      recipientName: qr.recipientName.trim(),
      recipientAccountNumber: qr.accountNumber.trim(),
      bankName: bankName,
      amount: amount,
      note: note,
    );

    // Navigate to the existing confirm step — no transfer logic here
    context.pushReplacement('/transfer');
  }

  // ── Error dialog ──────────────────────────────────────────────────────────

  void _showError({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final qr = widget.qrData;
    final theme = Theme.of(context);
    final amountPrefilled = qr.amount != null && qr.amount! > 0;
    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final accounts = accountsAsync.value ?? [];

    // Seed the default selected account once accounts are loaded
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Review QR Transfer')),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Recipient card ─────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.qr_code_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppConstants.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                qr.recipientName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _maskAccount(qr.accountNumber),
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Chip(
                          label: Text(
                            'QR Verified',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                      ],
                    ),
                    if (qr.bankCode != null || qr.referenceNumber != null) ...[
                      const Divider(height: AppConstants.xl),
                      if (qr.bankCode != null)
                        _InfoRow(label: 'Bank / Network', value: qr.bankCode!),
                      if (qr.referenceNumber != null)
                        _InfoRow(label: 'Reference', value: qr.referenceNumber!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.xl),

              // ── Task 5: Source account selector ───────────────────
              Text(
                'Transfer From',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.sm),
              accountsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text(
                  'Failed to load accounts.',
                  style: TextStyle(color: Colors.red),
                ),
                data: (accs) {
                  if (accs.isEmpty) {
                    return const Text(
                      'No accounts available.',
                      style: TextStyle(color: Colors.grey),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                          Icons.account_balance_wallet_rounded),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLg),
                      ),
                    ),
                    items: accs.map((acc) {
                      final bal =
                          '₱${acc.balance.toStringAsFixed(2)}';
                      return DropdownMenuItem(
                        value: acc.id,
                        child: Text(
                          '${acc.label} ($bal)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
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

              // ── Amount ────────────────────────────────────────────
              Text(
                'Transfer Amount',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.sm),

              if (amountPrefilled)
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount (fixed by QR)',
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        CurrencyFormatter.format(qr.amount!),
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (₱)',
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
                    if (val == null || val <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
              const SizedBox(height: AppConstants.md),

              // ── Note ──────────────────────────────────────────────
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note / Purpose (Optional)',
                  prefixIcon: const Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.xxl),

              AppButton(
                text: 'Continue to Confirm',
                isLoading: _isProceedLoading,
                onPressed: _isProceedLoading ? null : _proceed,
              ),
              const SizedBox(height: AppConstants.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows last 4 digits only to mask sensitive account info.
  String _maskAccount(String account) {
    final clean = account.replaceAll(RegExp(r'\s'), '');
    if (clean.length <= 4) return clean;
    return '**** ${clean.substring(clean.length - 4)}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
