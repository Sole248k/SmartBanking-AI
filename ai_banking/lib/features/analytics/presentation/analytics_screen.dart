import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/chart_utils.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/analytics_providers.dart';
import 'widgets/spending_pie_chart.dart';
import 'widgets/trend_line_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(spendingReportControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analytics'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(spendingReportControllerProvider.notifier).refresh(),
        child: reportAsync.when(
          data: (report) => SingleChildScrollView(
            padding: AppConstants.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.md),
                AppCard(
                  child: Row(
                    children: [
                      Expanded(child: SpendingPieChart(data: report.categoryBreakdown)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: report.categoryBreakdown.entries.toList().asMap().entries.take(5).map((entry) {
                            final index = entry.key;
                            final e = entry.value;
                            return _LegendItem(
                              label: e.key,
                              amount: e.value,
                              color: ChartUtils.getCategoryColor(index, theme),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.xl),
                Text(
                  'Spending Trend',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.md),
                AppCard(
                  child: TrendLineChart(points: report.dailyTrend),
                ),
                const SizedBox(height: AppConstants.xl),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Total Income',
                        amount: report.totalIncome,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: AppConstants.md),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Total Spent',
                        amount: report.totalSpent,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {

  const _LegendItem({required this.label, required this.amount, required this.color});
  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.xs),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: AppConstants.sm),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
          Text(CurrencyFormatter.noDecimal(amount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {

  const _SummaryCard({required this.label, required this.amount, required this.color});
  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: AppConstants.xs),
          Text(
            CurrencyFormatter.format(amount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
