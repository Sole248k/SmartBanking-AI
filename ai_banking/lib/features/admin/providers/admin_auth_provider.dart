import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/admin_auth_repository_impl.dart';
import '../domain/admin_auth_repository.dart';
import '../domain/admin_user.dart';

part 'admin_auth_provider.g.dart';

// ──────────────────────────────────────────
// Repository
// ──────────────────────────────────────────

@riverpod
AdminAuthRepository adminAuthRepository(AdminAuthRepositoryRef ref) {
  return AdminAuthRepositoryImpl();
}

// ──────────────────────────────────────────
// Auth State Stream
// ──────────────────────────────────────────

@riverpod
Stream<AdminUser?> adminAuthStateChanges(AdminAuthStateChangesRef ref) {
  return ref.watch(adminAuthRepositoryProvider).adminAuthStateChanges();
}

// ──────────────────────────────────────────
// Admin Auth Controller
// ──────────────────────────────────────────

@riverpod
class AdminAuthNotifier extends _$AdminAuthNotifier {
  @override
  FutureOr<AdminUser?> build() async {
    ref.listen(adminAuthStateChangesProvider, (previous, next) {
      if (next is AsyncData) {
        state = AsyncData(next.value);
      }
    });
    final result =
        await ref.read(adminAuthRepositoryProvider).getCurrentAdmin();
    return result.match((l) => null, (r) => r);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(adminAuthRepositoryProvider)
        .loginAdmin(email, password);
    state = result.match(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (adminUser) => AsyncValue.data(adminUser),
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(adminAuthRepositoryProvider).logoutAdmin();
    state = const AsyncValue.data(null);
  }
}

// ──────────────────────────────────────────
// Current Admin Role Convenience Provider
// ──────────────────────────────────────────

@riverpod
AdminRole? currentAdminRole(CurrentAdminRoleRef ref) {
  return ref.watch(adminAuthNotifierProvider).value?.role;
}

// ──────────────────────────────────────────
// All Admins Stream (Super Admin only)
// ──────────────────────────────────────────

@riverpod
Stream<List<AdminUser>> allAdmins(AllAdminsRef ref) {
  return ref.watch(adminAuthRepositoryProvider).watchAllAdmins();
}
