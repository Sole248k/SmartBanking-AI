import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../admin/domain/product_application.dart';
import '../providers/product_application_user_providers.dart';

class ApplicationStatusScreen extends ConsumerWidget {
  const ApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appsAsync = ref.watch(myProductApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Padding(
                padding: AppConstants.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: AppConstants.md),
                    Text(
                      'No Active Applications',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.xs),
                    Text(
                      'Apply for a new savings account, loan, or credit card from the Products menu.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: AppConstants.xl),
                    AppButton(
                      text: 'Browse Products',
                      onPressed: () => context.go('/products'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: AppConstants.screenPadding,
            itemCount: apps.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppConstants.md),
            itemBuilder: (context, i) => _UserApplicationCard(app: apps[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error loading applications: $e'),
        ),
      ),
    );
  }
}

class _UserApplicationCard extends StatelessWidget {
  const _UserApplicationCard({required this.app});

  final ProductApplication app;

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.underReview:
        return Colors.blue;
      case ApplicationStatus.moreInfoRequired:
        return Colors.orange;
      default:
        return Colors.amber;
    }
  }

  IconData _productIcon(ProductType type) {
    switch (type) {
      case ProductType.savings:
        return Icons.savings_rounded;
      case ProductType.current:
        return Icons.account_balance_rounded;
      case ProductType.loan:
        return Icons.money_rounded;
      case ProductType.creditCard:
        return Icons.credit_card_rounded;
      default:
        return Icons.work_outline_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(app.status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.sm),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(_productIcon(app.productType), color: statusColor, size: 24),
              ),
              const SizedBox(width: AppConstants.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.productType.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Submitted on ${_formatDate(app.submittedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMax),
                ),
                child: Text(
                  app.status.displayName,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.md),
          const Divider(height: 1),
          const SizedBox(height: AppConstants.md),
          
          // Status Explanations & Timeline
          if (app.status == ApplicationStatus.pending)
            Text(
              'Your application has been received and is currently in queue for administrative review.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
          else if (app.status == ApplicationStatus.underReview)
            Text(
              'An admin officer is currently reviewing your submitted verification documents.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
          else if (app.status == ApplicationStatus.approved) ...[
            Text(
              'Congratulations! Your application has been approved by the bank admin.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.sm),
            AppButton(
              text: 'View Account in Dashboard',
              onPressed: () => context.go('/'),
            ),
          ] else if (app.status == ApplicationStatus.rejected) ...[
            Text(
              'Application Declined',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (app.rejectionReason != null)
              Text(
                'Reason: ${app.rejectionReason}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
          ] else if (app.status == ApplicationStatus.moreInfoRequired) ...[
            Text(
              'Additional Documents Required',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (app.requestedDocuments != null && app.requestedDocuments!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.xs),
              Text(
                'Requested: ${app.requestedDocuments!.join(', ')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
