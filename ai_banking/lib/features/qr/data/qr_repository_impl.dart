import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/qr_data.dart';
import '../repositories/qr_repository.dart';

class QrRepositoryImpl implements QrRepository {
  @override
  Future<Either<Failure, QrData>> parseQrCode(String code) async {
    try {
      final Map<String, dynamic> data = jsonDecode(code);
      return right(QrData.fromJson(data));
    } catch (e) {
      return left(const ValidationFailure('Invalid QR code format'));
    }
  }

  @override
  String generateQrPayload(QrData data) {
    return jsonEncode(data.toJson());
  }
}
