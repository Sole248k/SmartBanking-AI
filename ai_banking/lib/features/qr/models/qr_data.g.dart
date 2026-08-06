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
      walletId: json['walletId'] as String?,
      userId: json['userId'] as String?,
      bankCode: json['bankCode'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      expiresAt: json['expiresAt'] as String?,
      version: json['version'] as String? ?? '1',
    );

Map<String, dynamic> _$$QrDataImplToJson(_$QrDataImpl instance) =>
    <String, dynamic>{
      'recipientId': instance.recipientId,
      'recipientName': instance.recipientName,
      'accountNumber': instance.accountNumber,
      'amount': instance.amount,
      'note': instance.note,
      'walletId': instance.walletId,
      'userId': instance.userId,
      'bankCode': instance.bankCode,
      'referenceNumber': instance.referenceNumber,
      'expiresAt': instance.expiresAt,
      'version': instance.version,
    };
