import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';

class FirebaseSavingsRepository implements SavingsRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  String get _uid => _auth.currentUser?.uid ?? '';
  CollectionReference get _col =>
      _firestore.collection('users').doc(_uid).collection('savings_goals');
  DocumentReference get _userDoc =>
      _firestore.collection('users').doc(_uid);

  @override
  Future<Either<Failure, List<SavingsGoal>>> getSavingsGoals() async {
    try {
      final snap = await _col.get();
      final goals = snap.docs
          .map((d) => SavingsGoal.fromJson(
              {'id': d.id, ...d.data() as Map<String, dynamic>}))
          .toList();
      return Right(goals);
    } catch (e) {
      return Left(ServerFailure('Failed to load savings goals: $e'));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> getSavingsGoalById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return Left(ServerFailure('Goal not found'));
      return Right(SavingsGoal.fromJson(
          {'id': doc.id, ...doc.data() as Map<String, dynamic>}));
    } catch (e) {
      return Left(ServerFailure('Error fetching goal: $e'));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> createSavingsGoal(SavingsGoal goal) async {
    try {
      final id = _uuid.v4();
      final updatedGoal = goal.copyWith(
        id: id,
        userId: _uid,
        currentAmount: 0,
        status: SavingsGoalStatus.active,
        createdAt: DateTime.now(),
      );
      await _col.doc(id).set(updatedGoal.toJson());
      return Right(updatedGoal);
    } catch (e) {
      return Left(ServerFailure('Failed to create goal: $e'));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> updateSavingsGoal(SavingsGoal goal) async {
    try {
      await _col.doc(goal.id).update(goal.toJson());
      return Right(goal);
    } catch (e) {
      return Left(ServerFailure('Failed to update goal: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSavingsGoal(String id) async {
    try {
      await _col.doc(id).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete goal: $e'));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> depositToGoal({
    required String goalId,
    required double amount,
    String? notes,
  }) async {
    try {
      final goalDoc = await _col.doc(goalId).get();
      if (!goalDoc.exists) return Left(ServerFailure('Goal not found'));

      final goal = SavingsGoal.fromJson(
          {'id': goalDoc.id, ...goalDoc.data() as Map<String, dynamic>});

      final userSnap = await _userDoc.get();
      final userData = userSnap.data() as Map<String, dynamic>?;
      final availableBalance = (userData?['availableBalance'] as num?)?.toDouble() ?? 0.0;
      final currentSavingsBalance = (userData?['savingsBalance'] as num?)?.toDouble() ?? 0.0;

      if (amount > availableBalance) {
        return Left(ServerFailure('Insufficient funds'));
      }

      final deposit = SavingsDepositEntry(
        id: _uuid.v4(),
        amount: amount,
        timestamp: DateTime.now(),
        isAutoDeposit: false,
        notes: notes,
      );
      
      final newGoalAmount = goal.currentAmount + amount;
      final updated = goal.copyWith(
        currentAmount: newGoalAmount,
        deposits: [...goal.deposits, deposit],
        status: newGoalAmount >= goal.targetAmount
            ? SavingsGoalStatus.completed
            : goal.status,
      );

      final batch = _firestore.batch();
      batch.update(_col.doc(goalId), updated.toJson());
      batch.update(_userDoc, {
        'availableBalance': availableBalance - amount,
        'savingsBalance': currentSavingsBalance + amount,
      });

      // Record transaction
      final txId = _uuid.v4();
      final txRef = _userDoc.collection('transactions').doc(txId);
      batch.set(txRef, {
        'id': txId,
        'title': 'Savings: ${goal.title}',
        'description': notes ?? 'Deposit to savings goal',
        'amount': -amount,
        'type': 'transfer',
        'category': 'savings',
        'status': 'completed',
        'timestamp': DateTime.now().toIso8601String(),
        'reference': 'SAV${DateTime.now().millisecondsSinceEpoch}',
      });

      await batch.commit();
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Deposit failed: $e'));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> withdrawFromGoal({
    required String goalId,
    required double amount,
    String? notes,
  }) async {
    try {
      final goalDoc = await _col.doc(goalId).get();
      if (!goalDoc.exists) return Left(ServerFailure('Goal not found'));

      final goal = SavingsGoal.fromJson(
          {'id': goalDoc.id, ...goalDoc.data() as Map<String, dynamic>});

      if (amount > goal.currentAmount) {
        return Left(ServerFailure('Insufficient funds in goal'));
      }

      final userSnap = await _userDoc.get();
      final userData = userSnap.data() as Map<String, dynamic>?;
      final currentAvailable = (userData?['availableBalance'] as num?)?.toDouble() ?? 0.0;
      final currentSavings = (userData?['savingsBalance'] as num?)?.toDouble() ?? 0.0;

      final updated = goal.copyWith(
        currentAmount: goal.currentAmount - amount,
      );

      final batch = _firestore.batch();
      batch.update(_col.doc(goalId), updated.toJson());
      batch.update(_userDoc, {
        'availableBalance': currentAvailable + amount,
        'savingsBalance': (currentSavings - amount).clamp(0.0, double.infinity),
      });

      // Record transaction
      final txId = _uuid.v4();
      final txRef = _userDoc.collection('transactions').doc(txId);
      batch.set(txRef, {
        'id': txId,
        'title': 'Savings Withdrawal: ${goal.title}',
        'description': notes ?? 'Withdrawal from savings goal',
        'amount': amount,
        'type': 'credit',
        'category': 'savings',
        'status': 'completed',
        'timestamp': DateTime.now().toIso8601String(),
        'reference': 'SWDRAW${DateTime.now().millisecondsSinceEpoch}',
      });

      await batch.commit();
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Withdrawal failed: $e'));
    }
  }

  @override
  Stream<List<SavingsGoal>> watchSavingsGoals() {
    return _col.snapshots().map((snap) => snap.docs
        .map((d) => SavingsGoal.fromJson(
            {'id': d.id, ...d.data() as Map<String, dynamic>}))
        .toList());
  }
}
