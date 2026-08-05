// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beneficiary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BeneficiaryImpl _$$BeneficiaryImplFromJson(Map<String, dynamic> json) =>
    _$BeneficiaryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      accountNumber: json['accountNumber'] as String,
      bankName: json['bankName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$BeneficiaryImplToJson(_$BeneficiaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'accountNumber': instance.accountNumber,
      'bankName': instance.bankName,
      'avatarUrl': instance.avatarUrl,
    };
