import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/budget_providers.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgeting'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(budgetControllerProvider);
          return Future.delayed(const Duration(seconds: 1));
        },
        child: budgetsAsync.when(
          data: (budgets) => ListView.builder(
            padding: AppConstants.screenPadding,
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final progress = (budget.spentAmount / budget.limitAmount).clamp(0.0, 1.0);
              final isOver = budget.spentAmount > budget.limitAmount;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.md),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            budget.category,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₱${budget.spentAmount.toStringAsFixed(0)} / ₱${budget.limitAmount.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isOver ? theme.colorScheme.error : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMax),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            isOver ? theme.colorScheme.error : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.xs),
                      Text(
                        isOver 
                          ? 'You have exceeded your budget by ₱${(budget.spentAmount - budget.limitAmount).toStringAsFixed(0)}'
                          : '₱${(budget.limitAmount - budget.spentAmount).toStringAsFixed(0)} remaining',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isOver ? theme.colorScheme.error : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/budgets/create'),
        label: const Text('Add Budget'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
