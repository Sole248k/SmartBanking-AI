import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/budget.dart';
import '../repositories/budget_repository.dart';

class FirestoreBudgetRepositoryImpl implements BudgetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));
      final snapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: _uid)
          .get();
      final list = snapshot.docs.map((doc) => Budget.fromJson({
        ...doc.data(),
        'id': doc.id,
      })).toList();
      return right(list);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Budget>> watchBudgets() {
    if (_uid == null) return const Stream.empty();
    return _firestore
        .collection('budgets')
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Budget.fromJson({
        ...doc.data(),
        'id': doc.id,
      })).toList();
    });
  }

  @override
  Future<Either<Failure, Budget>> createBudget(String category, double limit) async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));
      final docRef = await _firestore.collection('budgets').add({
        'userId': _uid,
        'category': category,
        'limitAmount': limit,
        'spentAmount': 0.0,
        'period': 'Monthly',
      });
      final doc = await docRef.get();
      return right(Budget.fromJson({...doc.data()!, 'id': doc.id}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await _firestore.collection('budgets').doc(id).delete();
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
