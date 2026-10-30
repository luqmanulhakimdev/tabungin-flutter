import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../providers/finance_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector_bar.dart';
import '../../widgets/transaction_card.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
    FinanceProvider provider,
  ) {
    final tr = context.tr;
    final isEnglish = Provider.of<LocaleProvider?>(context, listen: false)?.isEnglish ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final category = transaction.category;
        final isIncome = transaction.isIncome;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.getLocalizedName(isEnglish: isEnglish),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            transaction.type.getLabel(isEnglish: isEnglish),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isIncome
                                  ? AppColors.income
                                  : AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isIncome ? AppColors.income : AppColors.expense,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: tr.date,
                  value: DateFormatter.formatWithDay(transaction.date, isEnglish: isEnglish),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.notes_rounded,
                  label: isEnglish ? 'Note' : 'Catatan',
                  value:
                      (transaction.notes != null &&
                          transaction.notes!.trim().isNotEmpty)
                      ? transaction.notes!.trim()
                      : (isEnglish ? 'No notes' : 'Tidak ada catatan'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddEditTransactionScreen(
                                transactionToEdit: transaction,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: Text(isEnglish ? 'Edit Transaction' : 'Edit Transaksi'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final catName = category.getLocalizedName(isEnglish: isEnglish);
                          final confirmed = await ConfirmDialog.show(
                            context,
                            title: isEnglish ? 'Delete Transaction?' : 'Hapus Transaksi?',
                            message: isEnglish
                                ? 'Transaction $catName of ${CurrencyFormatter.format(transaction.amount)} will be permanently deleted.'
                                : 'Transaksi $catName sebesar ${CurrencyFormatter.format(transaction.amount)} akan dihapus permanen.',
                            confirmLabel: tr.delete,
                            cancelLabel: tr.cancel,
                          );

                          if (confirmed == true) {
                            await provider.deleteTransaction(transaction.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr.transactionDeleted),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                        ),
                        label: Text(tr.delete),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.expense,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider?>();
    final localeProvider = context.watch<LocaleProvider?>();
    final isEnglish = localeProvider?.isEnglish ?? false;
    final tr = context.tr;

    return Consumer<FinanceProvider>(
      builder: (context, finance, child) {
        final filteredList = finance.filteredTransactions;
        final selectedType = finance.selectedTypeFilter;

        return Scaffold(
          appBar: AppBar(
            title: Text(tr.transactionHistory),
            actions: [
              // Language switch button
              InkWell(
                onTap: () {
                  context.read<LocaleProvider?>()?.toggleLocale();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEnglish ? 'EN' : 'ID',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  context.read<ThemeProvider>().toggleTheme();
                },
                icon: Icon(
                  context.watch<ThemeProvider>().isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: context.watch<ThemeProvider>().isDarkMode
                      ? const Color(0xFFFBBF24)
                      : AppColors.textSecondary,
                ),
                tooltip: context.watch<ThemeProvider>().isDarkMode
                    ? (isEnglish ? 'Light Mode' : 'Mode Terang')
                    : (isEnglish ? 'Dark Mode' : 'Mode Gelap'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Month Selector Bar & Type Filter Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(
                  children: [
                    MonthSelectorBar(
                      selectedMonth: finance.selectedFilterMonth,
                      onPrevious: finance.previousMonth,
                      onNext: finance.nextMonth,
                      onSelectMonth: finance.setFilterMonth,
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips: All, Income, Expense
                    Row(
                      children: [
                        _buildFilterChip(
                          label: tr.all,
                          isSelected: selectedType == null,
                          onTap: () => finance.setTypeFilter(null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: tr.income,
                          isSelected: selectedType == TransactionType.income,
                          onTap: () =>
                              finance.setTypeFilter(TransactionType.income),
                          selectedColor: AppColors.income,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: tr.expense,
                          isSelected: selectedType == TransactionType.expense,
                          onTap: () =>
                              finance.setTypeFilter(TransactionType.expense),
                          selectedColor: AppColors.expense,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Transaction List or Empty State
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: EmptyStateWidget(
                          title: isEnglish ? 'No Transactions' : 'Tidak Ada Transaksi',
                          message: isEnglish
                              ? 'No transactions match the selected period and filter.'
                              : 'Tidak ada transaksi yang cocok untuk periode dan filter yang dipilih.',
                          buttonLabel: tr.addTransaction,
                          onButtonPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddEditTransactionScreen(),
                              ),
                            );
                          },
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final transaction = filteredList[index];
                          return TransactionCard(
                            transaction: transaction,
                            onTap: () => _showTransactionDetails(
                              context,
                              transaction,
                              finance,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color selectedColor = AppColors.primary,
  }) {
    final isDark = AppColors.isDarkMode;
    final effectiveColor =
        isDark && selectedColor == AppColors.primary
            ? AppColors.primaryLight
            : selectedColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? effectiveColor.withValues(alpha: 0.22)
                  : effectiveColor.withValues(alpha: 0.12))
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? effectiveColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? effectiveColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
