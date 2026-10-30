import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

/// Service handling local data persistence for transactions and balances.
///
/// **Design Rationale for SharedPreferences:**
/// 1. Stable, official package directly maintained by the Flutter team (`shared_preferences`).
/// 2. Requires zero native database dependencies or migration scripts.
/// 3. Data is persisted as a JSON string, providing a transparent serialization pipeline (`toJson` & `fromJson`).
/// 4. Lightweight, fast, and resilient for offline-first personal finance tracking.
class StorageService {
  static const String _transactionsKey = 'tabungin_transactions';
  static const String _initialBalanceKey = 'tabungin_initial_balance';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Initialize SharedPreferences instance
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// Load all transactions from local storage
  List<TransactionModel> loadTransactions() {
    final rawJson = _prefs.getString(_transactionsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(rawJson) as List<dynamic>;
      return decodedList
          .map(
            (item) => TransactionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // In case of parsing corruption, return an empty list gracefully
      return [];
    }
  }

  /// Persist transactions list to local storage
  Future<bool> saveTransactions(List<TransactionModel> transactions) async {
    final listMap = transactions.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(listMap);
    return await _prefs.setString(_transactionsKey, jsonString);
  }

  /// Load user's initial balance (if set)
  double loadInitialBalance() {
    return _prefs.getDouble(_initialBalanceKey) ?? 0.0;
  }

  /// Save user's initial balance
  Future<bool> saveInitialBalance(double balance) async {
    return await _prefs.setDouble(_initialBalanceKey, balance);
  }

  static const String _themeModeKey = 'tabungin_theme_mode';

  /// Load user's theme mode preference
  String loadThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'light';
  }

  /// Save user's theme mode preference
  Future<bool> saveThemeMode(String mode) async {
    return await _prefs.setString(_themeModeKey, mode);
  }

  static const String _languageCodeKey = 'tabungin_language_code';

  /// Load user's language code preference ('id' or 'en')
  String loadLanguageCode() {
    return _prefs.getString(_languageCodeKey) ?? 'id';
  }

  /// Save user's language code preference
  Future<bool> saveLanguageCode(String code) async {
    return await _prefs.setString(_languageCodeKey, code);
  }

  /// Clear all persisted data (used for testing and data resets)
  Future<bool> clearAll() async {
    await _prefs.remove(_transactionsKey);
    await _prefs.remove(_initialBalanceKey);
    await _prefs.remove(_themeModeKey);
    await _prefs.remove(_languageCodeKey);
    return true;
  }
}
