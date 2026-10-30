import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/category_model.dart';
import '../../models/transaction_type.dart';
import '../../providers/finance_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector_bar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  TransactionType _activeCategoryTab = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider?>();
    final localeProvider = context.watch<LocaleProvider?>();
    final isEnglish = localeProvider?.isEnglish ?? false;
    final tr = context.tr;

    return Consumer<FinanceProvider>(
      builder: (context, finance, child) {
        final monthlyIncome = finance.monthlyIncome;
        final monthlyExpense = finance.monthlyExpense;
        final netSavings = finance.monthlyNetSavings;
        final isSurplus = netSavings >= 0;

        // Breakdown categories for active tab
        final breakdown = _activeCategoryTab == TransactionType.expense
            ? finance.categoryExpenseBreakdown
            : finance.categoryIncomeBreakdown;

        final totalActiveAmount = _activeCategoryTab == TransactionType.expense
            ? monthlyExpense
            : monthlyIncome;

        final hasAnyData = monthlyIncome > 0 || monthlyExpense > 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(tr.statisticsSummary),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Selector Bar
                MonthSelectorBar(
                  selectedMonth: finance.selectedFilterMonth,
                  onPrevious: finance.previousMonth,
                  onNext: finance.nextMonth,
                  onSelectMonth: finance.setFilterMonth,
                ),
                const SizedBox(height: 18),

                if (!hasAnyData)
                  EmptyStateWidget(
                    title: isEnglish ? 'No Financial Analytics Yet' : 'Belum Ada Data Statistik',
                    message: isEnglish
                        ? 'No financial records for the selected month. Add transactions to see graphical insights.'
                        : 'Tidak ada catatan keuangan pada bulan yang dipilih. Tambahkan transaksi untuk melihat analisis grafis.',
                    icon: Icons.bar_chart_rounded,
                  )
                else ...[
                  // 3 Summary Cards: Income, Expense, Net Savings
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryMetricCard(
                          title: tr.income,
                          amount: monthlyIncome,
                          color: AppColors.income,
                          icon: Icons.arrow_downward_rounded,
                          subtleColor: AppColors.incomeSubtle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryMetricCard(
                          title: tr.expense,
                          amount: monthlyExpense,
                          color: AppColors.expense,
                          icon: Icons.arrow_upward_rounded,
                          subtleColor: AppColors.expenseSubtle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Net Savings Card (Surplus / Deficit)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSurplus
                                      ? AppColors.incomeSubtle
                                      : AppColors.expenseSubtle,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSurplus
                                      ? Icons.savings_rounded
                                      : Icons.warning_amber_rounded,
                                  color: isSurplus
                                      ? AppColors.income
                                      : AppColors.expense,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr.netCashflow,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isSurplus ? tr.surplusSaved : (isEnglish ? 'Deficit' : 'Defisit'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSurplus
                                            ? AppColors.income
                                            : AppColors.expense,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${isSurplus ? '+' : '-'}${CurrencyFormatter.format(netSavings.abs())}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSurplus
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Visual Comparison: Income vs Expense
                  Text(
                    tr.cashflowComparison,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildComparisonBar(monthlyIncome, monthlyExpense, isEnglish: isEnglish),
                  const SizedBox(height: 28),

                  // Category Breakdown Header & Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tr.categoryDistribution,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Expense / Income Toggle
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.isDarkMode
                              ? const Color(0xFF0F172A)
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(10),
                          border: AppColors.isDarkMode
                              ? Border.all(color: AppColors.border, width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            _buildToggleOption(
                              type: TransactionType.expense,
                              label: tr.expense,
                            ),
                            _buildToggleOption(
                              type: TransactionType.income,
                              label: tr.income,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // List of category distribution bars
                  if (breakdown.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        isEnglish
                            ? 'No ${_activeCategoryTab.getLabel(isEnglish: true).toLowerCase()} recorded this month.'
                            : 'Tidak ada ${_activeCategoryTab.label.toLowerCase()} pada bulan ini.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: breakdown.entries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = breakdown.entries.elementAt(index);
                        final category = CategoryModel.getById(entry.key);
                        final amount = entry.value;
                        final percentage = totalActiveAmount > 0
                            ? (amount / totalActiveAmount)
                            : 0.0;

                        return _buildCategoryProgressRow(
                          category: category,
                          amount: amount,
                          percentage: percentage,
                          isEnglish: isEnglish,
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryMetricCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required Color subtleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: subtleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(double income, double expense, {bool isEnglish = false}) {
    final total = income + expense;
    final incomeRatio = total > 0 ? (income / total) : 0.5;
    final expenseRatio = total > 0 ? (expense / total) : 0.5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Visual Multi-Color Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  Expanded(
                    flex: (incomeRatio * 100).toInt().clamp(1, 100),
                    child: Container(color: AppColors.income),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (expenseRatio * 100).toInt().clamp(1, 100),
                    child: Container(color: AppColors.expense),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.income,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${isEnglish ? 'Income' : 'Pemasukan'} (${(incomeRatio * 100).toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.expense,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${isEnglish ? 'Expense' : 'Pengeluaran'} (${(expenseRatio * 100).toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required TransactionType type,
    required String label,
  }) {
    final isSelected = _activeCategoryTab == type;
    final isDark = AppColors.isDarkMode;

    return InkWell(
      onTap: () {
        setState(() {
          _activeCategoryTab = type;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected && isDark
              ? Border.all(color: AppColors.border, width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryProgressRow({
    required CategoryModel category,
    required double amount,
    required double percentage,
    bool isEnglish = false,
  }) {
    final percentString = (percentage * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.getLocalizedName(isEnglish: isEnglish),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$percentString% ${isEnglish ? 'of total' : 'dari total'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: AppColors.divider,
              color: category.color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
