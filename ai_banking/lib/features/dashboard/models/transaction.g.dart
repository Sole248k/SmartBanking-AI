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
      referenceNumber: json['referenceNumber'] as String?,
      senderName: json['senderName'] as String?,
      senderBank: json['senderBank'] as String?,
      senderAccount: json['senderAccount'] as String?,
      recipientName: json['recipientName'] as String?,
      targetAccount: json['targetAccount'] as String?,
      targetBank: json['targetBank'] as String?,
      note: json['note'] as String?,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble(),
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      authMethod: json['authMethod'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
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
      'referenceNumber': instance.referenceNumber,
      'senderName': instance.senderName,
      'senderBank': instance.senderBank,
      'senderAccount': instance.senderAccount,
      'recipientName': instance.recipientName,
      'targetAccount': instance.targetAccount,
      'targetBank': instance.targetBank,
      'note': instance.note,
      'balanceBefore': instance.balanceBefore,
      'balanceAfter': instance.balanceAfter,
      'authMethod': instance.authMethod,
      'fee': instance.fee,
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
