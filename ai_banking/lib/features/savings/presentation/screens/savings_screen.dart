import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/savings_goal.dart';
import '../../providers/savings_provider.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Savings Goals'),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.plus),
                onPressed: () => context.push('/savings/create'),
              ),
            ],
          ),
          goalsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (goals) => SliverList(
              delegate: SliverChildListDelegate([
                _TotalSavingsCard(goals: goals),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'Your Goals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ...goals.map((g) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: _GoalCard(
                        goal: g,
                        onTap: () => context.push('/savings/${g.id}'),
                      ),
                    )),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalSavingsCard extends StatelessWidget {
  final List<SavingsGoal> goals;

  const _TotalSavingsCard({required this.goals});

  @override
  Widget build(BuildContext context) {
    final totalCurrent = goals.fold(0.0, (s, g) => s + g.currentAmount);
    final totalTarget = goals.fold(0.0, (s, g) => s + g.targetAmount);
    final completed = goals.where((g) => g.isCompleted).length;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Saved',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(totalCurrent),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(label: '${goals.length} Goals', icon: LucideIcons.flag),
                _InfoChip(label: '$completed Completed', icon: LucideIcons.circleCheck),
                _InfoChip(label: CurrencyFormatter.compact(totalTarget), icon: LucideIcons.target),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;

  const _GoalCard({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(goal.colorHex);
    final progress = goal.progressPercent;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_iconData(goal.iconName), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (goal.description != null)
                        Text(
                          goal.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(goal.currentAmount),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
                Text(
                  'of ${CurrencyFormatter.format(goal.targetAmount)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% reached',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (goal.daysRemaining != null)
                  Text(
                    '${goal.daysRemaining} days left',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: goal.daysRemaining! < 30 ? Colors.orange : colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
            if (goal.isAutoDeposit) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(LucideIcons.repeat, size: 12, color: colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    'Auto ${CurrencyFormatter.compact(goal.autoDepositAmount)}/${goal.autoDepositFrequency}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF0A84FF);
    }
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'shield': return LucideIcons.shield;
      case 'flight': return LucideIcons.plane;
      case 'laptop': return LucideIcons.laptop;
      case 'home': return LucideIcons.house;
      case 'car': return LucideIcons.car;
      default: return LucideIcons.piggyBank;
    }
  }
}
