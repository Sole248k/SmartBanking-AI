import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../domain/product_application.dart';
import '../domain/admin_user.dart';
import '../domain/audit_log.dart';
import 'audit_log_service.dart';

class ProductApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _auditLog = AuditLogService();
  static const String _collection = 'product_applications';

  // ──────────────────────────────────────────
  // Streams
  // ──────────────────────────────────────────

  Stream<List<ProductApplication>> watchByStatus(ApplicationStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.value)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ProductApplication.fromFirestore).toList());
  }

  Stream<List<ProductApplication>> watchAll() {
    return _firestore
        .collection(_collection)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ProductApplication.fromFirestore).toList());
  }

  Stream<List<ProductApplication>> watchByUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ProductApplication.fromFirestore).toList());
  }

  // ──────────────────────────────────────────
  // Admin Actions
  // ──────────────────────────────────────────

  Future<Either<Failure, void>> approveApplication({
    required String applicationId,
    required AdminUser admin,
    String? notes,
  }) async {
    return _updateStatus(
      applicationId: applicationId,
      admin: admin,
      newStatus: ApplicationStatus.approved,
      auditAction: AuditAction.approvedApplication,
      notes: notes,
    );
  }

  Future<Either<Failure, void>> rejectApplication({
    required String applicationId,
    required AdminUser admin,
    required String reason,
    String? notes,
  }) async {
    try {
      await _firestore.collection(_collection).doc(applicationId).update({
        'status': ApplicationStatus.rejected.value,
        'rejectionReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': admin.uid,
        if (notes != null) 'internalNotes': notes,
      });
      // Write audit log
      final doc = await _firestore
          .collection(_collection)
          .doc(applicationId)
          .get();
      final app = ProductApplication.fromFirestore(doc);
      await _auditLog.log(
        admin: admin,
        action: AuditAction.rejectedApplication,
        targetUserId: app.userId,
        targetUserName: app.userFullName,
        previousStatus: ApplicationStatus.underReview.value,
        newStatus: ApplicationStatus.rejected.value,
        notes: notes,
        metadata: {'rejectionReason': reason, 'applicationId': applicationId},
      );
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to reject application: $e'));
    }
  }

  Future<Either<Failure, void>> requestMoreInfo({
    required String applicationId,
    required AdminUser admin,
    required List<String> requestedDocuments,
    String? notes,
  }) async {
    try {
      await _firestore.collection(_collection).doc(applicationId).update({
        'status': ApplicationStatus.moreInfoRequired.value,
        'requestedDocuments': requestedDocuments,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': admin.uid,
        if (notes != null) 'internalNotes': notes,
      });
      final doc = await _firestore
          .collection(_collection)
          .doc(applicationId)
          .get();
      final app = ProductApplication.fromFirestore(doc);
      await _auditLog.log(
        admin: admin,
        action: AuditAction.requestedMoreInfo,
        targetUserId: app.userId,
        targetUserName: app.userFullName,
        previousStatus: ApplicationStatus.underReview.value,
        newStatus: ApplicationStatus.moreInfoRequired.value,
        notes: notes,
        metadata: {
          'requestedDocuments': requestedDocuments,
          'applicationId': applicationId
        },
      );
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to request more info: $e'));
    }
  }

  Future<Either<Failure, void>> assignToAdmin({
    required String applicationId,
    required AdminUser assigningAdmin,
    required AdminUser assignedAdmin,
  }) async {
    try {
      await _firestore.collection(_collection).doc(applicationId).update({
        'assignedAdminId': assignedAdmin.uid,
        'assignedAdminName': assignedAdmin.fullName,
        'status': ApplicationStatus.underReview.value,
      });
      final doc = await _firestore
          .collection(_collection)
          .doc(applicationId)
          .get();
      final app = ProductApplication.fromFirestore(doc);
      await _auditLog.log(
        admin: assigningAdmin,
        action: AuditAction.assignedApplication,
        targetUserId: app.userId,
        targetUserName: app.userFullName,
        notes: 'Assigned to ${assignedAdmin.fullName}',
        metadata: {
          'assignedAdminId': assignedAdmin.uid,
          'assignedAdminName': assignedAdmin.fullName,
        },
      );
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to assign application: $e'));
    }
  }

  Future<Either<Failure, void>> addNote({
    required String applicationId,
    required AdminUser admin,
    required String note,
  }) async {
    try {
      await _firestore.collection(_collection).doc(applicationId).update({
        'internalNotes': note,
      });
      final doc = await _firestore
          .collection(_collection)
          .doc(applicationId)
          .get();
      final app = ProductApplication.fromFirestore(doc);
      await _auditLog.log(
        admin: admin,
        action: AuditAction.addedNote,
        targetUserId: app.userId,
        targetUserName: app.userFullName,
        notes: note,
      );
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to add note: $e'));
    }
  }

  // ──────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────

  Future<Either<Failure, void>> _updateStatus({
    required String applicationId,
    required AdminUser admin,
    required ApplicationStatus newStatus,
    required AuditAction auditAction,
    String? notes,
  }) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(applicationId)
          .get();
      if (!doc.exists) {
        return left(const ServerFailure('Application not found.'));
      }
      final app = ProductApplication.fromFirestore(doc);
      final previousStatus = app.status.value;

      await _firestore.collection(_collection).doc(applicationId).update({
        'status': newStatus.value,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': admin.uid,
        if (notes != null) 'internalNotes': notes,
      });

      await _auditLog.log(
        admin: admin,
        action: auditAction,
        targetUserId: app.userId,
        targetUserName: app.userFullName,
        previousStatus: previousStatus,
        newStatus: newStatus.value,
        notes: notes,
        metadata: {'applicationId': applicationId},
      );

      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to update application: $e'));
    }
  }
}
