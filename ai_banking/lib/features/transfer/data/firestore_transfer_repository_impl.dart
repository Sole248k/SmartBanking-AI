import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/beneficiary.dart';
import '../repositories/transfer_repository.dart';

class FirestoreTransferRepositoryImpl implements TransferRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<Either<Failure, List<Beneficiary>>> getRecentBeneficiaries() async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));
      final snapshot = await _firestore
          .collection('beneficiaries')
          .where('userId', isEqualTo: _uid)
          .get();
      final list = snapshot.docs.map((doc) => Beneficiary.fromJson({
        ...doc.data(),
        'id': doc.id,
      })).toList();
      return right(list);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Beneficiary>> watchRecentBeneficiaries() {
    if (_uid == null) return const Stream.empty();
    return _firestore
        .collection('beneficiaries')
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Beneficiary.fromJson({
        ...doc.data(),
        'id': doc.id,
      })).toList();
    });
  }

  @override
  Future<Either<Failure, void>> addBeneficiary(Beneficiary beneficiary) async {
    try {
      if (_uid == null) return left(const AuthFailure('User not logged in'));
      await _firestore.collection('beneficiaries').add({
        ...beneficiary.toJson(),
        'userId': _uid,
      });
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> executeTransfer({
    required String fromAccountId,
    required String beneficiaryId,
    required double amount,
    String? note,
  }) async {
    try {
      final senderUid = _uid;
      if (senderUid == null) return left(const AuthFailure('User not logged in'));

      // 1. Fetch Beneficiary
      final beneficiaryDoc = await _firestore.collection('beneficiaries').doc(beneficiaryId).get();
      if (!beneficiaryDoc.exists) return left(const ServerFailure('Beneficiary not found'));
      
      final beneficiaryData = beneficiaryDoc.data();
      if (beneficiaryData == null) return left(const ServerFailure('Beneficiary data is empty'));

      final String targetAccountNumber = beneficiaryData['accountNumber'] ?? '';
      final String targetName = beneficiaryData['name'] ?? 'Unknown Recipient';
      final String targetBank = beneficiaryData['bankName'] ?? 'External Bank';

      final senderAccountRef = _firestore.collection('accounts').doc(fromAccountId);
      final transactionsRef = _firestore.collection('transactions');

      // 2. Detect if it's a SmartBank P2P transfer (PRE-READ)
      final bool isSmartBank = targetBank.toLowerCase().contains('smartbank');
      DocumentReference? recipientAccountRef;
      String? recipientUserId;

      if (isSmartBank) {
        final recipientQuery = await _firestore
            .collection('accounts')
            .where('accountNumber', isEqualTo: targetAccountNumber)
            .limit(1)
            .get();
            
        if (recipientQuery.docs.isNotEmpty) {
          final recipientDoc = recipientQuery.docs.first;
          final recipientData = recipientDoc.data() as Map<String, dynamic>?;
          recipientAccountRef = recipientDoc.reference;
          recipientUserId = recipientData?['userId'] as String?;
        }
      }

      // 3. Execute Atomic Transaction
      await _firestore.runTransaction((transaction) async {
        // --- ALL READS MUST HAPPEN FIRST ---
        
        // Read Sender
        final senderSnapshot = await transaction.get(senderAccountRef);
        if (!senderSnapshot.exists) throw 'Sender account not found';
        final senderData = senderSnapshot.data();
        final senderBalance = (senderData?['balance'] as num?)?.toDouble() ?? 0.0;

        // Read Recipient (If P2P)
        double recipientBalance = 0.0;
        if (recipientAccountRef != null) {
          final recipientSnapshot = await transaction.get(recipientAccountRef);
          if (recipientSnapshot.exists) {
            final recipientData = recipientSnapshot.data() as Map<String, dynamic>?;
            recipientBalance = (recipientData?['balance'] as num?)?.toDouble() ?? 0.0;
          }
        }

        // --- VALIDATION ---
        if (senderBalance < amount) throw 'Insufficient funds';

        // --- ALL WRITES MUST HAPPEN LAST ---

        // Update Sender Balance
        transaction.update(senderAccountRef, {'balance': (senderBalance - amount).toDouble()});

        // Log Sender Transaction (Debit)
        transaction.set(transactionsRef.doc(), {
          'userId': senderUid,
          'accountId': fromAccountId,
          'title': 'Transfer to $targetName',
          'description': note ?? 'P2P Transfer',
          'amount': amount.toDouble(),
          'date': FieldValue.serverTimestamp(),
          'category': 'Transfer',
          'status': 'completed',
          'type': 'debit',
          'targetBank': targetBank,
          'targetAccount': targetAccountNumber,
        });

        // Update Recipient (If P2P)
        if (recipientAccountRef != null && recipientUserId != null) {
          transaction.update(recipientAccountRef, {'balance': (recipientBalance + amount).toDouble()});

          // Log Recipient Transaction (Credit)
          transaction.set(transactionsRef.doc(), {
            'userId': recipientUserId,
            'accountId': recipientAccountRef.id,
            'title': 'Received from ${_auth.currentUser?.displayName ?? 'SmartBank User'}',
            'description': note ?? 'Incoming P2P',
            'amount': amount.toDouble(),
            'date': FieldValue.serverTimestamp(),
            'category': 'Transfer',
            'status': 'completed',
            'type': 'credit',
            'senderId': senderUid,
          });
        }
      });

      return right(null);
    } on FirebaseException catch (e) {
      return left(ServerFailure('Firebase Error [${e.code}]: ${e.message}'));
    } catch (e) {
      // Catch specific transaction failures
      return left(ServerFailure('Transfer Failed: $e'));
    }
  }
}
