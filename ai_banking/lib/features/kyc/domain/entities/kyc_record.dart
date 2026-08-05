import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc_record.freezed.dart';
part 'kyc_record.g.dart';

enum KycStep {
  welcome,
  personalInfo,
  idSelection,
  idCaptureFront,
  idCaptureBack,
  selfieCapture,
  review,
  submitted
}

enum IdType {
  passport,
  driversLicense,
  nationalId,
  umid,
  philsys,
  postalId,
  prcId,
  votersId
}

@freezed
class KycRecord with _$KycRecord {
  const factory KycRecord({
    String? fullName,
    DateTime? dateOfBirth,
    String? nationality,
    String? address,
    String? occupation,
    IdType? idType,
    String? idFrontUrl,
    String? idBackUrl,
    String? selfieUrl,
    double? faceMatchScore,
    @Default('pending') String status,
  }) = _KycRecord;

  factory KycRecord.fromJson(Map<String, dynamic> json) => _$KycRecordFromJson(json);
}
