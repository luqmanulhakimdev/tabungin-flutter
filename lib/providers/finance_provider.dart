import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../services/storage_service.dart';
import '../utils/date_formatter.dart';

/// Primary provider managing financial state, transactions, and balance calculations.
/// Built upon Flutter's native ChangeNotifier for clean, reactive state management.
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

  /// Load data from local storage
  void _loadData() {
    _isLoading = true;
    notifyListeners();

    _initialBalance = _storageService.loadInitialBalance();
    _transactions = _storageService.loadTransactions();
    _sortTransactions();

    _isLoading = false;
    notifyListeners();
  }

  /// Sort transactions in descending chronological order (newest first)
  void _sortTransactions() {
    _transactions.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  // --- Financial Calculations ---

  /// Lifetime total income across all recorded history
  double get totalLifetimeIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Lifetime total expenses across all recorded history
  double get totalLifetimeExpense {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Current Net Balance = Initial Balance + Lifetime Income - Lifetime Expenses
  double get currentBalance {
    return _initialBalance + totalLifetimeIncome - totalLifetimeExpense;
  }

  /// Total income for the currently selected filter month
  double get monthlyIncome {
    return _transactions
        .where(
          (t) =>
              t.isIncome &&
              DateFormatter.isSameMonth(t.date, _selectedFilterMonth),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total expenses for the currently selected filter month
  double get monthlyExpense {
    return _transactions
        .where(
          (t) =>
              t.isExpense &&
              DateFormatter.isSameMonth(t.date, _selectedFilterMonth),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Net monthly savings cashflow (Surplus / Deficit)
  double get monthlyNetSavings {
    return monthlyIncome - monthlyExpense;
  }

  /// 5 most recent transactions for the dashboard preview
  List<TransactionModel> get recentTransactions {
    if (_transactions.length <= 5) {
      return List.unmodifiable(_transactions);
    }
    return List.unmodifiable(_transactions.sublist(0, 5));
  }

  /// Transactions filtered by active month and transaction type
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

  /// Expense breakdown grouped by category for the active month
  Map<String, double> get categoryExpenseBreakdown {
    final Map<String, double> breakdown = {};

    for (final t in _transactions) {
      if (t.isExpense &&
          DateFormatter.isSameMonth(t.date, _selectedFilterMonth)) {
        breakdown[t.categoryId] = (breakdown[t.categoryId] ?? 0.0) + t.amount;
      }
    }

    // Sort by largest expense amount descending
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  /// Income breakdown grouped by category for the active month
  Map<String, double> get categoryIncomeBreakdown {
    final Map<String, double> breakdown = {};

    for (final t in _transactions) {
      if (t.isIncome &&
          DateFormatter.isSameMonth(t.date, _selectedFilterMonth)) {
        breakdown[t.categoryId] = (breakdown[t.categoryId] ?? 0.0) + t.amount;
      }
    }

    // Sort by largest income amount descending
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  // --- Transaction CRUD Operations ---

  /// Add a new transaction record
  Future<bool> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    _sortTransactions();
    notifyListeners();

    final success = await _storageService.saveTransactions(_transactions);
    return success;
  }

  /// Update an existing transaction record
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

  /// Delete a transaction record by its ID
  Future<bool> deleteTransaction(String transactionId) async {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) return false;

    _transactions.removeAt(index);
    notifyListeners();

    final success = await _storageService.saveTransactions(_transactions);
    return success;
  }

  /// Update initial baseline balance
  Future<bool> updateInitialBalance(double balance) async {
    _initialBalance = balance;
    notifyListeners();
    return await _storageService.saveInitialBalance(balance);
  }

  // --- Filter & Date Navigation Operations ---

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

  /// Reset and clear all stored transaction and balance data
  Future<void> clearAllData() async {
    _transactions.clear();
    _initialBalance = 0.0;
    notifyListeners();
    await _storageService.clearAll();
  }
}
