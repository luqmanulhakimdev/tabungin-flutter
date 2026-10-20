import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabungin_flutter/models/transaction_model.dart';
import 'package:tabungin_flutter/models/transaction_type.dart';
import 'package:tabungin_flutter/providers/finance_provider.dart';
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    provider = FinanceProvider(storageService);
  });

  Widget buildTestableWidget(Widget child) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: provider)],
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
    testWidgets('Validasi form saat nominal kosong atau 0', (
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

    testWidgets('Menambah transaksi baru berhasil tersimpan ke provider', (
      WidgetTester tester,
    ) async {
      setMobileScreen(tester);
      await tester.pumpWidget(
        buildTestableWidget(const AddEditTransactionScreen()),
      );

      // Ganti tipe ke Pemasukan
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Pilih kategori Gaji
      await tester.tap(find.text('Gaji'));
      await tester.pumpAndSettle();

      // Masukkan nominal
      await tester.enterText(find.byType(TextFormField).first, '5000000');
      await tester.pumpAndSettle();

      // Masukkan catatan
      await tester.enterText(
        find.byType(TextFormField).last,
        'Gaji Proyek Flutter',
      );
      await tester.pumpAndSettle();

      // Tap Simpan Transaksi
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

    testWidgets('Edit transaksi memuat data lama dan menyimpan perubahan', (
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

      // Ganti nominal
      await tester.enterText(find.byType(TextFormField).first, '250000');
      await tester.pumpAndSettle();

      // Ganti catatan
      await tester.enterText(
        find.byType(TextFormField).last,
        'Makan siang baru',
      );
      await tester.pumpAndSettle();

      // Tap Perbarui Transaksi
      await tester.ensureVisible(find.text('Perbarui Transaksi'));
      await tester.tap(find.text('Perbarui Transaksi'));
      await tester.pumpAndSettle();

      expect(provider.allTransactions.first.amount, 250000.0);
      expect(provider.allTransactions.first.notes, 'Makan siang baru');
    });
  });

  group('HomeScreen Tests', () {
    testWidgets('Menampilkan ringkasan saldo, sapaan, dan modal saldo awal', (
      WidgetTester tester,
    ) async {
      setMobileScreen(tester);
      await tester.pumpWidget(
        buildTestableWidget(HomeScreen(onNavigateToTransactions: () {})),
      );

      expect(find.text('Tabungin'), findsOneWidget);
      expect(find.text('Total Saldo'), findsOneWidget);
      expect(find.text('Belum Ada Transaksi'), findsOneWidget);

      // Tap Saldo Awal untuk buka dialog
      await tester.tap(find.text('Saldo Awal'));
      await tester.pumpAndSettle();

      expect(find.text('Atur Saldo Awal'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '2000000');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(provider.initialBalance, 2000000.0);
      expect(provider.currentBalance, 2000000.0);
    });

    testWidgets(
      'Menampilkan daftar transaksi terbaru dan membuka detail sheet',
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

        // Tap Lihat Semua
        await tester.tap(find.text('Lihat Semua'));
        expect(navigated, true);

        // Tap transaksi untuk buka detail bottom sheet
        await tester.tap(find.text('Makanan & Minuman'));
        await tester.pumpAndSettle();

        expect(find.text('Tanggal'), findsOneWidget);
        expect(find.text('Catatan'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Hapus'), findsOneWidget);
      },
    );
  });

  group('TransactionListScreen Tests', () {
    testWidgets(
      'Filter chip jenis transaksi dan hapus transaksi dengan konfirmasi',
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

        // Filter Pemasukan via chip (menggunakan ancestor InkWell dengan teks Pemasukan)
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

        // Filter Pengeluaran
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

        // Buka detail sheet pengeluaran
        await tester.tap(find.text('Makanan & Minuman'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Transaksi'), findsOneWidget);
        expect(find.text('Hapus'), findsOneWidget);

        // Tap Hapus -> Muncul Dialog Konfirmasi
        await tester.tap(find.text('Hapus'));
        await tester.pumpAndSettle();

        expect(find.text('Hapus Transaksi?'), findsOneWidget);

        // Konfirmasi Hapus
        await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
        await tester.pumpAndSettle();

        expect(provider.allTransactions.length, 1);
        expect(provider.allTransactions.first.id, 'list-inc');
      },
    );
  });

  group('StatisticsScreen Tests', () {
    testWidgets(
      'Menampilkan metrik finansial, bar perbandingan, dan toggle kategori',
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

        // Toggle ke Pemasukan
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
    testWidgets('Navigasi antar tab dan tombol FAB tambah transaksi', (
      WidgetTester tester,
    ) async {
      setMobileScreen(tester);
      await tester.pumpWidget(
        buildTestableWidget(const MainNavigationScreen()),
      );

      expect(find.text('Tabungin'), findsOneWidget);

      // Switch ke Transaksi
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Riwayat Transaksi'), findsOneWidget);

      // Switch ke Statistik
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
