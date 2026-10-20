import 'package:flutter/material.dart';

import 'transaction_type.dart';

class CategoryModel {
  final String id;
  final String name;
  final TransactionType type;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type.name};
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return getById(id);
  }

  /// Kategori bawaan Pengeluaran
  static const List<CategoryModel> defaultExpenseCategories = [
    CategoryModel(
      id: 'exp_food',
      name: 'Makanan & Minuman',
      type: TransactionType.expense,
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF97316), // Orange
    ),
    CategoryModel(
      id: 'exp_transport',
      name: 'Transportasi',
      type: TransactionType.expense,
      icon: Icons.directions_car_rounded,
      color: Color(0xFF3B82F6), // Blue
    ),
    CategoryModel(
      id: 'exp_shopping',
      name: 'Belanja',
      type: TransactionType.expense,
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFEC4899), // Pink
    ),
    CategoryModel(
      id: 'exp_bills',
      name: 'Tagihan',
      type: TransactionType.expense,
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF8B5CF6), // Purple
    ),
    CategoryModel(
      id: 'exp_entertainment',
      name: 'Hiburan',
      type: TransactionType.expense,
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF14B8A6), // Teal
    ),
    CategoryModel(
      id: 'exp_health',
      name: 'Kesehatan',
      type: TransactionType.expense,
      icon: Icons.medical_services_rounded,
      color: Color(0xFFEF4444), // Red
    ),
    CategoryModel(
      id: 'exp_education',
      name: 'Pendidikan',
      type: TransactionType.expense,
      icon: Icons.school_rounded,
      color: Color(0xFF6366F1), // Indigo
    ),
    CategoryModel(
      id: 'exp_others',
      name: 'Lainnya',
      type: TransactionType.expense,
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF64748B), // Slate
    ),
  ];

  /// Kategori bawaan Pemasukan
  static const List<CategoryModel> defaultIncomeCategories = [
    CategoryModel(
      id: 'inc_salary',
      name: 'Gaji',
      type: TransactionType.income,
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF059669), // Emerald
    ),
    CategoryModel(
      id: 'inc_freelance',
      name: 'Freelance',
      type: TransactionType.income,
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF0284C7), // Sky
    ),
    CategoryModel(
      id: 'inc_business',
      name: 'Bisnis',
      type: TransactionType.income,
      icon: Icons.store_rounded,
      color: Color(0xFFD97706), // Amber
    ),
    CategoryModel(
      id: 'inc_gift',
      name: 'Hadiah',
      type: TransactionType.income,
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFE11D48), // Rose
    ),
    CategoryModel(
      id: 'inc_others',
      name: 'Lainnya',
      type: TransactionType.income,
      icon: Icons.savings_rounded,
      color: Color(0xFF0D9488), // Teal
    ),
  ];

  static List<CategoryModel> get allDefaults => [
    ...defaultExpenseCategories,
    ...defaultIncomeCategories,
  ];

  static CategoryModel getById(String id) {
    return allDefaults.firstWhere(
      (c) => c.id == id,
      orElse: () => const CategoryModel(
        id: 'unknown',
        name: 'Lainnya',
        type: TransactionType.expense,
        icon: Icons.category_rounded,
        color: Color(0xFF64748B),
      ),
    );
  }
}
