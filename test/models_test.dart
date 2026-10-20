import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabungin_flutter/models/category_model.dart';
import 'package:tabungin_flutter/models/transaction_model.dart';
import 'package:tabungin_flutter/models/transaction_type.dart';

void main() {
  group('TransactionType Tests', () {
    test('Verifikasi label, warna, subtleColor, dan icon', () {
      expect(TransactionType.income.label, 'Pemasukan');
      expect(TransactionType.expense.label, 'Pengeluaran');

      expect(TransactionType.income.color, isA<Color>());
      expect(TransactionType.expense.color, isA<Color>());

      expect(TransactionType.income.subtleColor, isA<Color>());
      expect(TransactionType.expense.subtleColor, isA<Color>());

      expect(TransactionType.income.icon, Icons.arrow_downward_rounded);
      expect(TransactionType.expense.icon, Icons.arrow_upward_rounded);
    });

    test('fromString konversi teks bahasa Inggris dan Indonesia', () {
      expect(TransactionType.fromString('income'), TransactionType.income);
      expect(TransactionType.fromString('pemasukan'), TransactionType.income);
      expect(TransactionType.fromString('expense'), TransactionType.expense);
      expect(
        TransactionType.fromString('pengeluaran'),
        TransactionType.expense,
      );
      expect(TransactionType.fromString('other'), TransactionType.expense);
    });
  });

  group('CategoryModel Tests', () {
    test('Default kategori pengeluaran dan pemasukan tersedia', () {
      expect(CategoryModel.defaultExpenseCategories.isNotEmpty, true);
      expect(CategoryModel.defaultIncomeCategories.isNotEmpty, true);
      expect(
        CategoryModel.allDefaults.length,
        CategoryModel.defaultExpenseCategories.length +
            CategoryModel.defaultIncomeCategories.length,
      );
    });

    test(
      'getById menemukan kategori yang tepat atau mengembalikan fallback',
      () {
        final food = CategoryModel.getById('exp_food');
        expect(food.id, 'exp_food');
        expect(food.name, 'Makanan & Minuman');
        expect(food.type, TransactionType.expense);

        final salary = CategoryModel.getById('inc_salary');
        expect(salary.id, 'inc_salary');
        expect(salary.name, 'Gaji');
        expect(salary.type, TransactionType.income);

        final unknown = CategoryModel.getById('non_existent_category');
        expect(unknown.id, 'unknown');
        expect(unknown.name, 'Lainnya');
      },
    );

    test('toJson dan fromJson bekerja konsisten', () {
      final category = CategoryModel.defaultExpenseCategories.first;
      final json = category.toJson();
      expect(json['id'], category.id);
      expect(json['name'], category.name);
      expect(json['type'], category.type.name);

      final restored = CategoryModel.fromJson(json);
      expect(restored.id, category.id);
      expect(restored.name, category.name);
    });
  });

  group('TransactionModel Tests', () {
    final testDate = DateTime(2026, 10, 20, 10, 30);
    final created = DateTime(2026, 10, 20, 10, 0);

    test('Properties category, isIncome, isExpense, copyWith', () {
      final tx = TransactionModel(
        id: 'tx-1',
        amount: 250000.0,
        type: TransactionType.expense,
        categoryId: 'exp_food',
        date: testDate,
        notes: 'Makan malam',
        createdAt: created,
      );

      expect(tx.isExpense, true);
      expect(tx.isIncome, false);
      expect(tx.category.id, 'exp_food');

      final copied = tx.copyWith(
        amount: 300000.0,
        notes: 'Makan malam keluarga',
      );
      expect(copied.amount, 300000.0);
      expect(copied.notes, 'Makan malam keluarga');
      expect(copied.id, tx.id);
      expect(copied.categoryId, tx.categoryId);
    });

    test('toJson dan fromJson serialization', () {
      final tx = TransactionModel(
        id: 'tx-json',
        amount: 500000.0,
        type: TransactionType.income,
        categoryId: 'inc_freelance',
        date: testDate,
        notes: 'Project Flutter',
        createdAt: created,
      );

      final json = tx.toJson();
      expect(json['id'], 'tx-json');
      expect(json['amount'], 500000.0);
      expect(json['type'], 'income');
      expect(json['categoryId'], 'inc_freelance');

      final restored = TransactionModel.fromJson(json);
      expect(restored.id, tx.id);
      expect(restored.amount, tx.amount);
      expect(restored.type, tx.type);
      expect(restored.categoryId, tx.categoryId);
      expect(restored.notes, tx.notes);
    });

    test('operator == dan hashCode', () {
      final tx1 = TransactionModel(
        id: 'same-id',
        amount: 10000.0,
        type: TransactionType.expense,
        categoryId: 'exp_food',
        date: testDate,
        createdAt: created,
      );
      final tx2 = TransactionModel(
        id: 'same-id',
        amount: 20000.0,
        type: TransactionType.expense,
        categoryId: 'exp_food',
        date: testDate,
        createdAt: created,
      );
      final tx3 = TransactionModel(
        id: 'different-id',
        amount: 10000.0,
        type: TransactionType.expense,
        categoryId: 'exp_food',
        date: testDate,
        createdAt: created,
      );

      expect(tx1 == tx2, true);
      expect(tx1.hashCode, tx2.hashCode);
      expect(tx1 == tx3, false);
    });
  });
}
