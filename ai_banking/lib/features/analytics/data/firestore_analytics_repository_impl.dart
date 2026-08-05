import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/spending_report.dart';
import '../repositories/analytics_repository.dart';

class FirestoreAnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Either<Failure, SpendingReport>> getSpendingReport({required DateTime start, required DateTime end}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return left(const AuthFailure('User not logged in'));

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true) // Matches the existing index
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      double totalSpent = 0;
      double totalIncome = 0;
      final Map<String, double> breakdown = {};
      final Map<DateTime, double> trendMap = {};

      // Pre-populate trendMap with all days in range
      for (int i = 0; i <= end.difference(start).inDays; i++) {
        final day = start.add(Duration(days: i));
        trendMap[DateTime(day.year, day.month, day.day)] = 0.0;
      }

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num).toDouble();
        final type = data['type'] as String;
        final category = data['category'] as String;
        final date = (data['date'] as Timestamp).toDate();
        final dateKey = DateTime(date.year, date.month, date.day);

        if (type == 'debit') {
          totalSpent += amount;
          breakdown[category] = (breakdown[category] ?? 0) + amount;
          trendMap[dateKey] = (trendMap[dateKey] ?? 0) + amount;
        } else {
          totalIncome += amount;
        }
      }

      final dailyTrend = trendMap.entries.map((e) => DailyPoint(date: e.key, value: e.value)).toList();
      dailyTrend.sort((a, b) => a.date.compareTo(b.date));

      return right(SpendingReport(
        totalSpent: totalSpent,
        totalIncome: totalIncome,
        categoryBreakdown: breakdown,
        dailyTrend: dailyTrend,
      ));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
