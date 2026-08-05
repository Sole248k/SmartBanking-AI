import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../core/utils/chart_utils.dart';

class SpendingPieChart extends StatelessWidget {

  const SpendingPieChart({super.key, required this.data});
  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = data.values.fold(0.0, (sum, val) => sum + val);

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            final percentage = (entry.value / total) * 100;
            return PieChartSectionData(
              color: ChartUtils.getCategoryColor(index, theme),
              value: entry.value,
              title: '${percentage.toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
