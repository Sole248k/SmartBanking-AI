import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an audit log entry written whenever an admin takes a governed action.
class AuditLog {
  const AuditLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.adminRole,
    required this.action,
    required this.timestamp,
    this.targetUserId,
    this.targetUserName,
    this.targetAdminId,
    this.previousStatus,
    this.newStatus,
    this.notes,
    this.metadata,
  });

  final String id;
  final String adminId;
  final String adminName;
  final String adminRole;
  final AuditAction action;
  final DateTime timestamp;
  final String? targetUserId;
  final String? targetUserName;
  final String? targetAdminId;
  final String? previousStatus;
  final String? newStatus;
  final String? notes;
  final Map<String, dynamic>? metadata;

  factory AuditLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLog(
      id: doc.id,
      adminId: data['adminId'] as String? ?? '',
      adminName: data['adminName'] as String? ?? '',
      adminRole: data['adminRole'] as String? ?? '',
      action: AuditAction.fromString(data['action'] as String? ?? ''),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetUserId: data['targetUserId'] as String?,
      targetUserName: data['targetUserName'] as String?,
      targetAdminId: data['targetAdminId'] as String?,
      previousStatus: data['previousStatus'] as String?,
      newStatus: data['newStatus'] as String?,
      notes: data['notes'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'adminId': adminId,
      'adminName': adminName,
      'adminRole': adminRole,
      'action': action.value,
      'timestamp': FieldValue.serverTimestamp(),
      if (targetUserId != null) 'targetUserId': targetUserId,
      if (targetUserName != null) 'targetUserName': targetUserName,
      if (targetAdminId != null) 'targetAdminId': targetAdminId,
      if (previousStatus != null) 'previousStatus': previousStatus,
      if (newStatus != null) 'newStatus': newStatus,
      if (notes != null) 'notes': notes,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

enum AuditAction {
  // KYC actions
  approvedKyc('approvedKyc', 'Approved KYC'),
  rejectedKyc('rejectedKyc', 'Rejected KYC'),
  requestedKycDocs('requestedKycDocs', 'Requested KYC Documents'),

  // Product application actions
  approvedApplication('approvedApplication', 'Approved Application'),
  rejectedApplication('rejectedApplication', 'Rejected Application'),
  requestedMoreInfo('requestedMoreInfo', 'Requested More Info'),
  assignedApplication('assignedApplication', 'Assigned Application'),
  reviewedApplication('reviewedApplication', 'Reviewed Application'),

  // Admin management
  createdAdmin('createdAdmin', 'Created Admin Account'),
  updatedAdmin('updatedAdmin', 'Updated Admin Account'),
  suspendedAdmin('suspendedAdmin', 'Suspended Admin Account'),
  deletedAdmin('deletedAdmin', 'Deleted Admin Account'),

  // Generic
  viewedUser('viewedUser', 'Viewed User Profile'),
  addedNote('addedNote', 'Added Internal Note'),
  unknown('unknown', 'Unknown Action');

  const AuditAction(this.value, this.displayName);
  final String value;
  final String displayName;

  static AuditAction fromString(String value) {
    return AuditAction.values.firstWhere(
      (a) => a.value == value,
      orElse: () => AuditAction.unknown,
    );
  }
}
