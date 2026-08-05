import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_service.g.dart';

class StorageService {
  
  StorageService(this._secureStorage);
  final FlutterSecureStorage _secureStorage;

  Future<void> init() async {
    await Hive.initFlutter();
  }

  // Secure storage for sensitive data (tokens)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // Theme preference
  Future<void> saveDarkMode(bool isDark) async {
    final box = await Hive.openBox('settings');
    await box.put('isDarkMode', isDark);
  }

  Future<bool?> isDarkMode() async {
    final box = await Hive.openBox('settings');
    return box.get('isDarkMode') as bool?;
  }

  // Privacy preference
  Future<void> savePrivacyMode(bool isPrivate) async {
    final box = await Hive.openBox('settings');
    await box.put('isPrivacyMode', isPrivate);
  }

  Future<bool> isPrivacyMode() async {
    final box = await Hive.openBox('settings');
    return box.get('isPrivacyMode', defaultValue: false) as bool;
  }
}

@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService(const FlutterSecureStorage());
}
