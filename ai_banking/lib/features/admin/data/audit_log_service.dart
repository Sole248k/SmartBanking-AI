import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/audit_log.dart';
import '../domain/admin_user.dart';

/// Service for writing audit log entries to Firestore.
/// Used by all admin actions that require governance tracking.
class AuditLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'audit_logs';

  Future<void> log({
    required AdminUser admin,
    required AuditAction action,
    String? targetUserId,
    String? targetUserName,
    String? targetAdminId,
    String? previousStatus,
    String? newStatus,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    final entry = AuditLog(
      id: '',
      adminId: admin.uid,
      adminName: admin.fullName,
      adminRole: admin.role.name,
      action: action,
      timestamp: DateTime.now(),
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      targetAdminId: targetAdminId,
      previousStatus: previousStatus,
      newStatus: newStatus,
      notes: notes,
      metadata: metadata,
    );
    await _firestore.collection(_collection).add(entry.toFirestore());
  }

  Stream<List<AuditLog>> watchAuditLogs({
    String? adminId,
    String? targetUserId,
    int limit = 100,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (adminId != null) {
      query = query.where('adminId', isEqualTo: adminId);
    }
    if (targetUserId != null) {
      query = query.where('targetUserId', isEqualTo: targetUserId);
    }

    return query.snapshots().map(
          (snap) => snap.docs.map(AuditLog.fromFirestore).toList(),
        );
  }
}
