import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/savings_goal.dart';

abstract class SavingsRepository {
  Future<Either<Failure, List<SavingsGoal>>> getSavingsGoals();
  Future<Either<Failure, SavingsGoal>> getSavingsGoalById(String id);
  Future<Either<Failure, SavingsGoal>> createSavingsGoal(SavingsGoal goal);
  Future<Either<Failure, SavingsGoal>> updateSavingsGoal(SavingsGoal goal);
  Future<Either<Failure, void>> deleteSavingsGoal(String id);
  Future<Either<Failure, SavingsGoal>> depositToGoal({
    required String goalId,
    required double amount,
    String? notes,
  });
  Future<Either<Failure, SavingsGoal>> withdrawFromGoal({
    required String goalId,
    required double amount,
    String? notes,
  });
  Stream<List<SavingsGoal>> watchSavingsGoals();
}
