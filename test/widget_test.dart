import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabungin_flutter/app.dart';
import 'package:tabungin_flutter/providers/finance_provider.dart';
import 'package:tabungin_flutter/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TabunginApp smoke test rendering home screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();
    final provider = FinanceProvider(storageService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: provider)],
        child: const TabunginApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Tabungin branding and balance card are rendered
    expect(find.text('Tabungin'), findsOneWidget);
    expect(find.text('Total Saldo'), findsOneWidget);
    expect(find.text('Rp0'), findsWidgets);

    // Verify Bottom Navigation items
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Transaksi'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget);
  });
}
