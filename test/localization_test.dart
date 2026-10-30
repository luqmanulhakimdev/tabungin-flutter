import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabungin_flutter/localization/app_localizations.dart';
import 'package:tabungin_flutter/models/category_model.dart';
import 'package:tabungin_flutter/models/transaction_type.dart';
import 'package:tabungin_flutter/providers/finance_provider.dart';
import 'package:tabungin_flutter/providers/locale_provider.dart';
import 'package:tabungin_flutter/providers/theme_provider.dart';
import 'package:tabungin_flutter/screens/home/home_screen.dart';
import 'package:tabungin_flutter/services/storage_service.dart';
import 'package:tabungin_flutter/utils/date_formatter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider & Localization Tests', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
    });

    test('LocaleProvider initializes with default Indonesian (id)', () {
      final localeProvider = LocaleProvider(storageService);
      expect(localeProvider.languageCode, 'id');
      expect(localeProvider.locale, const Locale('id'));
      expect(localeProvider.isEnglish, false);
    });

    test('LocaleProvider toggles between id and en and persists', () async {
      final localeProvider = LocaleProvider(storageService);

      await localeProvider.toggleLocale();
      expect(localeProvider.languageCode, 'en');
      expect(localeProvider.isEnglish, true);
      expect(storageService.loadLanguageCode(), 'en');

      await localeProvider.toggleLocale();
      expect(localeProvider.languageCode, 'id');
      expect(localeProvider.isEnglish, false);
      expect(storageService.loadLanguageCode(), 'id');
    });

    test('AppLocalizations provides translated strings accurately', () {
      const idLocalizations = AppLocalizations('id');
      const enLocalizations = AppLocalizations('en');

      expect(idLocalizations.navHome, 'Beranda');
      expect(enLocalizations.navHome, 'Home');

      expect(idLocalizations.navTransactions, 'Transaksi');
      expect(enLocalizations.navTransactions, 'Transactions');

      expect(idLocalizations.navStatistics, 'Statistik');
      expect(enLocalizations.navStatistics, 'Statistics');

      expect(idLocalizations.totalBalance, 'Total Saldo');
      expect(enLocalizations.totalBalance, 'Total Balance');

      expect(idLocalizations.income, 'Pemasukan');
      expect(enLocalizations.income, 'Income');

      expect(idLocalizations.expense, 'Pengeluaran');
      expect(enLocalizations.expense, 'Expense');
    });

    test('TransactionType labels localize correctly', () {
      expect(TransactionType.income.getLabel(isEnglish: false), 'Pemasukan');
      expect(TransactionType.income.getLabel(isEnglish: true), 'Income');
      expect(TransactionType.expense.getLabel(isEnglish: false), 'Pengeluaran');
      expect(TransactionType.expense.getLabel(isEnglish: true), 'Expense');
    });

    test('CategoryModel localized names work accurately', () {
      final categorySalary = CategoryModel.getById('inc_salary');
      expect(categorySalary.getLocalizedName(isEnglish: false), 'Gaji');
      expect(categorySalary.getLocalizedName(isEnglish: true), 'Salary');

      final categoryFood = CategoryModel.getById('exp_food');
      expect(categoryFood.getLocalizedName(isEnglish: false), 'Makanan & Minuman');
      expect(categoryFood.getLocalizedName(isEnglish: true), 'Food & Beverage');
    });

    test('DateFormatter formats months and greetings in both languages', () {
      final testDate = DateTime(2026, 10, 15);
      expect(DateFormatter.formatMonthYear(testDate, isEnglish: false), 'Oktober 2026');
      expect(DateFormatter.formatMonthYear(testDate, isEnglish: true), 'October 2026');

      expect(DateFormatter.formatShort(testDate, isEnglish: false), '15 Okt 2026');
      expect(DateFormatter.formatShort(testDate, isEnglish: true), '15 Oct 2026');
    });

    testWidgets('Tapping language switcher on HomeScreen updates UI to English', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final financeProvider = FinanceProvider(storageService);
      final themeProvider = ThemeProvider(storageService);
      final localeProvider = LocaleProvider(storageService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: financeProvider),
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: localeProvider),
          ],
          child: MaterialApp(
            home: HomeScreen(onNavigateToTransactions: () {}),
          ),
        ),
      );

      // Initially Indonesian
      expect(find.text('Total Saldo'), findsOneWidget);
      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);

      // Tap the Language switch button (which shows 'ID' when current is ID)
      final langButton = find.text('ID');
      expect(langButton, findsOneWidget);
      await tester.tap(langButton);
      await tester.pumpAndSettle();

      // Now English
      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget); // Button shows 'EN' now
    });
  });
}
