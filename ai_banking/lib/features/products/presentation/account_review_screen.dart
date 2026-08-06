import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../dashboard/providers/active_account_provider.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../admin/domain/product_application.dart';
import '../providers/product_application_user_providers.dart';

class AccountReviewScreen extends ConsumerStatefulWidget {
  const AccountReviewScreen({super.key, required this.applicationData});

  final Map<String, dynamic> applicationData;

  @override
  ConsumerState<AccountReviewScreen> createState() => _AccountReviewScreenState();
}

class _AccountReviewScreenState extends ConsumerState<AccountReviewScreen> {
  bool _isLoading = false;

  String _generateAccountNumber() {
    final random = math.Random();
    final part1 = (random.nextInt(8999) + 1000).toString();
    final part2 = (random.nextInt(8999) + 1000).toString();
    return '1009 $part1 $part2';
  }

  String _generateCardNumber() {
    final random = math.Random();
    final p1 = (random.nextInt(8999) + 1000).toString();
    final p2 = (random.nextInt(8999) + 1000).toString();
    final p3 = (random.nextInt(8999) + 1000).toString();
    return '4532 $p1 $p2 $p3';
  }

  Future<void> _confirmAccountCreation() async {
    setState(() => _isLoading = true);

    final fullName = widget.applicationData['fullName'] as String;
    final accountType = widget.applicationData['accountType'] as AccountType;
    final initialDeposit = widget.applicationData['initialDeposit'] as double;

    final productType = accountType == AccountType.savings
        ? ProductType.savings
        : ProductType.current;

    final result = await ref
        .read(userProductApplicationServiceProvider)
        .submitApplication(
          productType: productType,
          applicationData: {
            'fullName': fullName,
            'initialDeposit': initialDeposit,
            'accountType': accountType.name,
            'submittedAt': DateTime.now().toIso8601String(),
          },
        );

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit application: ${failure.message}')),
        );
      },
      (appId) {
        ref.invalidate(myProductApplicationsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted! Awaiting admin review and verification.'),
            backgroundColor: Colors.blue,
          ),
        );
        context.go('/products/status');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = widget.applicationData['fullName'] as String;
    final address = widget.applicationData['address'] as String;
    final occupation = widget.applicationData['occupation'] as String;
    final accountType = widget.applicationData['accountType'] as AccountType;
    final initialDeposit = widget.applicationData['initialDeposit'] as double;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Application'),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Summary',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Please review your details carefully before confirming account opening.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: AppConstants.xl),

            AppCard(
              child: Column(
                children: [
                  _ReviewRow(label: 'Full Name', value: fullName),
                  const Divider(),
                  _ReviewRow(label: 'Residential Address', value: address),
                  const Divider(),
                  _ReviewRow(label: 'Occupation', value: occupation),
                  const Divider(),
                  _ReviewRow(
                    label: 'Account Type',
                    value: accountType == AccountType.savings ? 'Savings Account' : 'Current Account',
                  ),
                  const Divider(),
                  _ReviewRow(
                    label: 'Initial Deposit',
                    value: CurrencyFormatter.format(initialDeposit),
                    isHighlighted: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.xxl),
            AppButton(
              text: 'Confirm Account Creation',
              icon: Icons.check_circle_outline_rounded,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _confirmAccountCreation,
            ),
            const SizedBox(height: AppConstants.md),
            AppButton(
              text: 'Back / Edit Details',
              variant: AppButtonVariant.outline,
              onPressed: _isLoading ? null : () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(width: AppConstants.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                color: isHighlighted ? theme.colorScheme.primary : null,
                fontSize: isHighlighted ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
