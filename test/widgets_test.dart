import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabungin_flutter/models/transaction_model.dart';
import 'package:tabungin_flutter/models/transaction_type.dart';
import 'package:tabungin_flutter/widgets/balance_card.dart';
import 'package:tabungin_flutter/widgets/confirm_dialog.dart';
import 'package:tabungin_flutter/widgets/empty_state_widget.dart';
import 'package:tabungin_flutter/widgets/month_selector_bar.dart';
import 'package:tabungin_flutter/widgets/transaction_card.dart';

void main() {
  testWidgets(
    'TransactionCard renders income and expense correctly and triggers onTap',
    (WidgetTester tester) async {
      bool tapped = false;
      final incomeTx = TransactionModel(
        id: 'tx-card-inc',
        amount: 1500000.0,
        type: TransactionType.income,
        categoryId: 'inc_salary',
        date: DateTime(2026, 10, 20),
        notes: 'Transfer bonus',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionCard(
              transaction: incomeTx,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Gaji'), findsOneWidget);
      expect(find.text('Transfer bonus'), findsOneWidget);
      expect(find.text('+Rp1.500.000'), findsOneWidget);
      expect(find.text('Pemasukan'), findsOneWidget);

      await tester.tap(find.byType(TransactionCard));
      expect(tapped, true);

      // Expense without notes
      final expenseTx = TransactionModel(
        id: 'tx-card-exp',
        amount: 35000.0,
        type: TransactionType.expense,
        categoryId: 'exp_food',
        date: DateTime(2026, 10, 20),
        notes: null,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TransactionCard(transaction: expenseTx)),
        ),
      );

      expect(find.text('Makanan & Minuman'), findsOneWidget);
      expect(find.text('-Rp35.000'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
    },
  );

  testWidgets('ConfirmDialog shows and handles cancel or confirm actions', (
    WidgetTester tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmDialog.show(
                  context,
                  title: 'Hapus Item',
                  message: 'Yakin ingin menghapus item ini?',
                );
              },
              child: const Text('Buka Dialog'),
            ),
          ),
        ),
      ),
    );

    // Open Dialog
    await tester.tap(find.text('Buka Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus Item'), findsOneWidget);
    expect(find.text('Yakin ingin menghapus item ini?'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(result, false);

    // Re-open and tap Delete
    await tester.tap(find.text('Buka Dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(result, true);
  });

  testWidgets(
    'MonthSelectorBar triggers navigation and opens month picker modal',
    (WidgetTester tester) async {
      bool prevTriggered = false;
      bool nextTriggered = false;
      DateTime? selectedMonthResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorBar(
              selectedMonth: DateTime(2026, 10),
              onPrevious: () => prevTriggered = true,
              onNext: () => nextTriggered = true,
              onSelectMonth: (month) => selectedMonthResult = month,
            ),
          ),
        ),
      );

      expect(find.text('Oktober 2026'), findsOneWidget);

      // Tap previous & next
      await tester.tap(find.byTooltip('Bulan Sebelumnya'));
      expect(prevTriggered, true);

      await tester.tap(find.byTooltip('Bulan Selanjutnya'));
      expect(nextTriggered, true);

      // Tap selector to open bottom sheet
      await tester.tap(find.text('Oktober 2026'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Bulan'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);

      // Tap 'Jan' in picker
      await tester.tap(find.text('Januari'));
      await tester.pumpAndSettle();

      expect(selectedMonthResult?.month, 1);
    },
  );

  testWidgets('BalanceCard triggers onAdjustBalance callback', (
    WidgetTester tester,
  ) async {
    bool adjusted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BalanceCard(
            currentBalance: 7500000,
            monthlyIncome: 10000000,
            monthlyExpense: 2500000,
            onAdjustBalance: () => adjusted = true,
          ),
        ),
      ),
    );

    expect(find.text('Total Saldo'), findsOneWidget);
    expect(find.text('Rp7.500.000'), findsOneWidget);
    expect(find.text('Rp10.000.000'), findsOneWidget);
    expect(find.text('Rp2.500.000'), findsOneWidget);

    await tester.tap(find.text('Saldo Awal'));
    expect(adjusted, true);
  });

  testWidgets('EmptyStateWidget renders properly and triggers button action', (
    WidgetTester tester,
  ) async {
    bool actionPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            title: 'Data Kosong',
            message: 'Silakan tambah data baru.',
            buttonLabel: 'Tambah Data',
            onButtonPressed: () => actionPressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Data Kosong'), findsOneWidget);
    expect(find.text('Silakan tambah data baru.'), findsOneWidget);
    expect(find.text('Tambah Data'), findsOneWidget);

    await tester.tap(find.text('Tambah Data'));
    expect(actionPressed, true);
  });
}
