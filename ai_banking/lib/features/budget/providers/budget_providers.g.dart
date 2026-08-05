// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetRepositoryHash() => r'a8bd84be2a1819a3778d2920d7fcf7ea3bc9217a';

/// See also [budgetRepository].
@ProviderFor(budgetRepository)
final budgetRepositoryProvider = AutoDisposeProvider<BudgetRepository>.internal(
  budgetRepository,
  name: r'budgetRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BudgetRepositoryRef = AutoDisposeProviderRef<BudgetRepository>;
String _$budgetControllerHash() => r'b0c9a143afdb250ee378083cff3f3f68d0d8f623';

/// See also [BudgetController].
@ProviderFor(BudgetController)
final budgetControllerProvider =
    AutoDisposeStreamNotifierProvider<BudgetController, List<Budget>>.internal(
  BudgetController.new,
  name: r'budgetControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BudgetController = AutoDisposeStreamNotifier<List<Budget>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
