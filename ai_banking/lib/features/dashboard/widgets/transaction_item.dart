import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_list_tile.dart';
import '../../../shared/widgets/privacy_sensitive_text.dart';
import '../models/transaction.dart';

import 'package:go_router/go_router.dart';

class TransactionItem extends StatelessWidget {

  const TransactionItem({super.key, required this.transaction});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.type == TransactionType.debit;
    final theme = Theme.of(context);

    return AppListTile(
      onTap: () => context.push('/transactions/details', extra: transaction),
      title: Text(
        transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${DateFormat('MMM d, h:mm a').format(transaction.date)} • ${transaction.category}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Icon(
        _getCategoryIcon(transaction.category),
        color: theme.colorScheme.primary,
      ),
      trailing: PrivacySensitiveText(
        '${isDebit ? '-' : '+'} ${CurrencyFormatter.format(transaction.amount)}',
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
