import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../data/product_application_repository.dart';
import '../data/kyc_admin_repository.dart';
import '../data/audit_log_service.dart';
import '../domain/product_application.dart';
import '../domain/audit_log.dart';
import 'admin_auth_provider.dart';

part 'admin_data_providers.g.dart';

// ──────────────────────────────────────────
// Repositories
// ──────────────────────────────────────────

@riverpod
ProductApplicationRepository productApplicationRepository(
    ProductApplicationRepositoryRef ref) {
  return ProductApplicationRepository();
}

@riverpod
KycAdminRepository kycAdminRepository(KycAdminRepositoryRef ref) {
  return KycAdminRepository();
}

@riverpod
AuditLogService auditLogService(AuditLogServiceRef ref) {
  return AuditLogService();
}

// ──────────────────────────────────────────
// Product Applications Streams
// ──────────────────────────────────────────

@riverpod
Stream<List<ProductApplication>> productApplicationsByStatus(
  ProductApplicationsByStatusRef ref,
  ApplicationStatus status,
) {
  return ref
      .watch(productApplicationRepositoryProvider)
      .watchByStatus(status);
}

@riverpod
Stream<List<ProductApplication>> allProductApplications(
    AllProductApplicationsRef ref) {
  return ref.watch(productApplicationRepositoryProvider).watchAll();
}

// ──────────────────────────────────────────
// KYC Streams
// ──────────────────────────────────────────

@riverpod
Stream<List<Map<String, dynamic>>> kycByStatus(
    KycByStatusRef ref, String status) {
  return ref.watch(kycAdminRepositoryProvider).watchKycByStatus(status);
}

@riverpod
Stream<List<Map<String, dynamic>>> allKycRecords(AllKycRecordsRef ref) {
  return ref.watch(kycAdminRepositoryProvider).watchAllKyc();
}

// ──────────────────────────────────────────
// Audit Logs Stream
// ──────────────────────────────────────────

@riverpod
Stream<List<AuditLog>> auditLogs(AuditLogsRef ref, {String? adminId, String? targetUserId}) {
  return ref.watch(auditLogServiceProvider).watchAuditLogs(
        adminId: adminId,
        targetUserId: targetUserId,
      );
}

// ──────────────────────────────────────────
// Admin Dashboard Stats
// ──────────────────────────────────────────

@riverpod
Future<Map<String, int>> adminDashboardStats(
    AdminDashboardStatsRef ref) async {
  final pending = await ref
      .watch(productApplicationRepositoryProvider)
      .watchByStatus(ApplicationStatus.pending)
      .first;
  final underReview = await ref
      .watch(productApplicationRepositoryProvider)
      .watchByStatus(ApplicationStatus.underReview)
      .first;
  final kycPending = await ref
      .watch(kycAdminRepositoryProvider)
      .watchKycByStatus('pending')
      .first;

  return {
    'pendingApplications': pending.length,
    'underReviewApplications': underReview.length,
    'pendingKyc': kycPending.length,
  };
}

// ──────────────────────────────────────────
// Application Actions Controller
// ──────────────────────────────────────────

@riverpod
class ApplicationActionsController
    extends _$ApplicationActionsController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> approve({
    required String applicationId,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final admin = ref.read(adminAuthNotifierProvider).value;
    if (admin == null) {
      state = AsyncValue.error('Not authenticated as admin', StackTrace.current);
      return;
    }
    final result = await ref
        .read(productApplicationRepositoryProvider)
        .approveApplication(
          applicationId: applicationId,
          admin: admin,
          notes: notes,
        );
    state = result.match(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }

  Future<void> reject({
    required String applicationId,
    required String reason,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final admin = ref.read(adminAuthNotifierProvider).value;
    if (admin == null) {
      state = AsyncValue.error('Not authenticated as admin', StackTrace.current);
      return;
    }
    final result = await ref
        .read(productApplicationRepositoryProvider)
        .rejectApplication(
          applicationId: applicationId,
          admin: admin,
          reason: reason,
          notes: notes,
        );
    state = result.match(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }

  Future<void> requestMoreInfo({
    required String applicationId,
    required List<String> requestedDocuments,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final admin = ref.read(adminAuthNotifierProvider).value;
    if (admin == null) {
      state = AsyncValue.error('Not authenticated as admin', StackTrace.current);
      return;
    }
    final result = await ref
        .read(productApplicationRepositoryProvider)
        .requestMoreInfo(
          applicationId: applicationId,
          admin: admin,
          requestedDocuments: requestedDocuments,
          notes: notes,
        );
    state = result.match(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }
}

// ──────────────────────────────────────────
// KYC Actions Controller
// ──────────────────────────────────────────

@riverpod
class KycActionsController extends _$KycActionsController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> approveKyc({
    required String kycId,
    required String userId,
    required String userFullName,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final admin = ref.read(adminAuthNotifierProvider).value;
    if (admin == null) {
      state = AsyncValue.error('Not authenticated as admin', StackTrace.current);
      return;
    }
    final result = await ref.read(kycAdminRepositoryProvider).approveKyc(
          kycId: kycId,
          userId: userId,
          userFullName: userFullName,
          admin: admin,
          notes: notes,
        );
    state = result.match(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }

  Future<void> rejectKyc({
    required String kycId,
    required String userId,
    required String userFullName,
    required String reason,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final admin = ref.read(adminAuthNotifierProvider).value;
    if (admin == null) {
      state = AsyncValue.error('Not authenticated as admin', StackTrace.current);
      return;
    }
    final result = await ref.read(kycAdminRepositoryProvider).rejectKyc(
          kycId: kycId,
          userId: userId,
          userFullName: userFullName,
          admin: admin,
          reason: reason,
          notes: notes,
        );
    state = result.match(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }
}
