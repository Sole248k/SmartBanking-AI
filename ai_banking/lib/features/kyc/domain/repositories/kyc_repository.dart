import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/kyc_record.dart';

abstract class KycRepository {
  Future<Either<Failure, String>> uploadKycImage({
    required String filePath,
    required String folderName,
  });

  Future<Either<Failure, void>> submitKyc({
    required String userId,
    required KycRecord record,
  });

  Future<Either<Failure, KycRecord?>> getKycStatus(String userId);
}
