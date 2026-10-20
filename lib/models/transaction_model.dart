import 'category_model.dart';
import 'transaction_type.dart';

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  CategoryModel get category => CategoryModel.getById(categoryId);

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.fromString(json['type'] as String),
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
