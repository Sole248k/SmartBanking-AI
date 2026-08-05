import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/beneficiary.dart';

class RecipientDetails {
  final String accountId;
  final String userId;
  final String recipientName;
  final String bankName;
  final String accountNumber;
  final String maskedCardNumber;
  final String cardNetwork;

  const RecipientDetails({
    required this.accountId,
    required this.userId,
    required this.recipientName,
    required this.bankName,
    required this.accountNumber,
    required this.maskedCardNumber,
    required this.cardNetwork,
  });
}

abstract class TransferRepository {
  Future<Either<Failure, List<Beneficiary>>> getRecentBeneficiaries();
  Stream<List<Beneficiary>> watchRecentBeneficiaries();
  Future<Either<Failure, void>> addBeneficiary(Beneficiary beneficiary);
  Future<Either<Failure, RecipientDetails?>> lookupRecipient(String query);
  Future<Either<Failure, void>> executeTransfer({
    required String fromAccountId,
    required String recipientName,
    required String recipientAccountNumber,
    required String bankName,
    required double amount,
    String? note,
    String? beneficiaryId,
    bool saveAsBeneficiary = false,
  });
}
