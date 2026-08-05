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
String _$walletControllerHash() => r'6bc014273a2205c38894a3bfb674a5e6fd80e2b2';

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
