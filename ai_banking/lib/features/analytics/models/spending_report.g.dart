// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpendingReportImpl _$$SpendingReportImplFromJson(Map<String, dynamic> json) =>
    _$SpendingReportImpl(
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      categoryBreakdown:
          (json['categoryBreakdown'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toDouble()),
              ) ??
              const {},
      dailyTrend: (json['dailyTrend'] as List<dynamic>?)
              ?.map((e) => DailyPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SpendingReportImplToJson(
        _$SpendingReportImpl instance) =>
    <String, dynamic>{
      'totalSpent': instance.totalSpent,
      'totalIncome': instance.totalIncome,
      'categoryBreakdown': instance.categoryBreakdown,
      'dailyTrend': instance.dailyTrend,
    };

_$DailyPointImpl _$$DailyPointImplFromJson(Map<String, dynamic> json) =>
    _$DailyPointImpl(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$DailyPointImplToJson(_$DailyPointImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
    };
