import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firestore_budget_repository_impl.dart';
import '../models/budget.dart';
import '../repositories/budget_repository.dart';

part 'budget_providers.g.dart';

@riverpod
BudgetRepository budgetRepository(BudgetRepositoryRef ref) {
  return FirestoreBudgetRepositoryImpl();
}

@riverpod
class BudgetController extends _$BudgetController {
  @override
  Stream<List<Budget>> build() {
    return ref.watch(budgetRepositoryProvider).watchBudgets();
  }

  Future<void> createBudget(String category, double limit) async {
    await ref.read(budgetRepositoryProvider).createBudget(category, limit);
  }
}
