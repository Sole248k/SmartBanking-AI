import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/kyc_record.dart';
import '../../domain/repositories/kyc_repository.dart';

class FirebaseKycRepository implements KycRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseKycRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Either<Failure, String>> uploadKycImage({
    required String filePath,
    required String folderName,
  }) async {
    // Mock path: return a placeholder URL so the flow works on web/emulator
    if (filePath.startsWith('mock_')) {
      return Right('https://placehold.co/400x300/png?text=$folderName');
    }
    try {
      if (kIsWeb) {
        // Web: return mock URL since File() is not available
        return Right('https://placehold.co/400x300/png?text=$folderName');
      }
      final file = File(filePath);
      final ref = _storage
          .ref()
          .child('kyc')
          .child(folderName)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return Right(url);
    } catch (e) {
      return Left(ServerFailure('Failed to upload image: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> submitKyc({
    required String userId,
    required KycRecord record,
  }) async {
    try {
      final data = record.toJson();
      data['submittedAt'] = FieldValue.serverTimestamp();
      data['status'] = 'pending';

      // Write KYC record
      await _firestore.collection('kyc_records').doc(userId).set(data);

      // Update the profile document (correct collection)
      await _firestore.collection('profiles').doc(userId).update({
        'kycStatus': 'Pending Review',
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to submit KYC: $e'));
    }
  }

  @override
  Future<Either<Failure, KycRecord?>> getKycStatus(String userId) async {
    try {
      final doc =
          await _firestore.collection('kyc_records').doc(userId).get();
      if (!doc.exists) return const Right(null);
      return Right(KycRecord.fromJson(doc.data()!));
    } catch (e) {
      return Left(ServerFailure('Failed to get KYC status: $e'));
    }
  }

  /// Mock admin approval — simulates a reviewer approving the KYC.
  /// Call this from dev tools to test the approved flow.
  Future<void> mockApproveKyc(String userId) async {
    await _firestore.collection('kyc_records').doc(userId).update({
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('profiles').doc(userId).update({
      'kycStatus': 'Approved',
    });
  }

  /// Mock admin rejection.
  Future<void> mockRejectKyc(String userId, String reason) async {
    await _firestore.collection('kyc_records').doc(userId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('profiles').doc(userId).update({
      'kycStatus': 'Rejected',
    });
  }
}
