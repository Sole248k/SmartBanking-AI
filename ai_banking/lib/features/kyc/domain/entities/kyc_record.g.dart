// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KycRecordImpl _$$KycRecordImplFromJson(Map<String, dynamic> json) =>
    _$KycRecordImpl(
      fullName: json['fullName'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      nationality: json['nationality'] as String?,
      address: json['address'] as String?,
      occupation: json['occupation'] as String?,
      idType: $enumDecodeNullable(_$IdTypeEnumMap, json['idType']),
      idFrontUrl: json['idFrontUrl'] as String?,
      idBackUrl: json['idBackUrl'] as String?,
      selfieUrl: json['selfieUrl'] as String?,
      faceMatchScore: (json['faceMatchScore'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$KycRecordImplToJson(_$KycRecordImpl instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'nationality': instance.nationality,
      'address': instance.address,
      'occupation': instance.occupation,
      'idType': _$IdTypeEnumMap[instance.idType],
      'idFrontUrl': instance.idFrontUrl,
      'idBackUrl': instance.idBackUrl,
      'selfieUrl': instance.selfieUrl,
      'faceMatchScore': instance.faceMatchScore,
      'status': instance.status,
    };

const _$IdTypeEnumMap = {
  IdType.passport: 'passport',
  IdType.driversLicense: 'driversLicense',
  IdType.nationalId: 'nationalId',
  IdType.umid: 'umid',
  IdType.philsys: 'philsys',
  IdType.postalId: 'postalId',
  IdType.prcId: 'prcId',
  IdType.votersId: 'votersId',
};
