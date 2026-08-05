import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets();
  Stream<List<Budget>> watchBudgets();
  Future<Either<Failure, Budget>> createBudget(String category, double limit);
  Future<Either<Failure, void>> deleteBudget(String id);
}
