// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiRepositoryHash() => r'e6aac4aa62c05181934488d1a84444ad633ec209';

/// See also [aiRepository].
@ProviderFor(aiRepository)
final aiRepositoryProvider = AutoDisposeProvider<AiRepository>.internal(
  aiRepository,
  name: r'aiRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AiRepositoryRef = AutoDisposeProviderRef<AiRepository>;
String _$aiChatControllerHash() => r'43a9c9e6085b2546c1abff8bc0cd8369118f3e4c';

/// See also [AiChatController].
@ProviderFor(AiChatController)
final aiChatControllerProvider =
    AutoDisposeNotifierProvider<AiChatController, List<ChatMessage>>.internal(
  AiChatController.new,
  name: r'aiChatControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiChatControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AiChatController = AutoDisposeNotifier<List<ChatMessage>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
