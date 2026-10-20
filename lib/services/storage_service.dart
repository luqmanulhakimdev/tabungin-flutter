import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

/// Service untuk menangani penyimpanan data transaksi secara lokal di perangkat.
///
/// **Alasan Memilih SharedPreferences untuk Pemula:**
/// 1. Sangat stabil & resmi dari tim Flutter (`shared_preferences`).
/// 2. Tidak memerlukan konfigurasi database native yang rumit (tidak perlu NDK atau migrasi tabel SQLite).
/// 3. Data disimpan dalam bentuk JSON String yang mudah dipahami alur serialisasinya (`toJson` & `fromJson`).
/// 4. Sangat andal dan cepat untuk kebutuhan aplikasi pencatat keuangan skala personal/MVP.
class StorageService {
  static const String _transactionsKey = 'tabungin_transactions';
  static const String _initialBalanceKey = 'tabungin_initial_balance';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Inisialisasi instance SharedPreferences
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// Memuat daftar semua transaksi dari penyimpanan lokal
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
      // Jika terjadi kesalahan parsing, kembalikan daftar kosong
      return [];
    }
  }

  /// Menyimpan daftar transaksi ke penyimpanan lokal
  Future<bool> saveTransactions(List<TransactionModel> transactions) async {
    final listMap = transactions.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(listMap);
    return await _prefs.setString(_transactionsKey, jsonString);
  }

  /// Memuat saldo awal pengguna (jika ada)
  double loadInitialBalance() {
    return _prefs.getDouble(_initialBalanceKey) ?? 0.0;
  }

  /// Menyimpan saldo awal pengguna
  Future<bool> saveInitialBalance(double balance) async {
    return await _prefs.setDouble(_initialBalanceKey, balance);
  }

  /// Menghapus seluruh data lokal (untuk pengujian atau reset)
  Future<bool> clearAll() async {
    await _prefs.remove(_transactionsKey);
    await _prefs.remove(_initialBalanceKey);
    return true;
  }
}
