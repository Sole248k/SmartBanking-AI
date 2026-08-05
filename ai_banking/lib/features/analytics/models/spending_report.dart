import 'package:freezed_annotation/freezed_annotation.dart';

part 'spending_report.freezed.dart';
part 'spending_report.g.dart';

@freezed
class SpendingReport with _$SpendingReport {
  const factory SpendingReport({
    @Default(0.0) double totalSpent,
    @Default(0.0) double totalIncome,
    @Default({}) Map<String, double> categoryBreakdown,
    @Default([]) List<DailyPoint> dailyTrend,
  }) = _SpendingReport;

  factory SpendingReport.fromJson(Map<String, dynamic> json) => _$SpendingReportFromJson(json);
}

@freezed
class DailyPoint with _$DailyPoint {
  const factory DailyPoint({
    required DateTime date,
    @Default(0.0) double value,
  }) = _DailyPoint;

  factory DailyPoint.fromJson(Map<String, dynamic> json) => _$DailyPointFromJson(json);
}
