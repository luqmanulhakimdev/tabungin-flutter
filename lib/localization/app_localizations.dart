import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';

/// Class providing localized strings across Tabungin for Indonesian ('id') and English ('en').
class AppLocalizations {
  final String languageCode;

  const AppLocalizations(this.languageCode);

  bool get isEnglish => languageCode == 'en';

  static AppLocalizations of(BuildContext context) {
    try {
      final localeProvider = Provider.of<LocaleProvider?>(context, listen: true);
      if (localeProvider != null) {
        return AppLocalizations(localeProvider.languageCode);
      }
    } catch (_) {}
    return const AppLocalizations('id');
  }

  // App & Navigation
  String get appName => 'Tabungin';
  String get navHome => isEnglish ? 'Home' : 'Beranda';
  String get navTransactions => isEnglish ? 'Transactions' : 'Transaksi';
  String get navStatistics => isEnglish ? 'Statistics' : 'Statistik';

  // Common Actions
  String get cancel => isEnglish ? 'Cancel' : 'Batal';
  String get save => isEnglish ? 'Save' : 'Simpan';
  String get delete => isEnglish ? 'Delete' : 'Hapus';
  String get edit => isEnglish ? 'Edit' : 'Edit';
  String get close => isEnglish ? 'Close' : 'Tutup';
  String get all => isEnglish ? 'All' : 'Semua';
  String get optional => isEnglish ? 'Optional' : 'Opsional';

  // Home / Dashboard
  String get greetingMorning => isEnglish ? 'Good Morning' : 'Selamat Pagi';
  String get greetingAfternoon => isEnglish ? 'Good Afternoon' : 'Selamat Siang';
  String get greetingEvening => isEnglish ? 'Good Evening' : 'Selamat Sore';
  String get greetingNight => isEnglish ? 'Good Night' : 'Selamat Malam';
  String get totalBalance => isEnglish ? 'Total Balance' : 'Total Saldo';
  String get initialBalance => isEnglish ? 'Initial Balance' : 'Saldo Awal';
  String get setInitialBalance => isEnglish ? 'Set Initial Balance' : 'Atur Saldo Awal';
  String get initialBalanceDesc => isEnglish
      ? 'Initial balance sets your starting savings baseline without altering transaction history.'
      : 'Saldo awal ini menjadi titik awal perhitungan saldo Anda tanpa mengubah riwayat transaksi.';
  String get balanceAmount => isEnglish ? 'Balance Amount' : 'Nominal Saldo';
  String get saveBalance => isEnglish ? 'Save Balance' : 'Simpan Saldo';
  String get income => isEnglish ? 'Income' : 'Pemasukan';
  String get expense => isEnglish ? 'Expense' : 'Pengeluaran';
  String get cashflowSurplus => isEnglish ? 'Net Cashflow (Surplus)' : 'Arus Kas Bersih (Surplus)';
  String get cashflowDeficit => isEnglish ? 'Net Cashflow (Deficit)' : 'Arus Kas Bersih (Defisit)';
  String get cashflowBalanced => isEnglish ? 'Net Cashflow' : 'Arus Kas Bersih';
  String surplusMessage(String amount) => isEnglish
      ? 'Great! Income exceeds expenses by $amount'
      : 'Bagus! Pemasukan lebih besar $amount';
  String deficitMessage(String amount) => isEnglish
      ? 'Warning! Expenses exceed income by $amount'
      : 'Perhatian! Pengeluaran melebihi pemasukan $amount';
  String get balancedMessage => isEnglish
      ? 'Income and expenses are perfectly balanced'
      : 'Pemasukan dan pengeluaran seimbang';
  String get recentTransactions => isEnglish ? 'Recent Transactions' : 'Transaksi Terbaru';
  String get viewAll => isEnglish ? 'View All' : 'Lihat Semua';
  String get noTransactionsYet => isEnglish ? 'No Transactions Yet' : 'Belum Ada Transaksi';
  String get noTransactionsDesc => isEnglish
      ? 'Start recording your first transaction to track your daily income and expenses.'
      : 'Mulai catat transaksi pertamamu untuk melacak pemasukan dan pengeluaran harian.';
  String get addTransaction => isEnglish ? 'Add Transaction' : 'Tambah Transaksi';

