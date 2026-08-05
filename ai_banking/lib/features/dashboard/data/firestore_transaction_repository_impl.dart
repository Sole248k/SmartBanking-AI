import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/models/account.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

class FirestoreTransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));
      final snapshot = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: _uid)
          .get();
      final accounts = snapshot.docs
          .map((doc) => Account.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      return right(accounts);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Account>> watchAccounts() {
    if (_uid == null) return const Stream.empty();
    return _firestore
        .collection('accounts')
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Account.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  @override
  Future<Either<Failure, void>> addFunds(
    String accountId,
    double amount,
  ) async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));
      final accountRef = _firestore.collection('accounts').doc(accountId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(accountRef);
        if (snapshot.exists) {
          final currentBalance = (snapshot.data()!['balance'] as num)
              .toDouble();
          transaction.update(accountRef, {
            'balance': currentBalance + amount,
            'availableBalance': currentBalance + amount,
          });

          // Log a "Top-up" transaction
          final transactionsRef = _firestore.collection('transactions').doc();
          transaction.set(transactionsRef, {
            'userId': _uid,
            'accountId': accountId,
            'title': 'Funds Added',
            'description': 'Manual top-up for testing',
            'amount': amount,
            'date': FieldValue.serverTimestamp(),
            'category': 'Deposit',
            'status': 'completed',
            'type': 'credit',
          });
        }
      });
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    int limit = 10,
  }) async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: _uid)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      final transactions = snapshot.docs
          .map(
            (doc) => Transaction.fromJson({
              ...doc.data(),
              'id': doc.id,
              'date': (doc.data()['date'] as Timestamp)
                  .toDate()
                  .toIso8601String(),
            }),
          )
          .toList();

      return right(transactions);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Transaction>> watchRecentTransactions({int limit = 10}) {
    if (_uid == null) return const Stream.empty();
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => Transaction.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                  'date': (doc.data()['date'] as Timestamp)
                      .toDate()
                      .toIso8601String(),
                }),
              )
              .toList();
        });
  }

  @override
  Future<Either<Failure, Account>> getAccountDetails(String id) async {
    try {
      final doc = await _firestore.collection('accounts').doc(id).get();
      if (!doc.exists) return left(const ServerFailure('Account not found'));

      return right(Account.fromJson({...doc.data()!, 'id': doc.id}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> addExternalCard(Account account) async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));

      // Check for duplicate card number for this user
      final existing = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: _uid)
          .where('cardNumber', isEqualTo: account.cardNumber)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return left(const ServerFailure('This card is already linked to your account'));
      }

      // Generate a one-time demo balance between ₱5,000 and ₱99,999 if 0
      final double demoBalance = account.balance > 0
          ? account.balance
          : (5000 + math.Random().nextDouble() * 94999).roundToDouble();

      final accountWithBalance = account.copyWith(
        balance: demoBalance,
        availableBalance: demoBalance,
      );

      final docRef = await _firestore.collection('accounts').add({
        ...accountWithBalance.toJson(),
        'userId': _uid,
        'linkedAt': DateTime.now().toIso8601String(),
        'isExternal': true,
      });

      // Log Card Added Transaction
      await _firestore.collection('transactions').add({
        'userId': _uid,
        'accountId': docRef.id,
        'title': 'Linked ${account.bankName} Card',
        'description': 'Added external payment card',
        'amount': demoBalance,
        'date': FieldValue.serverTimestamp(),
        'category': 'Card Management',
        'status': 'completed',
        'type': 'credit',
      });

      final newAccount = accountWithBalance.copyWith(
        id: docRef.id,
        userId: _uid!,
        linkedAt: DateTime.now().toIso8601String(),
        isExternal: true,
      );
      return right(newAccount);
    } catch (e) {
      return left(ServerFailure('Failed to add card: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCardStatus(String accountId, AccountStatus status) async {
    try {
      await _firestore.collection('accounts').doc(accountId).update({
        'status': status.name,
      });
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to update status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCardNickname(String accountId, String nickname) async {
    try {
      await _firestore.collection('accounts').doc(accountId).update({
        'nickname': nickname,
        'label': nickname.isEmpty ? 'Card' : nickname,
      });
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to update nickname: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultCard(String accountId) async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));
      final userAccounts = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: _uid)
          .get();

      final batch = _firestore.batch();
      for (final doc in userAccounts.docs) {
        batch.update(doc.reference, {'isDefault': doc.id == accountId});
      }
      await batch.commit();
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to set default card: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeCard(String accountId) async {
    try {
      await _firestore.collection('accounts').doc(accountId).delete();
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to remove card: $e'));
    }
  }
}
