// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      accountId: json['accountId'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      merchantLogoUrl: json['merchantLogoUrl'] as String?,
      location: json['location'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'accountId': instance.accountId,
      'title': instance.title,
      'description': instance.description,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'category': instance.category,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'merchantLogoUrl': instance.merchantLogoUrl,
      'location': instance.location,
      'iconUrl': instance.iconUrl,
    };

const _$TransactionStatusEnumMap = {
  TransactionStatus.completed: 'completed',
  TransactionStatus.pending: 'pending',
  TransactionStatus.failed: 'failed',
};

const _$TransactionTypeEnumMap = {
  TransactionType.debit: 'debit',
  TransactionType.credit: 'credit',
};
