import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import 'home/home_screen.dart';
import 'statistics/statistics_screen.dart';
import 'transactions/add_edit_transaction_screen.dart';
import 'transactions/transaction_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAddTransactionScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditTransactionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider?>();
    context.watch<LocaleProvider?>();
    final tr = context.tr;

    final screens = [
      HomeScreen(onNavigateToTransactions: () => _onTabSelected(1)),
      const TransactionListScreen(),
      const StatisticsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionScreen,
        tooltip: tr.addTransaction,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: tr.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: tr.navTransactions,
            ),
            NavigationDestination(
              icon: const Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: const Icon(Icons.pie_chart_rounded),
              label: tr.navStatistics,
            ),
          ],
        ),
      ),
    );
  }
}
