import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/firestore_profile_repository_impl.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return FirestoreProfileRepositoryImpl();
}

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<UserProfile> build() async {
    // Use authNotifierProvider (not the raw stream) so we get the fully
    // resolved user AFTER provisioning has completed during registration.
    final authAsync = ref.watch(authNotifierProvider);
    final user = authAsync.value;

    if (user == null) {
      return const UserProfile(id: '', fullName: 'SmartBank User', email: '');
    }

    // Retry up to 3 times with a short delay to handle the race condition
    // where the Firestore profile document is still being written after
    // a fresh registration.
    for (int attempt = 0; attempt < 3; attempt++) {
      final result = await ref.read(profileRepositoryProvider).getProfile();
      final profile = result.getRight().toNullable();
      if (profile != null) return profile;
      if (attempt < 2) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    // Fallback: build a minimal profile from the auth user so the UI
    // always shows real data even if Firestore is slow.
    return UserProfile(id: user.id, fullName: user.fullName, email: user.email);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> toggleBiometrics(bool enabled) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;
    await ref.read(profileRepositoryProvider).toggleBiometrics(enabled);
    state = AsyncData(currentProfile.copyWith(isBiometricEnabled: enabled));
  }

  Future<void> toggleNotifications(bool enabled) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;
    final updated = currentProfile.copyWith(pushNotificationsEnabled: enabled);
    await ref.read(profileRepositoryProvider).updateProfile(updated);
    state = AsyncData(updated);
  }

  Future<void> approveKyc() async {
    final currentProfile = state.value;
    if (currentProfile == null) return;
    await ref.read(profileRepositoryProvider).updateKycStatus('Approved');
    state = AsyncData(currentProfile.copyWith(kycStatus: 'Approved'));
  }
}

