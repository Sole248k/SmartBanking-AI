import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../domain/admin_user.dart';
import '../domain/admin_auth_repository.dart';
import '../domain/audit_log.dart';

class AdminAuthRepositoryImpl implements AdminAuthRepository {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _adminCollection = 'admin_users';
  static const String _auditCollection = 'audit_logs';

  // ──────────────────────────────────────────
  // Auth
  // ──────────────────────────────────────────

  @override
  Future<Either<Failure, AdminUser>> loginAdmin(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return left(const AuthFailure('Authentication failed.'));
      }

      // Verify this Firebase UID has an admin_users document and is active
      final adminDoc =
          await _firestore.collection(_adminCollection).doc(uid).get();
      if (!adminDoc.exists) {
        await _auth.signOut();
        return left(const AuthFailure(
            'Access denied. This account is not an admin account.'));
      }

      final adminUser = AdminUser.fromFirestore(adminDoc);
      if (!adminUser.isActive) {
        await _auth.signOut();
        return left(
            const AuthFailure('This admin account has been suspended.'));
      }

      // Update last login timestamp
      await _firestore
          .collection(_adminCollection)
          .doc(uid)
          .update({'lastLogin': FieldValue.serverTimestamp()});

      return right(adminUser);
    } on firebase.FirebaseAuthException catch (e) {
      return left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return left(AuthFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<void> logoutAdmin() async {
    await _auth.signOut();
  }

  @override
  Future<Either<Failure, AdminUser?>> getCurrentAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return right(null);

      final doc =
          await _firestore.collection(_adminCollection).doc(user.uid).get();
      if (!doc.exists) return right(null);

      final adminUser = AdminUser.fromFirestore(doc);
      if (!adminUser.isActive) return right(null);

      return right(adminUser);
    } catch (e) {
      return left(ServerFailure('Failed to fetch admin: ${e.toString()}'));
    }
  }

  @override
  Stream<AdminUser?> adminAuthStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc =
            await _firestore.collection(_adminCollection).doc(user.uid).get();
        if (!doc.exists) return null;
        final adminUser = AdminUser.fromFirestore(doc);
        return adminUser.isActive ? adminUser : null;
      } catch (_) {
        return null;
      }
    });
  }

  // ──────────────────────────────────────────
  // Admin Management (Super Admin only)
  // ──────────────────────────────────────────

  @override
  Future<Either<Failure, AdminUser>> createAdmin({
    required String email,
    required String password,
    required String fullName,
    required AdminRole role,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return left(const AuthFailure('Failed to create admin account.'));
      }

      final newAdmin = AdminUser(
        uid: uid,
        email: email,
        fullName: fullName,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Write admin_users document
      await _firestore
          .collection(_adminCollection)
          .doc(uid)
          .set(newAdmin.toFirestore());

      return right(newAdmin);
    } on firebase.FirebaseAuthException catch (e) {
      return left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return left(ServerFailure('Failed to create admin: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAdmin({
    required String adminUid,
    AdminRole? role,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (role != null) updates['role'] = role.name;
      if (isActive != null) updates['isActive'] = isActive;
      if (updates.isEmpty) return right(null);

      await _firestore
          .collection(_adminCollection)
          .doc(adminUid)
          .update(updates);
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to update admin: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAdmin(String adminUid) async {
    try {
      await _firestore.collection(_adminCollection).doc(adminUid).delete();
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to delete admin: ${e.toString()}'));
    }
  }

  @override
  Stream<List<AdminUser>> watchAllAdmins() {
    return _firestore
        .collection(_adminCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(AdminUser.fromFirestore).toList());
  }

  // ──────────────────────────────────────────
  // Audit Logging
  // ──────────────────────────────────────────

  Future<void> writeAuditLog(AuditLog log) async {
    await _firestore.collection(_auditCollection).add(log.toFirestore());
  }

  // ──────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No admin account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
