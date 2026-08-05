import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/firebase_savings_repository.dart';
import '../domain/entities/savings_goal.dart';
import '../domain/repositories/savings_repository.dart';

part 'savings_provider.g.dart';

@riverpod
SavingsRepository savingsRepository(SavingsRepositoryRef ref) {
  return FirebaseSavingsRepository();
}

@riverpod
Stream<List<SavingsGoal>> savingsGoals(SavingsGoalsRef ref) {
  return ref.watch(savingsRepositoryProvider).watchSavingsGoals();
}

@riverpod
class SavingsController extends _$SavingsController {
  @override
  FutureOr<void> build() {}

  Future<void> createGoal(SavingsGoal goal) async {
    state = const AsyncValue.loading();
    final result = await ref.read(savingsRepositoryProvider).createSavingsGoal(goal);
    state = result.match(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }

  Future<void> deposit(String goalId, double amount, String? notes) async {
    state = const AsyncValue.loading();
    final result = await ref.read(savingsRepositoryProvider).depositToGoal(
      goalId: goalId,
      amount: amount,
      notes: notes,
    );
    state = result.match(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }

  Future<void> withdraw(String goalId, double amount, String? notes) async {
    state = const AsyncValue.loading();
    final result = await ref.read(savingsRepositoryProvider).withdrawFromGoal(
      goalId: goalId,
      amount: amount,
      notes: notes,
    );
    state = result.match(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }

  Future<void> deleteGoal(String id) async {
    state = const AsyncValue.loading();
    final result = await ref.read(savingsRepositoryProvider).deleteSavingsGoal(id);
    state = result.match(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }
}
