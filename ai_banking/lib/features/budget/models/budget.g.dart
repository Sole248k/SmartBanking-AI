// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetImpl _$$BudgetImplFromJson(Map<String, dynamic> json) => _$BudgetImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: json['category'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      period: json['period'] as String? ?? 'Monthly',
    );

Map<String, dynamic> _$$BudgetImplToJson(_$BudgetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'category': instance.category,
      'limitAmount': instance.limitAmount,
      'spentAmount': instance.spentAmount,
      'period': instance.period,
    };
