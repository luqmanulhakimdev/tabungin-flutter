import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabungin_flutter/models/transaction_model.dart';
import 'package:tabungin_flutter/models/transaction_type.dart';
import 'package:tabungin_flutter/providers/finance_provider.dart';
import 'package:tabungin_flutter/providers/theme_provider.dart';
import 'package:tabungin_flutter/screens/home/home_screen.dart';
import 'package:tabungin_flutter/screens/main_navigation_screen.dart';
import 'package:tabungin_flutter/screens/statistics/statistics_screen.dart';
import 'package:tabungin_flutter/screens/transactions/add_edit_transaction_screen.dart';
import 'package:tabungin_flutter/screens/transactions/transaction_list_screen.dart';
import 'package:tabungin_flutter/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late FinanceProvider provider;
  late ThemeProvider themeProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    provider = FinanceProvider(storageService);
    themeProvider = ThemeProvider(storageService);
  });

  Widget buildTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: provider),
      ],
      child: MaterialApp(home: child),
    );
  }

  void setMobileScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('AddEditTransactionScreen Tests', () {
    testWidgets('Form validation when amount is empty or zero', (
      WidgetTester tester,
    ) async {
      setMobileScreen(tester);
      await tester.pumpWidget(
        buildTestableWidget(const AddEditTransactionScreen()),
      );

      expect(find.text('Tambah Transaksi'), findsOneWidget);
      expect(find.text('Simpan Transaksi'), findsOneWidget);

      await tester.ensureVisible(find.text('Simpan Transaksi'));
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Nominal tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Adding new transaction saves successfully to provider', (
      WidgetTester tester,
    ) async {
      setMobileScreen(tester);
      await tester.pumpWidget(
        buildTestableWidget(const AddEditTransactionScreen()),
      );

      // Switch type to Income
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Select Salary category
      await tester.tap(find.text('Gaji'));
      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(find.byType(TextFormField).first, '5000000');
      await tester.pumpAndSettle();
      expect(find.text('5.000.000'), findsOneWidget);

      // Enter notes
      await tester.enterText(
        find.byType(TextFormField).last,
        'Gaji Proyek Flutter',
      );
      await tester.pumpAndSettle();

      // Tap Save Transaction
      await tester.ensureVisible(find.text('Simpan Transaksi'));
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pumpAndSettle();

      expect(provider.allTransactions.length, 1);
      final saved = provider.allTransactions.first;
      expect(saved.amount, 5000000.0);
      expect(saved.type, TransactionType.income);
      expect(saved.categoryId, 'inc_salary');
      expect(saved.notes, 'Gaji Proyek Flutter');
    });

    testWidgets('Edit transaction loads previous data and persists modifications', (
      WidgetTester tester,
    ) async {
      setMobileScreen(tester);
      final initialTx = TransactionModel(
        id: 'edit-1',
        amount: 200000.0,
        type: TransactionType.expense,
        categoryId: 'exp_food',
        date: DateTime.now(),
        notes: 'Makan siang lama',
        createdAt: DateTime.now(),
      );
      await provider.addTransaction(initialTx);

      await tester.pumpWidget(
        buildTestableWidget(
          AddEditTransactionScreen(transactionToEdit: initialTx),
        ),
      );

      expect(find.text('Edit Transaksi'), findsOneWidget);
      expect(find.text('Perbarui Transaksi'), findsOneWidget);

      // Change amount
      await tester.enterText(find.byType(TextFormField).first, '250000');
      await tester.pumpAndSettle();

      // Change notes
      await tester.enterText(
        find.byType(TextFormField).last,
        'Makan siang baru',
      );
      await tester.pumpAndSettle();

      // Tap Update Transaction
      await tester.ensureVisible(find.text('Perbarui Transaksi'));
      await tester.tap(find.text('Perbarui Transaksi'));
      await tester.pumpAndSettle();

      expect(provider.allTransactions.first.amount, 250000.0);
      expect(provider.allTransactions.first.notes, 'Makan siang baru');
    });
  });

  group('HomeScreen Tests', () {
    testWidgets('Displays balance summary, greeting, and initial balance modal', (
      WidgetTester tester,
    ) async {
      setMobileScreen(tester);
      await tester.pumpWidget(
        buildTestableWidget(HomeScreen(onNavigateToTransactions: () {})),
      );

      expect(find.text('Tabungin'), findsOneWidget);
      expect(find.text('Total Saldo'), findsOneWidget);
      expect(find.text('Belum Ada Transaksi'), findsOneWidget);

      // Tap Initial Balance to open dialog
      await tester.tap(find.text('Saldo Awal'));
      await tester.pumpAndSettle();

      expect(find.text('Atur Saldo Awal'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '2000000');
      await tester.pumpAndSettle();
      expect(find.text('2.000.000'), findsOneWidget);
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(provider.initialBalance, 2000000.0);
      expect(provider.currentBalance, 2000000.0);
    });

    testWidgets(
      'Displays recent transactions list and opens detail sheet',
      (WidgetTester tester) async {
        setMobileScreen(tester);
        bool navigated = false;
        final tx = TransactionModel(
          id: 'home-tx',
          amount: 75000.0,
          type: TransactionType.expense,
          categoryId: 'exp_food',
          date: DateTime.now(),
          notes: 'Bakso Malang',
          createdAt: DateTime.now(),
        );
        await provider.addTransaction(tx);

        await tester.pumpWidget(
          buildTestableWidget(
            HomeScreen(onNavigateToTransactions: () => navigated = true),
          ),
        );

        expect(find.text('Makanan & Minuman'), findsOneWidget);
        expect(find.text('Bakso Malang'), findsOneWidget);

        // Tap See All
        await tester.tap(find.text('Lihat Semua'));
        expect(navigated, true);

        // Tap transaction to open bottom sheet detail
        await tester.tap(find.text('Makanan & Minuman'));
        await tester.pumpAndSettle();

        expect(find.text('Tanggal'), findsOneWidget);
        expect(find.text('Catatan'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Hapus'), findsOneWidget);
      },
    );

    testWidgets('Toggle Dark Mode and Light Mode updates ThemeProvider', (
      WidgetTester tester,
    ) async {
      setMobileScreen(tester);
      await tester.pumpWidget(
        buildTestableWidget(
          HomeScreen(onNavigateToTransactions: () {}),
        ),
      );

      expect(themeProvider.isDarkMode, false);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

      // Tap dark mode toggle
      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      await tester.pumpAndSettle();

      expect(themeProvider.isDarkMode, true);
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

      // Tap again to switch back to light mode
      await tester.tap(find.byIcon(Icons.light_mode_rounded));
      await tester.pumpAndSettle();

      expect(themeProvider.isDarkMode, false);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });
  });

  group('TransactionListScreen Tests', () {
    testWidgets(
      'Filter transaction type chips and delete transaction with confirmation',
      (WidgetTester tester) async {
        setMobileScreen(tester);
        final now = DateTime.now();
        final inc = TransactionModel(
          id: 'list-inc',
          amount: 1000000.0,
          type: TransactionType.income,
          categoryId: 'inc_salary',
          date: now,
          createdAt: now,
        );
        final exp = TransactionModel(
          id: 'list-exp',
          amount: 50000.0,
          type: TransactionType.expense,
          categoryId: 'exp_food',
          date: now,
          createdAt: now,
        );
        await provider.addTransaction(inc);
        await provider.addTransaction(exp);

        await tester.pumpWidget(
          buildTestableWidget(const TransactionListScreen()),
        );

        expect(find.text('Gaji'), findsOneWidget);
        expect(find.text('Makanan & Minuman'), findsOneWidget);

        // Filter Income via chip
        final filterIncomeChip = find
            .ancestor(
              of: find.text('Pemasukan'),
              matching: find.byType(InkWell),
            )
            .first;
        await tester.tap(filterIncomeChip);
        await tester.pumpAndSettle();

        expect(find.text('Gaji'), findsOneWidget);
        expect(find.text('Makanan & Minuman'), findsNothing);

        // Filter Expense via chip
        final filterExpenseChip = find
            .ancestor(
              of: find.text('Pengeluaran'),
              matching: find.byType(InkWell),
            )
            .first;
        await tester.tap(filterExpenseChip);
        await tester.pumpAndSettle();

        expect(find.text('Gaji'), findsNothing);
        expect(find.text('Makanan & Minuman'), findsOneWidget);

        // Open expense detail sheet
        await tester.tap(find.text('Makanan & Minuman'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Transaksi'), findsOneWidget);
        expect(find.text('Hapus'), findsOneWidget);

        // Tap Delete -> Confirmation dialog appears
        await tester.tap(find.text('Hapus'));
        await tester.pumpAndSettle();

        expect(find.text('Hapus Transaksi?'), findsOneWidget);

        // Confirm Delete
        await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
        await tester.pumpAndSettle();

        expect(provider.allTransactions.length, 1);
        expect(provider.allTransactions.first.id, 'list-inc');
      },
    );
  });

  group('StatisticsScreen Tests', () {
    testWidgets(
      'Displays financial metrics, comparison bar, and category toggle',
      (WidgetTester tester) async {
        setMobileScreen(tester);
        final now = DateTime.now();
        await provider.addTransaction(
          TransactionModel(
            id: 'stat-inc',
            amount: 4000000.0,
            type: TransactionType.income,
            categoryId: 'inc_salary',
            date: now,
            createdAt: now,
          ),
        );
        await provider.addTransaction(
          TransactionModel(
            id: 'stat-exp',
            amount: 1500000.0,
            type: TransactionType.expense,
            categoryId: 'exp_food',
            date: now,
            createdAt: now,
          ),
        );

        await tester.pumpWidget(buildTestableWidget(const StatisticsScreen()));

        expect(find.text('Ringkasan Statistik'), findsOneWidget);
        expect(find.text('Perbandingan Arus Kas'), findsOneWidget);
        expect(find.text('Distribusi Kategori'), findsOneWidget);
        expect(find.text('Makanan & Minuman'), findsOneWidget);

        // Toggle to Income
        final incomeToggle = find
            .ancestor(
              of: find.text('Pemasukan'),
              matching: find.byType(InkWell),
            )
            .first;
        await tester.tap(incomeToggle);
        await tester.pumpAndSettle();

        expect(find.text('Gaji'), findsOneWidget);
      },
    );
  });

  group('MainNavigationScreen Tests', () {
    testWidgets('Navigation across bottom tabs and floating action button', (
      WidgetTester tester,
    ) async {
      setMobileScreen(tester);
      await tester.pumpWidget(
        buildTestableWidget(const MainNavigationScreen()),
      );

      expect(find.text('Tabungin'), findsOneWidget);

      // Switch to Transactions tab
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Riwayat Transaksi'), findsOneWidget);

      // Switch to Statistics tab
      await tester.tap(find.byIcon(Icons.pie_chart_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Ringkasan Statistik'), findsOneWidget);

      // Tap FAB (+)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Tambah Transaksi'), findsOneWidget);
    });
  });
}
