import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import 'admin_user.dart';

abstract class AdminAuthRepository {
  /// Sign in with email/password then verify admin_users Firestore document.
  Future<Either<Failure, AdminUser>> loginAdmin(String email, String password);

  /// Sign out the current admin.
  Future<void> logoutAdmin();

  /// Get the current admin user (null if not signed in or not an admin).
  Future<Either<Failure, AdminUser?>> getCurrentAdmin();

  /// Stream that emits the current admin (null if signed out).
  Stream<AdminUser?> adminAuthStateChanges();

  /// Create a new admin account (Super Admin only).
  Future<Either<Failure, AdminUser>> createAdmin({
    required String email,
    required String password,
    required String fullName,
    required AdminRole role,
  });

  /// Update an admin's role or active status (Super Admin only).
  Future<Either<Failure, void>> updateAdmin({
    required String adminUid,
    AdminRole? role,
    bool? isActive,
  });

  /// Permanently delete an admin account (Super Admin only).
  Future<Either<Failure, void>> deleteAdmin(String adminUid);

  /// Fetch all admin accounts.
  Stream<List<AdminUser>> watchAllAdmins();
}
