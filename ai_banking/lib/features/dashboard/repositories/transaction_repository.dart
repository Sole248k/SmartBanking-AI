import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/models/account.dart';
import '../models/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Account>>> getAccounts();
  Stream<List<Account>> watchAccounts();
  Future<Either<Failure, void>> addFunds(String accountId, double amount);
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    int limit = 10,
  });
  Stream<List<Transaction>> watchRecentTransactions({int limit = 10});
  Future<Either<Failure, Account>> getAccountDetails(String id);
}
