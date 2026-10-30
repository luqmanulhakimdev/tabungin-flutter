import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/transaction_model.dart';
import '../../providers/finance_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/transaction_card.dart';
import '../transactions/add_edit_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToTransactions;

  const HomeScreen({super.key, required this.onNavigateToTransactions});

  void _showInitialBalanceDialog(
    BuildContext context,
    FinanceProvider provider,
  ) {
    final controller = TextEditingController(
      text: provider.initialBalance > 0
          ? CurrencyFormatter.formatWithoutSymbol(provider.initialBalance)
          : '',
    );

    final tr = context.tr;
    final isEnglish = Provider.of<LocaleProvider?>(context, listen: false)?.isEnglish ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                tr.setInitialBalance,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.initialBalanceDesc,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                autofocus: true,
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final balance = CurrencyFormatter.parse(controller.text);
                provider.updateInitialBalance(balance);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEnglish
                          ? 'Initial balance updated successfully'
                          : 'Saldo awal berhasil diperbarui',
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: Text(tr.save),
            ),
          ],
        );
      },
    );
  }

  void _openTransactionDetail(
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
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
                _buildDetailRow(
                  label: tr.date,
                  value: DateFormatter.formatWithDay(transaction.date, isEnglish: isEnglish),
                  icon: Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  label: isEnglish ? 'Note' : 'Catatan',
                  value:
                      (transaction.notes != null &&
                          transaction.notes!.trim().isNotEmpty)
                      ? transaction.notes!.trim()
                      : (isEnglish ? 'No notes' : 'Tidak ada catatan'),
                  icon: Icons.notes_rounded,
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
                        label: Text(tr.edit),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(isEnglish ? 'Delete Transaction?' : 'Hapus Transaksi?'),
                              content: Text(tr.deleteTransactionConfirm),
                              actions: [
                                OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(tr.cancel),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.expense,
                                  ),
                                  child: Text(tr.delete),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await provider.deleteTransaction(transaction.id);
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

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
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
    return Consumer<FinanceProvider>(
      builder: (context, finance, child) {
        final recentTransactions = finance.recentTransactions;
        final hasTransactions = finance.allTransactions.isNotEmpty;
        final netSavings = finance.monthlyNetSavings;
        final isSurplus = netSavings >= 0;
        final tr = context.tr;
        final isEnglish = context.watch<LocaleProvider?>()?.isEnglish ?? false;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Provider is already synced with local storage
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Greeting Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormatter.getGreeting(isEnglish: isEnglish),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Tabungin',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Language switcher
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
                            // Theme toggle
                            InkWell(
                              onTap: () {
                                context.read<ThemeProvider>().toggleTheme();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  context.watch<ThemeProvider>().isDarkMode
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  size: 18,
                                  color:
                                      context.watch<ThemeProvider>().isDarkMode
                                          ? const Color(0xFFFBBF24)
                                          : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormatter.formatMonthYear(
                                      DateTime.now(),
                                      isEnglish: isEnglish,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Total Balance Card
                    BalanceCard(
                      currentBalance: finance.currentBalance,
                      monthlyIncome: finance.monthlyIncome,
                      monthlyExpense: finance.monthlyExpense,
                      onAdjustBalance: () =>
                          _showInitialBalanceDialog(context, finance),
                    ),
                    const SizedBox(height: 18),

                    // Monthly Cashflow Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSurplus
                            ? AppColors.incomeSubtle.withValues(alpha: 0.5)
                            : AppColors.expenseSubtle.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSurplus
                              ? AppColors.income.withValues(alpha: 0.2)
                              : AppColors.expense.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSurplus
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: isSurplus
                                ? AppColors.income
                                : AppColors.expense,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSurplus
                                      ? tr.cashflowSurplus
                                      : tr.cashflowDeficit,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSurplus
                                        ? AppColors.income
                                        : AppColors.expense,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSurplus
                                      ? tr.surplusMessage(CurrencyFormatter.format(netSavings))
                                      : tr.deficitMessage(CurrencyFormatter.format(netSavings.abs())),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr.recentTransactions,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (hasTransactions)
                          TextButton(
                            onPressed: onNavigateToTransactions,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  tr.viewAll,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.arrow_forward_rounded, size: 14),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Recent Transactions List or Empty State
                    if (!hasTransactions)
                      EmptyStateWidget(
                        title: tr.noTransactionsYet,
                        message: tr.noTransactionsDesc,
                        buttonLabel: tr.addTransaction,
                        onButtonPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddEditTransactionScreen(),
                            ),
                          );
                        },
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentTransactions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final transaction = recentTransactions[index];
                          return TransactionCard(
                            transaction: transaction,
                            onTap: () => _openTransactionDetail(
                              context,
                              transaction,
                              finance,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
