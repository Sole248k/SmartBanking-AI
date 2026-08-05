import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../dashboard/models/transaction.dart';

class DigitalReceiptModal extends StatelessWidget {
  const DigitalReceiptModal({super.key, required this.transaction});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final refCode = transaction.referenceNumber ??
        'REF-${transaction.id.substring(0, math.min(8, transaction.id.length)).toUpperCase()}';

    final isCredit = transaction.type == TransactionType.credit;
    final formattedDate =
        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} ${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(AppConstants.lg),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppConstants.lg),

          // Header Branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'SmartBank AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Official Transaction Receipt',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: AppConstants.lg),

          // Receipt Paper Container
          Container(
            padding: const EdgeInsets.all(AppConstants.lg),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                // Status Stamp
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.18),
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
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Amount
                Text(
                  '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                  style: TextStyle(
                    color: isCredit ? Colors.greenAccent : Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.title,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppConstants.md),

                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: AppConstants.md),

                // Details Grid
                _ReceiptRow(label: 'Reference No.', value: refCode),
                _ReceiptRow(label: 'Date & Time', value: formattedDate),
                _ReceiptRow(
                    label: 'Category', value: transaction.category),
                if (transaction.senderName != null)
                  _ReceiptRow(
                      label: 'Sender', value: transaction.senderName!),
                if (transaction.recipientName != null)
                  _ReceiptRow(
                      label: 'Recipient', value: transaction.recipientName!),
                if (transaction.targetBank != null)
                  _ReceiptRow(
                      label: 'Bank / Network', value: transaction.targetBank!),
                if (transaction.targetAccount != null)
                  _ReceiptRow(
                      label: 'Account / Card',
                      value: transaction.targetAccount!),
                _ReceiptRow(
                    label: 'Auth Method',
                    value: transaction.authMethod ?? 'Security PIN'),
                _ReceiptRow(label: 'Transfer Fee', value: '₱0.00'),

                const SizedBox(height: AppConstants.sm),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: AppConstants.sm),

                _ReceiptRow(
                  label: 'Total Amount',
                  value: CurrencyFormatter.format(transaction.amount),
                  valueStyle: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.xl),

          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Download PDF',
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt PDF saved to Downloads folder.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: AppConstants.md),
              Expanded(
                child: AppButton(
                  text: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.md),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(
      {required this.label, required this.value, this.valueStyle});
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
