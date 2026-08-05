// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QrDataImpl _$$QrDataImplFromJson(Map<String, dynamic> json) => _$QrDataImpl(
      recipientId: json['recipientId'] as String,
      recipientName: json['recipientName'] as String,
      accountNumber: json['accountNumber'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$QrDataImplToJson(_$QrDataImpl instance) =>
    <String, dynamic>{
      'recipientId': instance.recipientId,
      'recipientName': instance.recipientName,
      'accountNumber': instance.accountNumber,
      'amount': instance.amount,
      'note': instance.note,
    };
