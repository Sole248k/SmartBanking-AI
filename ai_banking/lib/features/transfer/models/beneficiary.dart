import 'package:freezed_annotation/freezed_annotation.dart';

part 'beneficiary.freezed.dart';
part 'beneficiary.g.dart';

@freezed
class Beneficiary with _$Beneficiary {
  const factory Beneficiary({
    required String id,
    required String userId,
    required String name,
    required String accountNumber,
    required String bankName,
    String? avatarUrl,
  }) = _Beneficiary;

  factory Beneficiary.fromJson(Map<String, dynamic> json) => _$BeneficiaryFromJson(json);
}
