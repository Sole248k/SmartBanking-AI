// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsRepositoryHash() =>
    r'510069cf117c487568d0ae73f4d5ec007a6a5d5c';

/// See also [analyticsRepository].
@ProviderFor(analyticsRepository)
final analyticsRepositoryProvider =
    AutoDisposeProvider<AnalyticsRepository>.internal(
  analyticsRepository,
  name: r'analyticsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AnalyticsRepositoryRef = AutoDisposeProviderRef<AnalyticsRepository>;
String _$spendingReportControllerHash() =>
    r'5772b8e186082ee3194805f67634712c0c29345a';

/// See also [SpendingReportController].
@ProviderFor(SpendingReportController)
final spendingReportControllerProvider = AutoDisposeAsyncNotifierProvider<
    SpendingReportController, SpendingReport>.internal(
  SpendingReportController.new,
  name: r'spendingReportControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$spendingReportControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpendingReportController = AutoDisposeAsyncNotifier<SpendingReport>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
