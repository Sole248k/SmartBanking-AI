import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return FirebaseAuthRepositoryImpl();
}

@riverpod
Stream<AuthUser?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthUser?> build() async {
    // Keep state in sync with Firebase auth stream.
    // Using listenSelf so we don't miss the initial value.
    ref.listen(authStateChangesProvider, (previous, next) {
      if (next is AsyncData) {
        state = AsyncData(next.value);
      }
    });

    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    return user.match((l) => null, (r) => r);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).login(email, password);
    state = result.match(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> register(String email, String password, String fullName) async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).register(
          email: email,
          password: password,
          fullName: fullName,
        );
    state = result.match(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
    // After successful registration the profile document has just been
    // written by UserProvisioningService. Invalidate the profile so it
    // re-fetches with the retry logic instead of serving a stale null.
    if (state.hasValue && state.value != null) {
      ref.invalidate(authStateChangesProvider);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    state = result.match(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
}
