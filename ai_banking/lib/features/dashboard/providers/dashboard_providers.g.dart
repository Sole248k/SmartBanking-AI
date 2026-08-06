// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionRepositoryHash() =>
    r'3b6c5a7ca30995ab7c5d9a7ee8565a9bde264cfe';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider =
    AutoDisposeProvider<TransactionRepository>.internal(
  transactionRepository,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransactionRepositoryRef
    = AutoDisposeProviderRef<TransactionRepository>;
String _$dashboardAccountsHash() => r'0238beefe491c5eb4d7a2738ff492dc19b8b6b86';

/// See also [dashboardAccounts].
@ProviderFor(dashboardAccounts)
final dashboardAccountsProvider =
    AutoDisposeStreamProvider<List<Account>>.internal(
  dashboardAccounts,
  name: r'dashboardAccountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DashboardAccountsRef = AutoDisposeStreamProviderRef<List<Account>>;
String _$recentTransactionsHash() =>
    r'c99d6952e431ce6e42f6fe1efde82b58509bb9a9';

/// See also [recentTransactions].
@ProviderFor(recentTransactions)
final recentTransactionsProvider =
    AutoDisposeStreamProvider<List<Transaction>>.internal(
  recentTransactions,
  name: r'recentTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentTransactionsRef = AutoDisposeStreamProviderRef<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
