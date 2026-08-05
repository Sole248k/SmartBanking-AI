import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../dashboard/models/transaction.dart';
import 'widgets/digital_receipt_modal.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key, required this.transaction});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = transaction.type == TransactionType.credit;

    final refCode = transaction.referenceNumber ??
        'REF-${transaction.id.substring(0, math.min(8, transaction.id.length)).toUpperCase()}';

    final formattedDate =
        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} at ${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'View Receipt',
            onPressed: () => _showReceiptModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Amount Header Card ─────────────────────────────────────
            AppCard(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isCredit ? Colors.green : Colors.blue)
                            .withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCredit
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: isCredit ? Colors.green : Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: AppConstants.md),
                    Text(
                      '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? Colors.green : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppConstants.sm),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.green.shade400, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            transaction.status.name.toUpperCase(),
                            style: TextStyle(
                              color: Colors.green.shade400,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.xl),

            // ── Basic & Counterparty Details Card ──────────────────────
            Text(
              'Transaction Metadata',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),

            AppCard(
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Reference Number',
                    valueWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(refCode,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: refCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Reference number copied!')),
                            );
                          },
                          child: const Icon(Icons.copy_rounded,
                              size: 14, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: AppConstants.md),
                  _DetailRow(label: 'Date & Time', value: formattedDate),
                  _DetailRow(label: 'Category', value: transaction.category),
                  if (transaction.senderName != null)
                    _DetailRow(label: 'Sender', value: transaction.senderName!),
                  if (transaction.recipientName != null)
                    _DetailRow(
                        label: 'Recipient', value: transaction.recipientName!),
                  if (transaction.targetBank != null)
                    _DetailRow(
                        label: 'Bank / Network',
                        value: transaction.targetBank!),
                  if (transaction.targetAccount != null)
                    _DetailRow(
                        label: 'Account / Card',
                        value: transaction.targetAccount!),
                  _DetailRow(
                      label: 'Auth Method',
                      value: transaction.authMethod ?? 'Security PIN'),
                  _DetailRow(
                      label: 'Processing Method', value: 'Instant P2P System'),
                  _DetailRow(label: 'Transfer Fee', value: '₱0.00'),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    _DetailRow(label: 'Note / Purpose', value: transaction.note!),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.xl),

            // ── Transaction Timeline Visualizer ────────────────────────
            Text(
              'Transaction Timeline',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),

            AppCard(
              child: Column(
                children: [
                  _TimelineNode(
                    title: 'Transaction Initiated',
                    subtitle: formattedDate,
                    isCompleted: true,
                    isFirst: true,
                  ),
                  _TimelineNode(
                    title: 'Security PIN Verified',
                    subtitle: 'Authenticated via 6-digit PIN',
                    isCompleted: true,
                  ),
                  _TimelineNode(
                    title: 'Atomic Database Settlement',
                    subtitle: 'Firestore Ledger Synchronized',
                    isCompleted: true,
                  ),
                  _TimelineNode(
                    title: 'Transaction Completed',
                    subtitle: 'Funds Available Immediately',
                    isCompleted: true,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.xl),

            // Actions
            AppButton(
              text: 'View & Download Digital Receipt',
              onPressed: () => _showReceiptModal(context),
            ),
            const SizedBox(height: AppConstants.xl),
          ],
        ),
      ),
    );
  }

  void _showReceiptModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DigitalReceiptModal(transaction: transaction),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.label, this.value, this.valueWidget});
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          valueWidget ??
              Text(
                value ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isFirst = false,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted ? Colors.green.withOpacity(0.5) : Colors.grey,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
