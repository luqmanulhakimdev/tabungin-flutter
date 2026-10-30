import 'package:flutter/material.dart';

import '../services/storage_service.dart';

/// Provider managing app-wide language locale ('id' or 'en') with persistence.
class LocaleProvider extends ChangeNotifier {
  final StorageService _storageService;
  Locale _locale = const Locale('id');

  LocaleProvider(this._storageService) {
    _loadLocale();
  }

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isEnglish => _locale.languageCode == 'en';

  void _loadLocale() {
    final savedCode = _storageService.loadLanguageCode();
    _locale = Locale(savedCode == 'en' ? 'en' : 'id');
  }

  /// Toggle between Indonesian ('id') and English ('en')
  Future<void> toggleLocale() async {
    final nextCode = isEnglish ? 'id' : 'en';
    _locale = Locale(nextCode);
    await _storageService.saveLanguageCode(nextCode);
    notifyListeners();
  }

  /// Explicitly set the language code
  Future<void> setLocale(String languageCode) async {
    final targetCode = languageCode == 'en' ? 'en' : 'id';
    _locale = Locale(targetCode);
    await _storageService.saveLanguageCode(targetCode);
    notifyListeners();
  }
}
