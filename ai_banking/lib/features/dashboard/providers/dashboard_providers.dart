import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firestore_transaction_repository_impl.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../../shared/models/account.dart';
import 'active_account_provider.dart';

part 'dashboard_providers.g.dart';

@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return FirestoreTransactionRepositoryImpl();
}

@riverpod
Stream<List<Account>> dashboardAccounts(DashboardAccountsRef ref) {
  return ref.watch(transactionRepositoryProvider).watchAccounts();
}

@riverpod
Stream<List<Transaction>> recentTransactions(RecentTransactionsRef ref) {
  final activeAccount = ref.watch(activeAccountProvider);

  return ref.watch(transactionRepositoryProvider).watchRecentTransactions().map((transactions) {
    if (activeAccount == null) return const [];

    final accId = activeAccount.id;
    final accNum = activeAccount.accountNumber;
    final cardNum = activeAccount.cardNumber;

    return transactions.where((t) {
      if (t.accountId == accId) return true;
      if (accNum.isNotEmpty && t.targetAccount == accNum) return true;
      if (cardNum.isNotEmpty && t.targetAccount == cardNum) return true;
      if (accNum.isNotEmpty && t.senderAccount == accNum) return true;
      if (cardNum.isNotEmpty && t.senderAccount == cardNum) return true;
      return false;
    }).toList();
  });
}
