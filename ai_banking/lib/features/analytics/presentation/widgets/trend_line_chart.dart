import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/spending_report.dart';

class TrendLineChart extends StatelessWidget {

  const TrendLineChart({super.key, required this.points});
  final List<DailyPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: points.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.value);
              }).toList(),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 2,
                  color: theme.colorScheme.primary,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
