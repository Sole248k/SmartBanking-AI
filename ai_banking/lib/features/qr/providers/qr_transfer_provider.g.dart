// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_transfer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$qrTransferNotifierHash() =>
    r'3183906cb177862c5c0e7be4a40994fe2f2f780b';

/// Manages state for the self-contained QR transfer flow.
///
/// This is intentionally separate from [TransferController] so QR transfers
/// have isolated state and don't bleed into or from the manual Send Money flow.
///
/// Copied from [QrTransferNotifier].
@ProviderFor(QrTransferNotifier)
final qrTransferNotifierProvider =
    AutoDisposeNotifierProvider<QrTransferNotifier, QrTransferState>.internal(
  QrTransferNotifier.new,
  name: r'qrTransferNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$qrTransferNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QrTransferNotifier = AutoDisposeNotifier<QrTransferState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
