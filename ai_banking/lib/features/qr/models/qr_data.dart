import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr_data.freezed.dart';
part 'qr_data.g.dart';

/// Flexible QR transfer payload — v1 fields are required; all others are optional
/// to support future extensions without breaking existing QR codes.
@freezed
class QrData with _$QrData {
  const factory QrData({
    // ── v1 core fields ──────────────────────────────────────────────────────
    required String recipientId,
    required String recipientName,
    required String accountNumber,
    // ── optional transfer hints ──────────────────────────────────────────────
    double? amount,
    String? note,
    // ── extended recipient identifiers ───────────────────────────────────────
    String? walletId,
    String? userId,
    String? bankCode,
    String? referenceNumber,
    // ── security & lifecycle ─────────────────────────────────────────────────
    /// ISO-8601 UTC string; null means no expiry.
    String? expiresAt,
    /// Payload schema version for forward-compatibility.
    @Default('1') String version,
  }) = _QrData;

  factory QrData.fromJson(Map<String, dynamic> json) => _$QrDataFromJson(json);
}
