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
  Future<Either<Failure, RecipientDetails?>> lookupRecipient(String query) async {
    try {
      final cleanQuery = query.trim();
      if (cleanQuery.isEmpty) return right(null);

      // 1. Search accounts by accountNumber
      var snapshot = await _firestore
          .collection('accounts')
          .where('accountNumber', isEqualTo: cleanQuery)
          .limit(1)
          .get();

      // 2. Search accounts by cardNumber if not found
      if (snapshot.docs.isEmpty) {
        snapshot = await _firestore
            .collection('accounts')
            .where('cardNumber', isEqualTo: cleanQuery)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isEmpty) return right(null);

      final doc = snapshot.docs.first;
      final data = doc.data();
      final userId = data['userId'] as String? ?? '';

      // Fetch user full name from users collection if available
      String recipientName = data['holderName'] as String? ?? 'SmartBank User';
      if (userId.isNotEmpty) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data()?['fullName'] != null) {
          recipientName = userDoc.data()!['fullName'] as String;
        }
      }

      final rawCardNum = data['cardNumber'] as String? ?? data['accountNumber'] as String? ?? '';
      final masked = rawCardNum.length >= 4
          ? '**** **** **** ${rawCardNum.substring(rawCardNum.length - 4)}'
          : rawCardNum;

      return right(RecipientDetails(
        accountId: doc.id,
        userId: userId,
        recipientName: recipientName,
        bankName: data['bankName'] as String? ?? 'SmartBank AI',
        accountNumber: data['accountNumber'] as String? ?? doc.id,
        maskedCardNumber: masked,
        cardNetwork: data['cardNetwork'] as String? ?? 'visa',
      ));
    } catch (e) {
      return left(ServerFailure('Recipient lookup failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> executeTransfer({
    required String fromAccountId,
    required String recipientName,
    required String recipientAccountNumber,
    required String bankName,
    required double amount,
    String? note,
    String? beneficiaryId,
    bool saveAsBeneficiary = false,
  }) async {
    try {
      final senderUid = _uid;
      if (senderUid == null) return left(const AuthFailure('User not logged in'));

      final String targetName = recipientName.trim();
      final String targetAccountNumber = recipientAccountNumber.trim();
      final String targetBank = bankName.trim();

      // Optionally save as beneficiary if requested
      if (saveAsBeneficiary && beneficiaryId == null) {
        await addBeneficiary(Beneficiary(
          id: '',
          userId: senderUid,
          name: targetName,
          accountNumber: targetAccountNumber,
          bankName: targetBank,
        ));
      }

      final senderAccountRef = _firestore.collection('accounts').doc(fromAccountId);
      final transactionsRef = _firestore.collection('transactions');

      // Shared Reference Number
      final refCode = 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';

      // Detect if recipient account exists in database (Internal or Inter-user P2P)
      DocumentReference? recipientAccountRef;
      String? recipientUserId;

      final recipientQuery = await _firestore
          .collection('accounts')
          .where('accountNumber', isEqualTo: targetAccountNumber)
          .limit(1)
          .get();

      if (recipientQuery.docs.isNotEmpty) {
        final recipientDoc = recipientQuery.docs.first;
        final recipientData = recipientDoc.data();
        recipientAccountRef = recipientDoc.reference;
        recipientUserId = recipientData['userId'] as String?;
      } else {
        // Try searching by cardNumber
        final cardQuery = await _firestore
            .collection('accounts')
            .where('cardNumber', isEqualTo: targetAccountNumber)
            .limit(1)
            .get();

        if (cardQuery.docs.isNotEmpty) {
          final cardDoc = cardQuery.docs.first;
          final cardData = cardDoc.data();
          recipientAccountRef = cardDoc.reference;
          recipientUserId = cardData['userId'] as String?;
        }
      }

      // Execute Atomic Transaction
      await _firestore.runTransaction((transaction) async {
        // --- READS ---
        final senderSnapshot = await transaction.get(senderAccountRef);
        if (!senderSnapshot.exists) throw 'Sender account not found';
        final senderData = senderSnapshot.data() as Map<String, dynamic>?;
        final senderBalance = (senderData?['balance'] as num?)?.toDouble() ?? 0.0;

        double recipientBalance = 0.0;
        if (recipientAccountRef != null) {
          final recipientSnapshot = await transaction.get(recipientAccountRef);
          if (recipientSnapshot.exists) {
            final recipientData = recipientSnapshot.data() as Map<String, dynamic>?;
            recipientBalance = (recipientData?['balance'] as num?)?.toDouble() ?? 0.0;
          }
        }

        // --- VALIDATION ---
        if (senderBalance < amount) throw 'Insufficient available balance';

        // --- WRITES ---

        // 1. Debit Sender
        final newSenderBal = (senderBalance - amount).toDouble();
        transaction.update(senderAccountRef, {
          'balance': newSenderBal,
          'availableBalance': newSenderBal,
        });

        // 2. Log Sender Debit Transaction
        final senderAccNum = (senderData?['accountNumber'] as String?) ?? (senderData?['cardNumber'] as String?) ?? '';
        final senderBankName = (senderData?['bankName'] as String?) ?? 'SmartBank AI';
        final senderFullName = _auth.currentUser?.displayName ?? 'SmartBank User';

        transaction.set(transactionsRef.doc(), {
          'userId': senderUid,
          'accountId': fromAccountId,
          'title': 'Transfer to $targetName',
          'description': note ?? 'Fund Transfer ($refCode)',
          'amount': amount.toDouble(),
          'date': FieldValue.serverTimestamp(),
          'category': 'Transfer',
          'status': 'completed',
          'type': 'debit',
          'senderName': senderFullName,
          'senderAccount': senderAccNum,
          'senderBank': senderBankName,
          'recipientName': targetName,
          'targetBank': targetBank,
          'targetAccount': targetAccountNumber,
          'referenceNumber': refCode,
        });

        // 3. Credit Recipient (if found in ecosystem)
        if (recipientAccountRef != null && recipientUserId != null) {
          final newRecipientBal = (recipientBalance + amount).toDouble();
          transaction.update(recipientAccountRef, {
            'balance': newRecipientBal,
            'availableBalance': newRecipientBal,
          });

          // Log Recipient Credit Transaction
          transaction.set(transactionsRef.doc(), {
            'userId': recipientUserId,
            'accountId': recipientAccountRef.id,
            'title': 'Received from $senderFullName',
            'description': note ?? 'Incoming Transfer ($refCode)',
            'amount': amount.toDouble(),
            'date': FieldValue.serverTimestamp(),
            'category': 'Transfer',
            'status': 'completed',
            'type': 'credit',
            'senderId': senderUid,
            'senderName': senderFullName,
            'senderAccount': senderAccNum,
            'senderBank': senderBankName,
            'recipientName': targetName,
            'targetBank': targetBank,
            'targetAccount': targetAccountNumber,
            'referenceNumber': refCode,
          });
        }
      });

      return right(null);
    } on FirebaseException catch (e) {
      return left(ServerFailure('Firebase Error [${e.code}]: ${e.message}'));
    } catch (e) {
      return left(ServerFailure('Transfer Failed: $e'));
    }
  }
}
