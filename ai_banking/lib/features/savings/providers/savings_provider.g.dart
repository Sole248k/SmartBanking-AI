// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$savingsRepositoryHash() => r'ee03dcbb7dd059ec8d92240be38ea2db5319ae58';

/// See also [savingsRepository].
@ProviderFor(savingsRepository)
final savingsRepositoryProvider =
    AutoDisposeProvider<SavingsRepository>.internal(
  savingsRepository,
  name: r'savingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SavingsRepositoryRef = AutoDisposeProviderRef<SavingsRepository>;
String _$savingsGoalsHash() => r'ab83b23f871ee19518cdad0814387d5e082f8f82';

/// See also [savingsGoals].
@ProviderFor(savingsGoals)
final savingsGoalsProvider =
    AutoDisposeStreamProvider<List<SavingsGoal>>.internal(
  savingsGoals,
  name: r'savingsGoalsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$savingsGoalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SavingsGoalsRef = AutoDisposeStreamProviderRef<List<SavingsGoal>>;
String _$savingsControllerHash() => r'ce6294ec418c70dbe44715a8f2c2d7993d2a81cb';

/// See also [SavingsController].
@ProviderFor(SavingsController)
final savingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<SavingsController, void>.internal(
  SavingsController.new,
  name: r'savingsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savingsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SavingsController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
