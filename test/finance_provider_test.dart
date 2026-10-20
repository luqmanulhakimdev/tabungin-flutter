import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabungin_flutter/models/transaction_model.dart';
import 'package:tabungin_flutter/models/transaction_type.dart';
import 'package:tabungin_flutter/providers/finance_provider.dart';
import 'package:tabungin_flutter/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late FinanceProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    provider = FinanceProvider(storageService);
  });

  group('FinanceProvider - Perhitungan Saldo & Transaksi', () {
    test('Saldo awal default adalah 0 dan dapat diubah', () async {
      expect(provider.initialBalance, 0.0);
      expect(provider.currentBalance, 0.0);

      await provider.updateInitialBalance(500000.0);
      expect(provider.initialBalance, 500000.0);
      expect(provider.currentBalance, 500000.0);
    });

    test('Menambahkan transaksi pemasukan dan pengeluaran menghitung saldo dengan benar', () async {
      await provider.updateInitialBalance(1000000.0);

      final now = DateTime(2026, 10, 20);

      final income = TransactionModel(
        id: 'inc-1',
        amount: 5000000.0,
        type: TransactionType.income,
        categoryId: 'inc_salary',
        date: now,
        notes: 'Gaji Bulanan',
        createdAt: now,
      );
      await provider.addTransaction(income);

      final expense1 = TransactionModel(
        id: 'exp-1',
        amount: 150000.0,
        type: TransactionType.expense,
        categoryId: 'exp_food',
        date: now,
        notes: 'Makan siang',
        createdAt: now,
      );
      await provider.addTransaction(expense1);

      final expense2 = TransactionModel(
        id: 'exp-2',
        amount: 50000.0,
        type: TransactionType.expense,
        categoryId: 'exp_transport',
        date: now,
        notes: 'Ojek online',
        createdAt: now,
      );
      await provider.addTransaction(expense2);

      expect(provider.totalLifetimeIncome, 5000000.0);
      expect(provider.totalLifetimeExpense, 200000.0);
      expect(provider.currentBalance, 5800000.0);

      provider.setFilterMonth(now);
      expect(provider.monthlyIncome, 5000000.0);
      expect(provider.monthlyExpense, 200000.0);
      expect(provider.monthlyNetSavings, 4800000.0);
    });

    test(
      'Memperbarui transaksi (Edit) menghitung ulang saldo secara akurat',
      () async {
        final now = DateTime(2026, 10, 20);

        final transaction = TransactionModel(
          id: 'test-edit',
          amount: 100000.0,
          type: TransactionType.expense,
          categoryId: 'exp_food',
          date: now,
          createdAt: now,
        );
        await provider.addTransaction(transaction);
        expect(provider.totalLifetimeExpense, 100000.0);

        final updated = transaction.copyWith(amount: 125000.0);
        final success = await provider.updateTransaction(updated);
        expect(success, true);

        expect(provider.totalLifetimeExpense, 125000.0);
        expect(provider.currentBalance, -125000.0);

        // Edit transaksi dengan ID yang tidak ada mengembalikan false
        final notFound = transaction.copyWith(id: 'non-existent-id');
        final fail = await provider.updateTransaction(notFound);
        expect(fail, false);
      },
    );

    test(
      'Menghapus transaksi memperbarui daftar dan saldo secara instan',
      () async {
        final now = DateTime(2026, 10, 20);

        final t1 = TransactionModel(
          id: 'del-1',
          amount: 250000.0,
          type: TransactionType.expense,
          categoryId: 'exp_shopping',
          date: now,
          createdAt: now,
        );
        await provider.addTransaction(t1);
        expect(provider.allTransactions.length, 1);

        final deleted = await provider.deleteTransaction('del-1');
        expect(deleted, true);
        expect(provider.allTransactions.isEmpty, true);
        expect(provider.totalLifetimeExpense, 0.0);

        // Menghapus ID yang tidak ada mengembalikan false
        final failDelete = await provider.deleteTransaction('invalid-id');
        expect(failDelete, false);
      },
    );

    test('Filter bulan dan navigasi previous/next month', () {
      final initialMonth = DateTime(2026, 5);
      provider.setFilterMonth(initialMonth);
      expect(provider.selectedFilterMonth.month, 5);

      provider.previousMonth();
      expect(provider.selectedFilterMonth.month, 4);

      provider.nextMonth();
      expect(provider.selectedFilterMonth.month, 5);

      provider.nextMonth();
      expect(provider.selectedFilterMonth.month, 6);
    });

    test('Filter tipe transaksi (semua, pemasukan, pengeluaran)', () async {
      final now = DateTime(2026, 10, 20);
      provider.setFilterMonth(now);

      await provider.addTransaction(
        TransactionModel(
          id: 'inc-f',
          amount: 100000.0,
          type: TransactionType.income,
          categoryId: 'inc_salary',
          date: now,
          createdAt: now,
        ),
      );
      await provider.addTransaction(
        TransactionModel(
          id: 'exp-f',
          amount: 50000.0,
          type: TransactionType.expense,
          categoryId: 'exp_food',
          date: now,
          createdAt: now,
        ),
      );

      // Semua
      provider.setTypeFilter(null);
      expect(provider.filteredTransactions.length, 2);

      // Pemasukan
      provider.setTypeFilter(TransactionType.income);
      expect(provider.filteredTransactions.length, 1);
      expect(provider.filteredTransactions.first.id, 'inc-f');

      // Pengeluaran
      provider.setTypeFilter(TransactionType.expense);
      expect(provider.filteredTransactions.length, 1);
      expect(provider.filteredTransactions.first.id, 'exp-f');
    });

    test(
      'recentTransactions membatasi maksimal 5 data transaksi terbaru',
      () async {
        final now = DateTime(2026, 10, 20);
        for (int i = 1; i <= 7; i++) {
          await provider.addTransaction(
            TransactionModel(
              id: 'tx-$i',
              amount: (i * 10000).toDouble(),
              type: TransactionType.expense,
              categoryId: 'exp_food',
              date: now.add(Duration(minutes: i)),
              createdAt: now.add(Duration(minutes: i)),
            ),
          );
        }

        expect(provider.allTransactions.length, 7);
        expect(provider.recentTransactions.length, 5);
        // Urutan pertama adalah yang paling baru (tx-7)
        expect(provider.recentTransactions.first.id, 'tx-7');
      },
    );

    test('Ringkasan pengeluaran dan pemasukan per kategori dikelompokkan dengan benar', () async {
      final now = DateTime(2026, 10, 20);
      provider.setFilterMonth(now);

      // Pengeluaran
      await provider.addTransaction(
        TransactionModel(
          id: '1',
          amount: 100000.0,
          type: TransactionType.expense,
          categoryId: 'exp_food',
          date: now,
          createdAt: now,
        ),
      );
      await provider.addTransaction(
        TransactionModel(
          id: '2',
          amount: 50000.0,
          type: TransactionType.expense,
          categoryId: 'exp_food',
          date: now,
          createdAt: now,
        ),
      );
      await provider.addTransaction(
        TransactionModel(
          id: '3',
          amount: 80000.0,
          type: TransactionType.expense,
          categoryId: 'exp_transport',
          date: now,
          createdAt: now,
        ),
      );

      // Pemasukan
      await provider.addTransaction(
        TransactionModel(
          id: '4',
          amount: 3000000.0,
          type: TransactionType.income,
          categoryId: 'inc_salary',
          date: now,
          createdAt: now,
        ),
      );
      await provider.addTransaction(
        TransactionModel(
          id: '5',
          amount: 500000.0,
          type: TransactionType.income,
          categoryId: 'inc_freelance',
          date: now,
          createdAt: now,
        ),
      );

      final expBreakdown = provider.categoryExpenseBreakdown;
      expect(expBreakdown['exp_food'], 150000.0);
      expect(expBreakdown['exp_transport'], 80000.0);
      expect(expBreakdown.keys.first, 'exp_food');

      final incBreakdown = provider.categoryIncomeBreakdown;
      expect(incBreakdown['inc_salary'], 3000000.0);
      expect(incBreakdown['inc_freelance'], 500000.0);
      expect(incBreakdown.keys.first, 'inc_salary');
    });

    test('clearAllData mengosongkan seluruh data state dan storage', () async {
      await provider.updateInitialBalance(100000);
      await provider.addTransaction(
        TransactionModel(
          id: 'clear-1',
          amount: 50000,
          type: TransactionType.income,
          categoryId: 'inc_salary',
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      expect(provider.allTransactions.length, 1);
      expect(provider.initialBalance, 100000);

      await provider.clearAllData();
      expect(provider.allTransactions.isEmpty, true);
      expect(provider.initialBalance, 0.0);
      expect(provider.currentBalance, 0.0);
    });

    test(
      'StorageService menangani JSON rusak tanpa melempar exception',
      () async {
        SharedPreferences.setMockInitialValues({
          'tabungin_transactions': 'invalid-corrupted-json-content',
        });
        final customStorage = await StorageService.init();
        final loaded = customStorage.loadTransactions();
        expect(loaded.isEmpty, true);
      },
    );
  });
}
