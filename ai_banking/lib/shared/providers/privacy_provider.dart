import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/storage/storage_service.dart';

part 'privacy_provider.g.dart';

@riverpod
class PrivacyMode extends _$PrivacyMode {
  @override
  bool build() {
    _loadPrivacy();
    return false;
  }

  Future<void> _loadPrivacy() async {
    state = await ref.read(storageServiceProvider).isPrivacyMode();
  }

  Future<void> toggle() async {
    state = !state;
    await ref.read(storageServiceProvider).savePrivacyMode(state);
  }
}
