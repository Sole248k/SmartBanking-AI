import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String fullName,
    required String email,
    String? phoneNumber,
    String? avatarUrl,
    @Default(false) bool isBiometricEnabled,
    @Default(false) bool pushNotificationsEnabled,
    @Default('Not Started') String kycStatus,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
