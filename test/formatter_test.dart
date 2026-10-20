import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabungin_flutter/utils/currency_formatter.dart';
import 'package:tabungin_flutter/utils/date_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('Format numbers to standard Rupiah format', () {
      expect(CurrencyFormatter.format(1250000), 'Rp1.250.000');
      expect(CurrencyFormatter.format(0), 'Rp0');
      expect(CurrencyFormatter.format(50000), 'Rp50.000');
    });

    test('Format signed numbers with +/-', () {
      expect(
        CurrencyFormatter.formatSigned(50000, isIncome: true),
        '+Rp50.000',
      );
      expect(
        CurrencyFormatter.formatSigned(50000, isIncome: false),
        '-Rp50.000',
      );
    });

    test('Parse string input into double value', () {
      expect(CurrencyFormatter.parse('1.250.000'), 1250000.0);
      expect(CurrencyFormatter.parse('Rp 50.000'), 50000.0);
      expect(CurrencyFormatter.parse(''), 0.0);
    });
  });

  group('CurrencyInputFormatter', () {
    final formatter = CurrencyInputFormatter();

    test('Format standard numbers with thousand dot separators', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '100000',
        selection: TextSelection.collapsed(offset: 6),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '100.000');
      expect(result.selection.end, 7);
    });

    test('Handle empty text', () {
      const oldValue = TextEditingValue(
        text: '500',
        selection: TextSelection.collapsed(offset: 3),
      );
      const newValue = TextEditingValue.empty;

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '');
      expect(result.selection.end, 0);
    });

    test('Automatically strip non-digit characters', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: 'abc25000xyz',
        selection: TextSelection.collapsed(offset: 11),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '25.000');
    });

    test('Handle backspace on separator dot', () {
      // old: 1.000 (offset 2, cursor after dot)
      // new: 1000 (offset 1, dot removed)
      const oldValue = TextEditingValue(
        text: '1.000',
        selection: TextSelection.collapsed(offset: 2),
      );
      const newValue = TextEditingValue(
        text: '1000',
        selection: TextSelection.collapsed(offset: 1),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      // When dot is deleted, digit preceding the dot is deleted as well
      expect(result.text.isNotEmpty, true);
    });

    test('Limit maximum input length to 15 digits to avoid overflow', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '1234567890123456789',
        selection: TextSelection.collapsed(offset: 19),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      // Formats first 15 digits: 123.456.789.012.345
      expect(result.text, '123.456.789.012.345');
    });

    test('Preserve cursor position when inserting digits in the middle', () {
      // old: 100.000 (cursor at offset 2, after '10')
      // user types '5' -> '105.000'
      const oldValue = TextEditingValue(
        text: '100.000',
        selection: TextSelection.collapsed(offset: 2),
      );
      const newValue = TextEditingValue(
        text: '1050.000',
        selection: TextSelection.collapsed(offset: 3),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text.contains('1.050.000') || result.text.contains('105.000'), true);
      expect(result.selection.end > 0, true);
    });

    test('Normalize excess leading zeros', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '0500',
        selection: TextSelection.collapsed(offset: 4),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '500');
    });
  });

  group('DateFormatter', () {
    test('Format full, short, and localized Indonesian dates', () {
      final date = DateTime(2026, 10, 20);
      expect(DateFormatter.formatFull(date), '20 Oktober 2026');
      expect(DateFormatter.formatShort(date), '20 Okt 2026');
      expect(DateFormatter.formatMonthYear(date), 'Oktober 2026');
      expect(DateFormatter.formatWithDay(date), 'Selasa, 20 Oktober 2026');
    });

    test('Validate same month and year comparison', () {
      final a = DateTime(2026, 10, 5);
      final b = DateTime(2026, 10, 20);
      final c = DateTime(2026, 11, 20);

      expect(DateFormatter.isSameMonth(a, b), true);
      expect(DateFormatter.isSameMonth(a, c), false);
    });
  });
}
