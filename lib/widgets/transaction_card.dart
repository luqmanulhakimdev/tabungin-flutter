import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionCard({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final category = transaction.category;
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountPrefix = isIncome ? '+' : '-';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            // Category Icon with colored background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(width: 14),

            // Category Title & Notes / Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        DateFormatter.formatShort(transaction.date),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (transaction.notes != null &&
                          transaction.notes!.trim().isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            transaction.notes!.trim(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Amount with Sign
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix${CurrencyFormatter.format(transaction.amount)}',
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? AppColors.incomeSubtle
                        : AppColors.expenseSubtle,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    transaction.type.label,
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
