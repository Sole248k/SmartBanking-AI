// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productApplicationRepositoryHash() =>
    r'ed947564de20bd8dcd85b6c92c4a294cc1eb4a8d';

/// See also [productApplicationRepository].
@ProviderFor(productApplicationRepository)
final productApplicationRepositoryProvider =
    AutoDisposeProvider<ProductApplicationRepository>.internal(
  productApplicationRepository,
  name: r'productApplicationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productApplicationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProductApplicationRepositoryRef
    = AutoDisposeProviderRef<ProductApplicationRepository>;
String _$kycAdminRepositoryHash() =>
    r'e45e121714c4925a49d5e8009a3ccff2d961c505';

/// See also [kycAdminRepository].
@ProviderFor(kycAdminRepository)
final kycAdminRepositoryProvider =
    AutoDisposeProvider<KycAdminRepository>.internal(
  kycAdminRepository,
  name: r'kycAdminRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycAdminRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef KycAdminRepositoryRef = AutoDisposeProviderRef<KycAdminRepository>;
String _$auditLogServiceHash() => r'a26d79630fe95b6dcd98d340abf4322d67d89f77';

/// See also [auditLogService].
@ProviderFor(auditLogService)
final auditLogServiceProvider = AutoDisposeProvider<AuditLogService>.internal(
  auditLogService,
  name: r'auditLogServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$auditLogServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuditLogServiceRef = AutoDisposeProviderRef<AuditLogService>;
String _$productApplicationsByStatusHash() =>
    r'3702cb04543d1778660adb826de271efb522e020';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [productApplicationsByStatus].
@ProviderFor(productApplicationsByStatus)
const productApplicationsByStatusProvider = ProductApplicationsByStatusFamily();

/// See also [productApplicationsByStatus].
class ProductApplicationsByStatusFamily
    extends Family<AsyncValue<List<ProductApplication>>> {
  /// See also [productApplicationsByStatus].
  const ProductApplicationsByStatusFamily();

  /// See also [productApplicationsByStatus].
  ProductApplicationsByStatusProvider call(
    ApplicationStatus status,
  ) {
    return ProductApplicationsByStatusProvider(
      status,
    );
  }

  @override
  ProductApplicationsByStatusProvider getProviderOverride(
    covariant ProductApplicationsByStatusProvider provider,
  ) {
    return call(
      provider.status,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productApplicationsByStatusProvider';
}

/// See also [productApplicationsByStatus].
class ProductApplicationsByStatusProvider
    extends AutoDisposeStreamProvider<List<ProductApplication>> {
  /// See also [productApplicationsByStatus].
  ProductApplicationsByStatusProvider(
    ApplicationStatus status,
  ) : this._internal(
          (ref) => productApplicationsByStatus(
            ref as ProductApplicationsByStatusRef,
            status,
          ),
          from: productApplicationsByStatusProvider,
          name: r'productApplicationsByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productApplicationsByStatusHash,
          dependencies: ProductApplicationsByStatusFamily._dependencies,
          allTransitiveDependencies:
              ProductApplicationsByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  ProductApplicationsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final ApplicationStatus status;

  @override
  Override overrideWith(
    Stream<List<ProductApplication>> Function(
            ProductApplicationsByStatusRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductApplicationsByStatusProvider._internal(
        (ref) => create(ref as ProductApplicationsByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ProductApplication>> createElement() {
    return _ProductApplicationsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductApplicationsByStatusProvider &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProductApplicationsByStatusRef
    on AutoDisposeStreamProviderRef<List<ProductApplication>> {
  /// The parameter `status` of this provider.
  ApplicationStatus get status;
}

class _ProductApplicationsByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<ProductApplication>>
    with ProductApplicationsByStatusRef {
  _ProductApplicationsByStatusProviderElement(super.provider);

  @override
  ApplicationStatus get status =>
      (origin as ProductApplicationsByStatusProvider).status;
}

String _$allProductApplicationsHash() =>
    r'255ff610602a668f9300a40a23668adfe4352b3a';

/// See also [allProductApplications].
@ProviderFor(allProductApplications)
final allProductApplicationsProvider =
    AutoDisposeStreamProvider<List<ProductApplication>>.internal(
  allProductApplications,
  name: r'allProductApplicationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allProductApplicationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllProductApplicationsRef
    = AutoDisposeStreamProviderRef<List<ProductApplication>>;
String _$kycByStatusHash() => r'b487fa349feb764adca2cd4b999588b79889eaa5';

/// See also [kycByStatus].
@ProviderFor(kycByStatus)
const kycByStatusProvider = KycByStatusFamily();

/// See also [kycByStatus].
class KycByStatusFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [kycByStatus].
  const KycByStatusFamily();

  /// See also [kycByStatus].
  KycByStatusProvider call(
    String status,
  ) {
    return KycByStatusProvider(
      status,
    );
  }

  @override
  KycByStatusProvider getProviderOverride(
    covariant KycByStatusProvider provider,
  ) {
    return call(
      provider.status,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'kycByStatusProvider';
}

/// See also [kycByStatus].
class KycByStatusProvider
    extends AutoDisposeStreamProvider<List<Map<String, dynamic>>> {
  /// See also [kycByStatus].
  KycByStatusProvider(
    String status,
  ) : this._internal(
          (ref) => kycByStatus(
            ref as KycByStatusRef,
            status,
          ),
          from: kycByStatusProvider,
          name: r'kycByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$kycByStatusHash,
          dependencies: KycByStatusFamily._dependencies,
          allTransitiveDependencies:
              KycByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  KycByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String status;

  @override
  Override overrideWith(
    Stream<List<Map<String, dynamic>>> Function(KycByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: KycByStatusProvider._internal(
        (ref) => create(ref as KycByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Map<String, dynamic>>> createElement() {
    return _KycByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is KycByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin KycByStatusRef
    on AutoDisposeStreamProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `status` of this provider.
  String get status;
}

class _KycByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<Map<String, dynamic>>>
    with KycByStatusRef {
  _KycByStatusProviderElement(super.provider);

  @override
  String get status => (origin as KycByStatusProvider).status;
}

String _$allKycRecordsHash() => r'e81554b82e530c2370e83fc253796c14766e57d2';

/// See also [allKycRecords].
@ProviderFor(allKycRecords)
final allKycRecordsProvider =
    AutoDisposeStreamProvider<List<Map<String, dynamic>>>.internal(
  allKycRecords,
  name: r'allKycRecordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allKycRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllKycRecordsRef
    = AutoDisposeStreamProviderRef<List<Map<String, dynamic>>>;
String _$auditLogsHash() => r'4d40d1c5ec3a6d6869fb31f5eb33477fa6471cd6';

/// See also [auditLogs].
@ProviderFor(auditLogs)
const auditLogsProvider = AuditLogsFamily();

/// See also [auditLogs].
class AuditLogsFamily extends Family<AsyncValue<List<AuditLog>>> {
  /// See also [auditLogs].
  const AuditLogsFamily();

  /// See also [auditLogs].
  AuditLogsProvider call({
    String? adminId,
    String? targetUserId,
  }) {
    return AuditLogsProvider(
      adminId: adminId,
      targetUserId: targetUserId,
    );
  }

  @override
  AuditLogsProvider getProviderOverride(
    covariant AuditLogsProvider provider,
  ) {
    return call(
      adminId: provider.adminId,
      targetUserId: provider.targetUserId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'auditLogsProvider';
}

/// See also [auditLogs].
class AuditLogsProvider extends AutoDisposeStreamProvider<List<AuditLog>> {
  /// See also [auditLogs].
  AuditLogsProvider({
    String? adminId,
    String? targetUserId,
  }) : this._internal(
          (ref) => auditLogs(
            ref as AuditLogsRef,
            adminId: adminId,
            targetUserId: targetUserId,
          ),
          from: auditLogsProvider,
          name: r'auditLogsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$auditLogsHash,
          dependencies: AuditLogsFamily._dependencies,
          allTransitiveDependencies: AuditLogsFamily._allTransitiveDependencies,
          adminId: adminId,
          targetUserId: targetUserId,
        );

  AuditLogsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.adminId,
    required this.targetUserId,
  }) : super.internal();

  final String? adminId;
  final String? targetUserId;

  @override
  Override overrideWith(
    Stream<List<AuditLog>> Function(AuditLogsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AuditLogsProvider._internal(
        (ref) => create(ref as AuditLogsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        adminId: adminId,
        targetUserId: targetUserId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AuditLog>> createElement() {
    return _AuditLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuditLogsProvider &&
        other.adminId == adminId &&
        other.targetUserId == targetUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, adminId.hashCode);
    hash = _SystemHash.combine(hash, targetUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AuditLogsRef on AutoDisposeStreamProviderRef<List<AuditLog>> {
  /// The parameter `adminId` of this provider.
  String? get adminId;

  /// The parameter `targetUserId` of this provider.
  String? get targetUserId;
}

class _AuditLogsProviderElement
    extends AutoDisposeStreamProviderElement<List<AuditLog>> with AuditLogsRef {
  _AuditLogsProviderElement(super.provider);

  @override
  String? get adminId => (origin as AuditLogsProvider).adminId;
  @override
  String? get targetUserId => (origin as AuditLogsProvider).targetUserId;
}

String _$adminDashboardStatsHash() =>
    r'3a28d18eab966ab7e5ae12d416be8c802f7d77e8';

/// See also [adminDashboardStats].
@ProviderFor(adminDashboardStats)
final adminDashboardStatsProvider =
    AutoDisposeFutureProvider<Map<String, int>>.internal(
  adminDashboardStats,
  name: r'adminDashboardStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminDashboardStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AdminDashboardStatsRef = AutoDisposeFutureProviderRef<Map<String, int>>;
String _$applicationActionsControllerHash() =>
    r'd22be1bd498ca9d7d9b8b3156de7b7800d034ecb';

/// See also [ApplicationActionsController].
@ProviderFor(ApplicationActionsController)
final applicationActionsControllerProvider = AutoDisposeNotifierProvider<
    ApplicationActionsController, AsyncValue<void>>.internal(
  ApplicationActionsController.new,
  name: r'applicationActionsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$applicationActionsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ApplicationActionsController = AutoDisposeNotifier<AsyncValue<void>>;
String _$kycActionsControllerHash() =>
    r'd7f97940d82b67d02f3771ba6216579d4d57e4d1';

/// See also [KycActionsController].
@ProviderFor(KycActionsController)
final kycActionsControllerProvider = AutoDisposeNotifierProvider<
    KycActionsController, AsyncValue<void>>.internal(
  KycActionsController.new,
  name: r'kycActionsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycActionsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KycActionsController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
