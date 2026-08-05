import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/storage/storage_service.dart';

part 'theme_provider.g.dart';

@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final isDark = await ref.read(storageServiceProvider).isDarkMode();
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final isDark = state == ThemeMode.dark;
    final newState = isDark ? ThemeMode.light : ThemeMode.dark;
    state = newState;
    await ref.read(storageServiceProvider).saveDarkMode(!isDark);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    if (mode != ThemeMode.system) {
      await ref.read(storageServiceProvider).saveDarkMode(mode == ThemeMode.dark);
    }
  }
}
