import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/qr_data.dart';

abstract class QrRepository {
  Future<Either<Failure, QrData>> parseQrCode(String code);
  String generateQrPayload(QrData data);
}
