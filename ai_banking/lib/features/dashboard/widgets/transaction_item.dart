import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/app_list_tile.dart';
import '../../../shared/widgets/privacy_sensitive_text.dart';
import '../models/transaction.dart';

class TransactionItem extends StatelessWidget {

  const TransactionItem({super.key, required this.transaction});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.type == TransactionType.debit;
    final theme = Theme.of(context);

    return AppListTile(
      title: Text(transaction.title),
      subtitle: Text(
        '${DateFormat('MMM d, h:mm a').format(transaction.date)} • ${transaction.category}',
      ),
      leading: Icon(
        _getCategoryIcon(transaction.category),
        color: theme.colorScheme.primary,
      ),
      trailing: PrivacySensitiveText(
        '${isDebit ? '-' : '+'} ₱${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDebit ? null : Colors.green,
          fontSize: 16,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return Icons.movie_outlined;
      case 'services':
        return Icons.build_outlined;
      case 'salary':
        return Icons.work_outline;
      case 'food & drink':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car_outlined;
      default:
        return Icons.payment;
    }
  }
}
