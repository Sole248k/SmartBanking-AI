import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/wallet.dart';
import '../repositories/wallet_repository.dart';

class FirestoreWalletRepositoryImpl implements WalletRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<Either<Failure, Wallet>> getWallet() async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));
      final snapshot = await _firestore
          .collection('wallets')
          .where('userId', isEqualTo: _uid)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return left(const ServerFailure('Wallet not found'));
      final doc = snapshot.docs.first;
      return right(Wallet.fromJson({...doc.data(), 'id': doc.id}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Wallet> watchWallet() {
    if (_uid == null) return const Stream.empty();
    return _firestore
        .collection('wallets')
        .where('userId', isEqualTo: _uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) throw Exception('Wallet not found');
      final doc = snapshot.docs.first;
      return Wallet.fromJson({...doc.data(), 'id': doc.id});
    });
  }

  @override
  Future<Either<Failure, Wallet>> topUp(double amount, String targetAccountId) async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));

      final userAccountsSnapshot = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: _uid)
          .get();

      if (userAccountsSnapshot.docs.isEmpty) {
        return left(const ServerFailure('No banking accounts found in database for user.'));
      }

      DocumentSnapshot? targetDoc;
      if (targetAccountId.isNotEmpty) {
        targetDoc = userAccountsSnapshot.docs
            .where((doc) => doc.id == targetAccountId)
            .firstOrNull;
      }

      targetDoc ??= userAccountsSnapshot.docs
          .where((doc) => doc.data()['isExternal'] != true)
          .firstOrNull ?? userAccountsSnapshot.docs.first;

      final accountRef = targetDoc.reference;
      final actualAccountId = targetDoc.id;

      final transactionsRef = _firestore.collection('transactions');

      await _firestore.runTransaction((transaction) async {
        // --- 1. READS (Must occur before ANY writes) ---
        final accountSnapshot = await transaction.get(accountRef);
        if (!accountSnapshot.exists) throw Exception('SmartBank card/account not found in database');

        final accountData = accountSnapshot.data() as Map<String, dynamic>?;
        final currentAccountBalance =
            (accountData?['balance'] as num?)?.toDouble() ?? 0.0;
        final newBalance = currentAccountBalance + amount;

        // --- 2. WRITES ---
        // Credit target card balance in accounts collection
        transaction.update(accountRef, {
          'balance': newBalance,
          'availableBalance': newBalance,
        });

        // Create Top-Up Deposit transaction record
        final refCode = 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        transaction.set(transactionsRef.doc(), {
          'userId': _uid,
          'accountId': actualAccountId,
          'title': 'Top-Up Deposit',
          'description': 'SmartBank AI Card deposit ($refCode)',
          'amount': amount,
          'date': FieldValue.serverTimestamp(),
          'category': 'Deposit',
          'status': 'completed',
          'type': 'credit',
          'referenceNumber': refCode,
          'targetAccount': accountData?['accountNumber'] ?? accountData?['cardNumber'] ?? '',
          'targetBank': 'SmartBank AI',
          'authMethod': 'Security PIN',
        });
      });

      return right(Wallet(id: 'main', userId: _uid!, balance: 0.0, currency: 'PHP', linkedAccountIds: []));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wallet>> withdraw(double amount, String toAccountId) async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));

      final walletQuery = await _firestore.collection('wallets').where('userId', isEqualTo: _uid).limit(1).get();
      if (walletQuery.docs.isEmpty) throw Exception('Wallet not found');

      final walletRef = walletQuery.docs.first.reference;
      final accountRef = _firestore.collection('accounts').doc(toAccountId);
      final transactionsRef = _firestore.collection('transactions');

      await _firestore.runTransaction((transaction) async {
        final walletSnapshot = await transaction.get(walletRef);
        final accountSnapshot = await transaction.get(accountRef);

        if (!accountSnapshot.exists) throw Exception('Destination account not found');

        final currentWalletBalance = (walletSnapshot.data()!['balance'] as num).toDouble();
        if (currentWalletBalance < amount) throw Exception('Insufficient wallet balance');

        final currentAccountBalance = (accountSnapshot.data()!['balance'] as num).toDouble();

        // 1. Subtract from wallet
        transaction.update(walletRef, {'balance': currentWalletBalance - amount});

        // 2. Add to bank account
        transaction.update(accountRef, {'balance': currentAccountBalance + amount});

        // 3. Create transaction record
        transaction.set(transactionsRef.doc(), {
          'userId': _uid,
          'title': 'Wallet Withdrawal',
          'description': 'To bank account',
          'amount': amount,
          'date': FieldValue.serverTimestamp(),
          'category': 'Wallet',
          'status': 'completed',
          'type': 'credit',
          'accountId': toAccountId,
        });
      });

      return getWallet();
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
