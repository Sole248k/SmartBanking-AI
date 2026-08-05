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
  if (activeAccount == null) return const Stream.empty();
  
  return ref.watch(transactionRepositoryProvider).watchRecentTransactions().map((transactions) {
    return transactions.where((t) => t.accountId == activeAccount.id).toList();
  });
}
