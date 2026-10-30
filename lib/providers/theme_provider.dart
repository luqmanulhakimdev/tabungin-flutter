import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_colors.dart';

/// Provider managing app-wide theme mode (Light / Dark mode) with persistence.
class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider(this._storageService) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    final savedMode = _storageService.loadThemeMode();
    _themeMode = savedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    AppColors.isDarkMode = isDarkMode;
  }

  /// Toggle between Light and Dark mode
  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    AppColors.isDarkMode = isDarkMode;
    await _storageService.saveThemeMode(isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }

  /// Explicitly set the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    AppColors.isDarkMode = isDarkMode;
    await _storageService.saveThemeMode(isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }
}
