import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../providers/finance_provider.dart';
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
                            category.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            transaction.type.label,
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
                  label: 'Tanggal',
                  value: DateFormatter.formatWithDay(transaction.date),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.notes_rounded,
                  label: 'Catatan',
                  value:
                      (transaction.notes != null &&
                          transaction.notes!.trim().isNotEmpty)
                      ? transaction.notes!.trim()
                      : 'Tidak ada catatan',
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
                        label: const Text('Edit Transaksi'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final confirmed = await ConfirmDialog.show(
                            context,
                            title: 'Hapus Transaksi?',
                            message:
                                'Transaksi ${category.name} sebesar ${CurrencyFormatter.format(transaction.amount)} akan dihapus permanen.',
                          );

                          if (confirmed == true) {
                            await provider.deleteTransaction(transaction.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaksi berhasil dihapus'),
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
                        label: const Text('Hapus'),
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
            style: const TextStyle(
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
            style: const TextStyle(
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
    return Consumer<FinanceProvider>(
      builder: (context, finance, child) {
        final filteredList = finance.filteredTransactions;
        final selectedType = finance.selectedTypeFilter;

        return Scaffold(
          appBar: AppBar(title: const Text('Riwayat Transaksi')),
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

                    // Filter Chips: Semua, Pemasukan, Pengeluaran
                    Row(
                      children: [
                        _buildFilterChip(
                          label: 'Semua',
                          isSelected: selectedType == null,
                          onTap: () => finance.setTypeFilter(null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Pemasukan',
                          isSelected: selectedType == TransactionType.income,
                          onTap: () =>
                              finance.setTypeFilter(TransactionType.income),
                          selectedColor: AppColors.income,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Pengeluaran',
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
                          title: 'Tidak Ada Transaksi',
                          message: 'Tidak ada transaksi yang cocok untuk periode dan filter yang dipilih.',
                          buttonLabel: 'Tambah Transaksi',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.12)
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? selectedColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
