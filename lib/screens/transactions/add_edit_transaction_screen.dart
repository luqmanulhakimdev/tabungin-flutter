import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddEditTransactionScreen({super.key, this.transactionToEdit});

  bool get isEditing => transactionToEdit != null;

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late TransactionType _selectedType;
  late String _selectedCategoryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final edit = widget.transactionToEdit;
    if (edit != null) {
      _selectedType = edit.type;
      _selectedCategoryId = edit.categoryId;
      _selectedDate = edit.date;
      _amountController.text = CurrencyFormatter.formatWithoutSymbol(
        edit.amount,
      );
      _notesController.text = edit.notes ?? '';
    } else {
      _selectedType = TransactionType.expense;
      _selectedCategoryId = CategoryModel.defaultExpenseCategories.first.id;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<CategoryModel> get _currentCategories {
    return _selectedType == TransactionType.income
        ? CategoryModel.defaultIncomeCategories
        : CategoryModel.defaultExpenseCategories;
  }

  void _onTypeChanged(TransactionType newType) {
    if (_selectedType == newType) return;
    setState(() {
      _selectedType = newType;
      // Reset selected category to first available in new type
      final categories = newType == TransactionType.income
          ? CategoryModel.defaultIncomeCategories
          : CategoryModel.defaultExpenseCategories;
      _selectedCategoryId = categories.first.id;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primaryLight,
                    onPrimary: Colors.white,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.lightTextPrimary,
                  ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal transaksi harus lebih dari 0'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final provider = context.read<FinanceProvider>();
    final notes = _notesController.text.trim();

    if (widget.isEditing) {
      final updated = widget.transactionToEdit!.copyWith(
        amount: amount,
        type: _selectedType,
        categoryId: _selectedCategoryId,
        date: _selectedDate,
        notes: notes.isEmpty ? null : notes,
      );
      await provider.updateTransaction(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil diperbarui'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      const uuid = Uuid();
      final newTransaction = TransactionModel(
        id: uuid.v4(),
        amount: amount,
        type: _selectedType,
        categoryId: _selectedCategoryId,
        date: _selectedDate,
        notes: notes.isEmpty ? null : notes,
        createdAt: DateTime.now(),
      );
      await provider.addTransaction(newTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil disimpan'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final isEditing = widget.isEditing;
    final title = isEditing ? 'Edit Transaksi' : 'Tambah Transaksi';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Type Selector (Expense / Income)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.isDarkMode
                      ? const Color(0xFF0F172A)
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(14),
                  border: AppColors.isDarkMode
                      ? Border.all(color: AppColors.border, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        type: TransactionType.expense,
                        label: 'Pengeluaran',
                        icon: Icons.arrow_upward_rounded,
                        color: AppColors.expense,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildTypeButton(
                        type: TransactionType.income,
                        label: 'Pemasukan',
                        icon: Icons.arrow_downward_rounded,
                        color: AppColors.income,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount Input Field
              Text(
                'Nominal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      'Rp',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  hintText: '0',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal tidak boleh kosong';
                  }
                  final parsed = CurrencyFormatter.parse(value);
                  if (parsed <= 0) {
                    return 'Masukkan nominal yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Picker
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: _currentCategories.length,
                itemBuilder: (context, index) {
                  final cat = _currentCategories[index];
                  final isSelected = cat.id == _selectedCategoryId;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = cat.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withValues(alpha: 0.12)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? cat.color : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cat.color
                                  : cat.color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat.icon,
                              color: isSelected ? Colors.white : cat.color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Transaction Date
              Text(
                'Tanggal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormatter.formatWithDay(_selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.edit_calendar_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Optional Notes
              Text(
                'Catatan (Opsional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Misal: Sarapan bubur ayam di kantor',
                ),
              ),
              const SizedBox(height: 32),

              // Save / Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEditing ? 'Perbarui Transaksi' : 'Simpan Transaksi',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    final isDark = AppColors.isDarkMode;

    return InkWell(
      onTap: () => _onTypeChanged(type),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected && isDark
              ? Border.all(color: AppColors.border, width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
