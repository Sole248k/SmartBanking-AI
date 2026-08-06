import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/qr_data.dart';
import '../repositories/qr_repository.dart';

class QrRepositoryImpl implements QrRepository {
  /// Maximum allowed payload size (bytes) to prevent DoS via huge QR strings.
  static const int _maxPayloadBytes = 4096;

  @override
  Future<Either<Failure, QrData>> parseQrCode(String code) async {
    try {
      // 1. Size guard
      if (code.length > _maxPayloadBytes) {
        return left(const ValidationFailure('QR code payload is too large'));
      }

      // 2. Must be valid JSON
      final Map<String, dynamic> raw;
      try {
        raw = jsonDecode(code) as Map<String, dynamic>;
      } catch (_) {
        return left(const ValidationFailure('Invalid QR code format'));
      }

      // 3. Sanitize: strip any keys not in the known schema to prevent injection
      const allowedKeys = {
        'recipientId', 'recipientName', 'accountNumber',
        'amount', 'note', 'walletId', 'userId', 'bankCode',
        'referenceNumber', 'expiresAt', 'version',
      };
      final sanitized = Map<String, dynamic>.fromEntries(
        raw.entries.where((e) => allowedKeys.contains(e.key)),
      );

      // 4. Required-field presence check before deserialization
      for (final field in ['recipientId', 'recipientName', 'accountNumber']) {
        final val = sanitized[field];
        if (val == null || (val is String && val.trim().isEmpty)) {
          return left(ValidationFailure('QR code is missing required field: $field'));
        }
      }

      // 5. Deserialize
      final qrData = QrData.fromJson(sanitized);

      // 6. Expiry check
      if (qrData.expiresAt != null) {
        final expiry = DateTime.tryParse(qrData.expiresAt!);
        if (expiry == null || DateTime.now().toUtc().isAfter(expiry)) {
          return left(const ValidationFailure('This QR code has expired'));
        }
      }

      // 7. Self-transfer guard
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null && qrData.userId == currentUid) {
        return left(const ValidationFailure('You cannot transfer money to yourself'));
      }

      // 8. Amount sanity check (if present)
      if (qrData.amount != null && qrData.amount! <= 0) {
        return left(const ValidationFailure('QR code contains an invalid amount'));
      }

      return right(qrData);
    } catch (e) {
      return left(ValidationFailure('QR processing error: $e'));
    }
  }

  @override
  String generateQrPayload(QrData data) => jsonEncode(data.toJson());
}
