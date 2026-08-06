import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles available in the Admin Portal.
enum AdminRole {
  superAdmin,
  opsAdmin,
  complianceOfficer;

  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.opsAdmin:
        return 'Operations Admin';
      case AdminRole.complianceOfficer:
        return 'Compliance Officer';
    }
  }

  static AdminRole fromString(String value) {
    switch (value) {
      case 'superAdmin':
        return AdminRole.superAdmin;
      case 'opsAdmin':
        return AdminRole.opsAdmin;
      case 'complianceOfficer':
        return AdminRole.complianceOfficer;
      default:
        return AdminRole.opsAdmin;
    }
  }
}

/// Represents an admin account stored in the `admin_users` Firestore collection.
class AdminUser {
  const AdminUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.lastLogin,
  });

  final String uid;
  final String email;
  final String fullName;
  final AdminRole role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  /// Whether this admin can manage other admin accounts.
  bool get canManageAdmins => role == AdminRole.superAdmin;

  /// Whether this admin can review KYC submissions.
  bool get canReviewKyc =>
      role == AdminRole.superAdmin ||
      role == AdminRole.complianceOfficer;

  /// Whether this admin can review product applications.
  bool get canReviewApplications =>
      role == AdminRole.superAdmin || role == AdminRole.opsAdmin;

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      role: AdminRole.fromString(data['role'] as String? ?? 'opsAdmin'),
      isActive: data['isActive'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role.name,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  AdminUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    AdminRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AdminUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
