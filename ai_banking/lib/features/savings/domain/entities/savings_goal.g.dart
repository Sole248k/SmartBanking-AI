// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavingsDepositEntryImpl _$$SavingsDepositEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$SavingsDepositEntryImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isAutoDeposit: json['isAutoDeposit'] as bool? ?? false,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$SavingsDepositEntryImplToJson(
        _$SavingsDepositEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
      'isAutoDeposit': instance.isAutoDeposit,
      'notes': instance.notes,
    };

_$SavingsGoalImpl _$$SavingsGoalImplFromJson(Map<String, dynamic> json) =>
    _$SavingsGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      iconName: json['iconName'] as String? ?? 'savings',
      colorHex: json['colorHex'] as String? ?? '#4F6EF7',
      isAutoDeposit: json['isAutoDeposit'] as bool? ?? false,
      autoDepositAmount: (json['autoDepositAmount'] as num?)?.toDouble() ?? 0.0,
      autoDepositFrequency: json['autoDepositFrequency'] as String?,
      status: $enumDecodeNullable(_$SavingsGoalStatusEnumMap, json['status']) ??
          SavingsGoalStatus.active,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deposits: (json['deposits'] as List<dynamic>?)
              ?.map((e) =>
                  SavingsDepositEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SavingsGoalImplToJson(_$SavingsGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'deadline': instance.deadline?.toIso8601String(),
      'iconName': instance.iconName,
      'colorHex': instance.colorHex,
      'isAutoDeposit': instance.isAutoDeposit,
      'autoDepositAmount': instance.autoDepositAmount,
      'autoDepositFrequency': instance.autoDepositFrequency,
      'status': _$SavingsGoalStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'deposits': instance.deposits,
    };

const _$SavingsGoalStatusEnumMap = {
  SavingsGoalStatus.active: 'active',
  SavingsGoalStatus.completed: 'completed',
  SavingsGoalStatus.paused: 'paused',
  SavingsGoalStatus.cancelled: 'cancelled',
};
