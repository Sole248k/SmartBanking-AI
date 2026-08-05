import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/spending_report.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, SpendingReport>> getSpendingReport({required DateTime start, required DateTime end});
}
