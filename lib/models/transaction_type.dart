import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum TransactionType {
  income,
  expense;

  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
    }
  }

  Color get subtleColor {
    switch (this) {
      case TransactionType.income:
        return AppColors.incomeSubtle;
      case TransactionType.expense:
        return AppColors.expenseSubtle;
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.expense:
        return Icons.arrow_upward_rounded;
    }
  }

  static TransactionType fromString(String value) {
    if (value.toLowerCase() == 'income' || value.toLowerCase() == 'pemasukan') {
      return TransactionType.income;
    }
    return TransactionType.expense;
  }
}
