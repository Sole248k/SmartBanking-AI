import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr_data.freezed.dart';
part 'qr_data.g.dart';

@freezed
class QrData with _$QrData {
  const factory QrData({
    required String recipientId,
    required String recipientName,
    required String accountNumber,
    double? amount,
    String? note,
  }) = _QrData;

  factory QrData.fromJson(Map<String, dynamic> json) => _$QrDataFromJson(json);
}
