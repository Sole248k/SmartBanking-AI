// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transferRepositoryHash() =>
    r'35868a51fad18013103d6643b5d9cf17eede7357';

/// See also [transferRepository].
@ProviderFor(transferRepository)
final transferRepositoryProvider =
    AutoDisposeProvider<TransferRepository>.internal(
  transferRepository,
  name: r'transferRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transferRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransferRepositoryRef = AutoDisposeProviderRef<TransferRepository>;
String _$beneficiariesHash() => r'135272453fdccfaf33afc0b1bddfe5637fdad44f';

/// See also [beneficiaries].
@ProviderFor(beneficiaries)
final beneficiariesProvider =
    AutoDisposeStreamProvider<List<Beneficiary>>.internal(
  beneficiaries,
  name: r'beneficiariesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$beneficiariesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BeneficiariesRef = AutoDisposeStreamProviderRef<List<Beneficiary>>;
String _$transferControllerHash() =>
    r'678db45739e36a031a30073afaf642eff27974bb';

/// See also [TransferController].
@ProviderFor(TransferController)
final transferControllerProvider =
    AutoDisposeNotifierProvider<TransferController, TransferState>.internal(
  TransferController.new,
  name: r'transferControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transferControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransferController = AutoDisposeNotifier<TransferState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
