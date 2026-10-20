import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  /// Format numbers to standard Rupiah format, e.g.: Rp1.250.000
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format numbers without the "Rp" symbol, e.g.: 1.250.000
  static String formatWithoutSymbol(double amount) {
    final formatted = _formatter.format(amount);
    return formatted.replaceFirst('Rp', '').trim();
  }

  /// Format numbers with a + or - sign to indicate cashflow direction
  static String formatSigned(double amount, {required bool isIncome}) {
    final base = format(amount);
    if (isIncome) {
      return '+$base';
    } else {
      return '-$base';
    }
  }

  /// Parse user input string into a pure double value
  static double parse(String input) {
    if (input.isEmpty) return 0.0;
    // Remove 'Rp', thousand separator dots, commas, and spaces
    final cleaned = input
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(' ', '')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}

/// [TextInputFormatter] that formats numeric inputs in real-time with thousand separator dots (.).
/// Example: when the user types '100000', the display automatically becomes '100.000'.
class CurrencyInputFormatter extends TextInputFormatter {
  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String text = newValue.text;
    int selectionIndex = newValue.selection.end;

    // Handle backspace when user deletes a thousand separator dot (.)
    if (oldValue.text.length - 1 == newValue.text.length) {
      final oldDigits = oldValue.text.replaceAll(RegExp(r'[^\d]'), '');
      final newDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      if (oldDigits == newDigits && oldValue.selection.end > 0) {
        final deletePos = oldValue.selection.end - 1;
        if (deletePos > 0) {
          text = oldValue.text.substring(0, deletePos - 1) +
              oldValue.text.substring(deletePos);
          selectionIndex = deletePos - 1;
        }
      }
    }

    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Limit maximum length to prevent integer overflow (max 15 digits)
    final safeDigits = digitsOnly.length > 15
        ? digitsOnly.substring(0, 15)
        : digitsOnly;

    final number = int.tryParse(safeDigits);
    if (number == null) return oldValue;

    final formatted = _numberFormat.format(number);

    // Calculate new cursor position proportionally based on digits before cursor
    int digitsBeforeCursor = 0;
    final maxCheck = selectionIndex.clamp(0, text.length);
    for (int i = 0; i < maxCheck; i++) {
      if (RegExp(r'\d').hasMatch(text[i])) {
        digitsBeforeCursor++;
      }
    }

    int newOffset = 0;
    int digitCount = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitCount++;
      }
      if (digitCount == digitsBeforeCursor) {
        newOffset = i + 1;
        break;
      }
    }

    if (digitsBeforeCursor == 0) {
      newOffset = 0;
    } else if (newOffset == 0 || newOffset > formatted.length) {
      newOffset = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

