// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] as bool? ?? false,
      kycStatus: json['kycStatus'] as String? ?? 'Not Started',
      pinHash: json['pinHash'] as String?,
      pinCreatedAt: json['pinCreatedAt'] as String?,
      pinAttempts: (json['pinAttempts'] as num?)?.toInt() ?? 0,
      pinLockedUntil: json['pinLockedUntil'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'avatarUrl': instance.avatarUrl,
      'isBiometricEnabled': instance.isBiometricEnabled,
      'pushNotificationsEnabled': instance.pushNotificationsEnabled,
      'kycStatus': instance.kycStatus,
      'pinHash': instance.pinHash,
      'pinCreatedAt': instance.pinCreatedAt,
      'pinAttempts': instance.pinAttempts,
      'pinLockedUntil': instance.pinLockedUntil,
    };
