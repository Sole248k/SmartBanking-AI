// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kycRepositoryHash() => r'd6e5dfd2984751e681d239994ca57ad514c52318';

/// See also [kycRepository].
@ProviderFor(kycRepository)
final kycRepositoryProvider = AutoDisposeProvider<KycRepository>.internal(
  kycRepository,
  name: r'kycRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef KycRepositoryRef = AutoDisposeProviderRef<KycRepository>;
String _$kycControllerHash() => r'961a05f09c4aa933c975b2b91cbfabf20ace275c';

/// See also [KycController].
@ProviderFor(KycController)
final kycControllerProvider =
    AutoDisposeNotifierProvider<KycController, KycState>.internal(
  KycController.new,
  name: r'kycControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KycController = AutoDisposeNotifier<KycState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
