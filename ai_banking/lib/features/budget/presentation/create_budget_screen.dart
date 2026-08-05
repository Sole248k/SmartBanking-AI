import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/budget_providers.dart';

class CreateBudgetScreen extends ConsumerStatefulWidget {
  const CreateBudgetScreen({super.key});

  @override
  ConsumerState<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends ConsumerState<CreateBudgetScreen> {
  final _limitController = TextEditingController();
  String _selectedCategory = 'Food & Drink';

  final List<String> _categories = [
    'Food & Drink',
    'Entertainment',
    'Transport',
    'Shopping',
    'Services',
    'Health',
    'Travel',
  ];

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Budget'),
      ),
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category',
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: AppConstants.lg),
            AppTextField(
              controller: _limitController,
              label: 'Monthly Limit',
              hint: '0.00',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money_rounded,
            ),
            const Spacer(),
            AppButton(
              text: 'Create Budget',
              isLoading: budgetState.isLoading,
              onPressed: () async {
                final limit = double.tryParse(_limitController.text) ?? 0.0;
                if (limit > 0) {
                  await ref.read(budgetControllerProvider.notifier).createBudget(_selectedCategory, limit);
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
