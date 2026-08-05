import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/beneficiary.dart';

abstract class TransferRepository {
  Future<Either<Failure, List<Beneficiary>>> getRecentBeneficiaries();
  Stream<List<Beneficiary>> watchRecentBeneficiaries();
  Future<Either<Failure, void>> addBeneficiary(Beneficiary beneficiary);
  Future<Either<Failure, void>> executeTransfer({
    required String fromAccountId,
    required String beneficiaryId,
    required double amount,
    String? note,
  });
}
