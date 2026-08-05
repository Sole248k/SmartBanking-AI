// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletRepositoryHash() => r'312be6394fd213e71f5c4f562712f2d484a7f071';

/// See also [walletRepository].
@ProviderFor(walletRepository)
final walletRepositoryProvider = AutoDisposeProvider<WalletRepository>.internal(
  walletRepository,
  name: r'walletRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WalletRepositoryRef = AutoDisposeProviderRef<WalletRepository>;
String _$walletControllerHash() => r'90b5255421860a5c3363003d951c80932618bb2e';

/// See also [WalletController].
@ProviderFor(WalletController)
final walletControllerProvider =
    AutoDisposeStreamNotifierProvider<WalletController, Wallet>.internal(
  WalletController.new,
  name: r'walletControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WalletController = AutoDisposeStreamNotifier<Wallet>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
