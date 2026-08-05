import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firestore_analytics_repository_impl.dart';
import '../models/spending_report.dart';
import '../repositories/analytics_repository.dart';

part 'analytics_providers.g.dart';

@riverpod
AnalyticsRepository analyticsRepository(AnalyticsRepositoryRef ref) {
  return FirestoreAnalyticsRepositoryImpl();
}

@riverpod
class SpendingReportController extends _$SpendingReportController {
  @override
  FutureOr<SpendingReport> build() async {
    final now = DateTime.now();
    final result = await ref.watch(analyticsRepositoryProvider).getSpendingReport(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
    return result.match(
      (failure) => throw failure.message,
      (report) => report,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final now = DateTime.now();
      final result = await ref.read(analyticsRepositoryProvider).getSpendingReport(
        start: DateTime(now.year, now.month, 1),
        end: now,
      );
      return result.match(
        (failure) => throw failure.message,
        (report) => report,
      );
    });
  }
}
