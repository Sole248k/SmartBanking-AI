import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../domain/admin_user.dart';
import '../domain/audit_log.dart';
import 'audit_log_service.dart';

/// Handles admin-side KYC review operations.
class KycAdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _auditLog = AuditLogService();

  static const String _kycCollection = 'kyc_records';

  /// Stream all KYC records, filtered by status.
  Stream<List<Map<String, dynamic>>> watchKycByStatus(String status) {
    return _firestore
        .collection(_kycCollection)
        .where('status', isEqualTo: status)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Stream all KYC records (all statuses).
  Stream<List<Map<String, dynamic>>> watchAllKyc() {
    return _firestore
        .collection(_kycCollection)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Get a single KYC record by user ID.
  Future<Map<String, dynamic>?> getKycByUserId(String userId) async {
    final snap = await _firestore
        .collection(_kycCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data();
    data['id'] = snap.docs.first.id;
    return data;
  }

  /// Approve a KYC submission.
  Future<Either<Failure, void>> approveKyc({
    required String kycId,
    required String userId,
    required String userFullName,
    required AdminUser admin,
    String? notes,
  }) async {
    try {
      await _firestore.collection(_kycCollection).doc(kycId).update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': admin.uid,
        'reviewedByName': admin.fullName,
        if (notes != null) 'adminNotes': notes,
      });

      // Update user status across both profiles and users collections
      await _firestore.collection('profiles').doc(userId).set({
        'kycStatus': 'Approved',
      }, SetOptions(merge: true));

      await _firestore.collection('users').doc(userId).set({
        'kycStatus': 'Approved',
      }, SetOptions(merge: true));

      await _auditLog.log(
        admin: admin,
        action: AuditAction.approvedKyc,
        targetUserId: userId,
        targetUserName: userFullName,
        previousStatus: 'pending',
        newStatus: 'approved',
        notes: notes,
      );
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to approve KYC: $e'));
    }
  }

  /// Reject a KYC submission.
  Future<Either<Failure, void>> rejectKyc({
    required String kycId,
    required String userId,
    required String userFullName,
    required AdminUser admin,
    required String reason,
    String? notes,
  }) async {
    try {
      await _firestore.collection(_kycCollection).doc(kycId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': admin.uid,
        'reviewedByName': admin.fullName,
        if (notes != null) 'adminNotes': notes,
      });

      await _firestore.collection('profiles').doc(userId).set({
        'kycStatus': 'Rejected',
        'kycRejectionReason': reason,
      }, SetOptions(merge: true));

      await _firestore.collection('users').doc(userId).set({
        'kycStatus': 'Rejected',
        'kycRejectionReason': reason,
      }, SetOptions(merge: true));

      await _auditLog.log(
        admin: admin,
        action: AuditAction.rejectedKyc,
        targetUserId: userId,
        targetUserName: userFullName,
        previousStatus: 'pending',
        newStatus: 'rejected',
        notes: notes,
        metadata: {'rejectionReason': reason},
      );
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to reject KYC: $e'));
    }
  }

  /// Request additional documents from the user.
  Future<Either<Failure, void>> requestKycDocuments({
    required String kycId,
    required String userId,
    required String userFullName,
    required AdminUser admin,
    required List<String> requestedDocuments,
    String? notes,
  }) async {
    try {
      await _firestore.collection(_kycCollection).doc(kycId).update({
        'status': 'moreInfoRequired',
        'requestedDocuments': requestedDocuments,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': admin.uid,
        if (notes != null) 'adminNotes': notes,
      });

      await _firestore.collection('profiles').doc(userId).set({
        'kycStatus': 'More Info Required',
        'requestedDocuments': requestedDocuments,
      }, SetOptions(merge: true));

      await _firestore.collection('users').doc(userId).set({
        'kycStatus': 'More Info Required',
        'requestedDocuments': requestedDocuments,
      }, SetOptions(merge: true));

      await _auditLog.log(
        admin: admin,
        action: AuditAction.requestedKycDocs,
        targetUserId: userId,
        targetUserName: userFullName,
        previousStatus: 'pending',
        newStatus: 'moreInfoRequired',
        notes: notes,
        metadata: {'requestedDocuments': requestedDocuments},
      );
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to request KYC documents: $e'));
    }
  }
}
