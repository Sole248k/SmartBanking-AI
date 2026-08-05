// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_lock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionLockControllerHash() =>
    r'29164de228858f7ee8d6c2348b6d7ac2e3f8bd57';

/// In-memory state for overall app session lock.
/// On app launch or browser refresh, initial state is `true` (locked).
///
/// Copied from [SessionLockController].
@ProviderFor(SessionLockController)
final sessionLockControllerProvider =
    AutoDisposeNotifierProvider<SessionLockController, bool>.internal(
  SessionLockController.new,
  name: r'sessionLockControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionLockControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionLockController = AutoDisposeNotifier<bool>;
String _$cardAuthSessionControllerHash() =>
    r'd039273e8172acb20640921e066a303a44a63ad4';

/// See also [CardAuthSessionController].
@ProviderFor(CardAuthSessionController)
final cardAuthSessionControllerProvider = AutoDisposeNotifierProvider<
    CardAuthSessionController, CardAuthSession>.internal(
  CardAuthSessionController.new,
  name: r'cardAuthSessionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cardAuthSessionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CardAuthSessionController = AutoDisposeNotifier<CardAuthSession>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
