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
    // Watch auth state to automatically trigger rebuild on login/logout
    final authState = ref.watch(authStateChangesProvider);
    
    final user = authState.value;
    if (user == null) {
      // Return a guest profile instead of throwing or returning null
      return const UserProfile(
        id: '',
        fullName: 'SmartBank User',
        email: '',
      );
    }

    final result = await ref.watch(profileRepositoryProvider).getProfile();
    return result.match(
      (failure) => const UserProfile(
        id: '',
        fullName: 'SmartBank User',
        email: '',
      ),
      (profile) => profile,
    );
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
}