  // Transaction Details & Actions
  String get transactionDetails => isEnglish ? 'Transaction Details' : 'Detail Transaksi';
  String get deleteTransaction => isEnglish ? 'Delete Transaction' : 'Hapus Transaksi';
  String get deleteTransactionConfirm => isEnglish
      ? 'Are you sure you want to delete this transaction? This action cannot be undone.'
      : 'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.';
  String get transactionDeleted => isEnglish ? 'Transaction deleted successfully' : 'Transaksi berhasil dihapus';

  // Transactions Screen
  String get transactionHistory => isEnglish ? 'Transaction History' : 'Riwayat Transaksi';
  String get noTransactionsForMonth => isEnglish ? 'No Transactions' : 'Belum Ada Transaksi';
  String noTransactionsForMonthDesc(String month) => isEnglish
      ? 'No transactions recorded for $month.'
      : 'Tidak ada transaksi tercatat untuk bulan $month.';

  // Add / Edit Transaction Screen
  String get addTransactionTitle => isEnglish ? 'Add Transaction' : 'Tambah Transaksi';
  String get editTransactionTitle => isEnglish ? 'Edit Transaction' : 'Edit Transaksi';
  String get nominal => isEnglish ? 'Amount' : 'Nominal';
  String get category => isEnglish ? 'Category' : 'Kategori';
  String get date => isEnglish ? 'Date' : 'Tanggal';
  String get noteOptional => isEnglish ? 'Note (Optional)' : 'Catatan (Opsional)';
  String get noteHint => isEnglish ? 'E.g., Breakfast at office' : 'Misal: Sarapan bubur ayam di kantor';
  String get saveTransaction => isEnglish ? 'Save Transaction' : 'Simpan Transaksi';
  String get saveChanges => isEnglish ? 'Save Changes' : 'Simpan Perubahan';
  String get nominalValidation => isEnglish ? 'Amount must be greater than Rp 0' : 'Nominal harus lebih dari Rp 0';
  String get selectCategoryValidation => isEnglish ? 'Please select a category' : 'Pilih salah satu kategori';
  String get transactionSaved => isEnglish ? 'Transaction saved successfully' : 'Transaksi berhasil disimpan';
  String get transactionUpdated => isEnglish ? 'Transaction updated successfully' : 'Transaksi berhasil diperbarui';

  // Statistics Screen
  String get statisticsSummary => isEnglish ? 'Financial Analytics' : 'Ringkasan Statistik';
  String get netCashflow => isEnglish ? 'Net Difference (Cashflow)' : 'Selisih (Arus Kas Bersih)';
  String get surplusSaved => isEnglish ? 'Surplus / Saved' : 'Surplus / Hemat';
  String get deficitOverbudget => isEnglish ? 'Deficit / Overbudget' : 'Defisit / Overbudget';
  String get balanced => isEnglish ? 'Balanced' : 'Seimbang';
  String get cashflowComparison => isEnglish ? 'Cashflow Comparison' : 'Perbandingan Arus Kas';
  String get categoryDistribution => isEnglish ? 'Category Distribution' : 'Distribusi Kategori';
  String get noExpenseThisMonth => isEnglish ? 'No expenses recorded this month' : 'Belum ada pengeluaran di bulan ini';
  String get noIncomeThisMonth => isEnglish ? 'No income recorded this month' : 'Belum ada pemasukan di bulan ini';
  String get ofTotal => isEnglish ? 'of total' : 'dari total';

  // Month Selector
  String get selectMonth => isEnglish ? 'Select Month' : 'Pilih Bulan';

  // Language switch feedback
  String get languageSwitched => isEnglish
      ? 'Language changed to English'
      : 'Bahasa diubah ke Bahasa Indonesia';
}

/// Convenience extension for easy access via `context.tr`
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this);
}
