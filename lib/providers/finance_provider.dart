import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../services/storage_service.dart';
import '../utils/date_formatter.dart';

/// Provider utama untuk mengelola state keuangan, transaksi, dan kalkulasi saldo.
/// Menggunakan ChangeNotifier yang merupakan arsitektur bawaan Flutter yang bersih dan reaktif.
class FinanceProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<TransactionModel> _transactions = [];
  double _initialBalance = 0.0;
  bool _isLoading = false;

  // Filter state
  DateTime _selectedFilterMonth = DateTime.now();
  TransactionType? _selectedTypeFilter;

  FinanceProvider(this._storageService) {
    _loadData();
  }

  // --- Getters ---

  bool get isLoading => _isLoading;
  List<TransactionModel> get allTransactions =>
      List.unmodifiable(_transactions);
  double get initialBalance => _initialBalance;
  DateTime get selectedFilterMonth => _selectedFilterMonth;
  TransactionType? get selectedTypeFilter => _selectedTypeFilter;

  /// Memuat data dari local storage
  void _loadData() {
    _isLoading = true;
    notifyListeners();

    _initialBalance = _storageService.loadInitialBalance();
    _transactions = _storageService.loadTransactions();
    _sortTransactions();

    _isLoading = false;
    notifyListeners();
  }

  /// Mengurutkan transaksi dari tanggal terbaru ke terlama
  void _sortTransactions() {
    _transactions.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  // --- Kalkulasi Keuangan ---

  /// Total seluruh pemasukan sepanjang waktu
  double get totalLifetimeIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total seluruh pengeluaran sepanjang waktu
  double get totalLifetimeExpense {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total Saldo Saat Ini = Saldo Awal + Seluruh Pemasukan - Seluruh Pengeluaran
  double get currentBalance {
    return _initialBalance + totalLifetimeIncome - totalLifetimeExpense;
  }

  /// Total Pemasukan untuk bulan yang sedang difilter
  double get monthlyIncome {
    return _transactions
        .where(
          (t) =>
              t.isIncome &&
              DateFormatter.isSameMonth(t.date, _selectedFilterMonth),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total Pengeluaran untuk bulan yang sedang difilter
  double get monthlyExpense {
    return _transactions
        .where(
          (t) =>
              t.isExpense &&
              DateFormatter.isSameMonth(t.date, _selectedFilterMonth),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Selisih bersih bulan ini (Surplus / Defisit)
  double get monthlyNetSavings {
    return monthlyIncome - monthlyExpense;
  }

  /// 5 Transaksi terbaru untuk tampilan ringkas di Dashboard
  List<TransactionModel> get recentTransactions {
    if (_transactions.length <= 5) {
      return List.unmodifiable(_transactions);
    }
    return List.unmodifiable(_transactions.sublist(0, 5));
  }

  /// Transaksi yang sudah disaring berdasarkan bulan & jenis transaksi
  List<TransactionModel> get filteredTransactions {
    return _transactions.where((t) {
      final matchesMonth = DateFormatter.isSameMonth(
        t.date,
        _selectedFilterMonth,
      );
      if (!matchesMonth) return false;

      if (_selectedTypeFilter != null) {
        return t.type == _selectedTypeFilter;
      }
      return true;
    }).toList();
  }

  /// Ringkasan pengeluaran per kategori pada bulan yang dipilih
  Map<String, double> get categoryExpenseBreakdown {
    final Map<String, double> breakdown = {};

    for (final t in _transactions) {
      if (t.isExpense &&
          DateFormatter.isSameMonth(t.date, _selectedFilterMonth)) {
        breakdown[t.categoryId] = (breakdown[t.categoryId] ?? 0.0) + t.amount;
      }
    }

    // Urutkan dari pengeluaran terbesar
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  /// Ringkasan pemasukan per kategori pada bulan yang dipilih
  Map<String, double> get categoryIncomeBreakdown {
    final Map<String, double> breakdown = {};

    for (final t in _transactions) {
      if (t.isIncome &&
          DateFormatter.isSameMonth(t.date, _selectedFilterMonth)) {
        breakdown[t.categoryId] = (breakdown[t.categoryId] ?? 0.0) + t.amount;
      }
    }

    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  // --- Operasi CRUD Transaksi ---

  /// Menambahkan transaksi baru
  Future<bool> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    _sortTransactions();
    notifyListeners();

    final success = await _storageService.saveTransactions(_transactions);
    return success;
  }

  /// Mengedit transaksi yang sudah ada
  Future<bool> updateTransaction(TransactionModel updatedTransaction) async {
    final index = _transactions.indexWhere(
      (t) => t.id == updatedTransaction.id,
    );
    if (index == -1) return false;

    _transactions[index] = updatedTransaction;
    _sortTransactions();
    notifyListeners();

    final success = await _storageService.saveTransactions(_transactions);
    return success;
  }

  /// Menghapus transaksi berdasarkan ID
  Future<bool> deleteTransaction(String transactionId) async {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) return false;

    _transactions.removeAt(index);
    notifyListeners();

    final success = await _storageService.saveTransactions(_transactions);
    return success;
  }

  /// Memperbarui saldo awal
  Future<bool> updateInitialBalance(double balance) async {
    _initialBalance = balance;
    notifyListeners();
    return await _storageService.saveInitialBalance(balance);
  }

  // --- Operasi Filter & Navigasi Tanggal ---

  void setFilterMonth(DateTime month) {
    _selectedFilterMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void previousMonth() {
    _selectedFilterMonth = DateTime(
      _selectedFilterMonth.year,
      _selectedFilterMonth.month - 1,
    );
    notifyListeners();
  }

  void nextMonth() {
    _selectedFilterMonth = DateTime(
      _selectedFilterMonth.year,
      _selectedFilterMonth.month + 1,
    );
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  /// Membersihkan seluruh data
  Future<void> clearAllData() async {
    _transactions.clear();
    _initialBalance = 0.0;
    notifyListeners();
    await _storageService.clearAll();
  }
}
