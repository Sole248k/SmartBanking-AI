import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/wallet.dart';

abstract class WalletRepository {
  Future<Either<Failure, Wallet>> getWallet();
  Stream<Wallet> watchWallet();
  Future<Either<Failure, Wallet>> topUp(double amount, String fromAccountId);
  Future<Either<Failure, Wallet>> withdraw(double amount, String toAccountId);
}
