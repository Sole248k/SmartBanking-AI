// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminAuthRepositoryHash() =>
    r'5261057498415b7a9dec0c60caaaeaa873f40e33';

/// See also [adminAuthRepository].
@ProviderFor(adminAuthRepository)
final adminAuthRepositoryProvider =
    AutoDisposeProvider<AdminAuthRepository>.internal(
  adminAuthRepository,
  name: r'adminAuthRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminAuthRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AdminAuthRepositoryRef = AutoDisposeProviderRef<AdminAuthRepository>;
String _$adminAuthStateChangesHash() =>
    r'b770ae0167cd6ba5a0dac2033e67c45993b2538b';

/// See also [adminAuthStateChanges].
@ProviderFor(adminAuthStateChanges)
final adminAuthStateChangesProvider =
    AutoDisposeStreamProvider<AdminUser?>.internal(
  adminAuthStateChanges,
  name: r'adminAuthStateChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminAuthStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AdminAuthStateChangesRef = AutoDisposeStreamProviderRef<AdminUser?>;
String _$currentAdminRoleHash() => r'f728b444b755068df4df985df9703d94080e1ca7';

/// See also [currentAdminRole].
@ProviderFor(currentAdminRole)
final currentAdminRoleProvider = AutoDisposeProvider<AdminRole?>.internal(
  currentAdminRole,
  name: r'currentAdminRoleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAdminRoleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentAdminRoleRef = AutoDisposeProviderRef<AdminRole?>;
String _$allAdminsHash() => r'368043adfcac80f34eaada39eb4dc262ddb272ef';

/// See also [allAdmins].
@ProviderFor(allAdmins)
final allAdminsProvider = AutoDisposeStreamProvider<List<AdminUser>>.internal(
  allAdmins,
  name: r'allAdminsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allAdminsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllAdminsRef = AutoDisposeStreamProviderRef<List<AdminUser>>;
String _$adminAuthNotifierHash() => r'90df985ba2e08fd84a782388f9626b711e5a3c5b';

/// See also [AdminAuthNotifier].
@ProviderFor(AdminAuthNotifier)
final adminAuthNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AdminAuthNotifier, AdminUser?>.internal(
  AdminAuthNotifier.new,
  name: r'adminAuthNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminAuthNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminAuthNotifier = AutoDisposeAsyncNotifier<AdminUser?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
