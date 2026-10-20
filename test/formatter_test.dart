import 'package:flutter_test/flutter_test.dart';
import 'package:tabungin_flutter/utils/currency_formatter.dart';
import 'package:tabungin_flutter/utils/date_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('Format angka ke format Rupiah standar', () {
      expect(CurrencyFormatter.format(1250000), 'Rp1.250.000');
      expect(CurrencyFormatter.format(0), 'Rp0');
      expect(CurrencyFormatter.format(50000), 'Rp50.000');
    });

    test('Format angka bertanda +/-', () {
      expect(
        CurrencyFormatter.formatSigned(50000, isIncome: true),
        '+Rp50.000',
      );
      expect(
        CurrencyFormatter.formatSigned(50000, isIncome: false),
        '-Rp50.000',
      );
    });

    test('Parse string input menjadi nilai double', () {
      expect(CurrencyFormatter.parse('1.250.000'), 1250000.0);
      expect(CurrencyFormatter.parse('Rp 50.000'), 50000.0);
      expect(CurrencyFormatter.parse(''), 0.0);
    });
  });

  group('DateFormatter', () {
    test('Format tanggal Indonesia penuh dan singkat', () {
      final date = DateTime(2026, 10, 20);
      expect(DateFormatter.formatFull(date), '20 Oktober 2026');
      expect(DateFormatter.formatShort(date), '20 Okt 2026');
      expect(DateFormatter.formatMonthYear(date), 'Oktober 2026');
      expect(DateFormatter.formatWithDay(date), 'Selasa, 20 Oktober 2026');
    });

    test('Pemeriksaan kesamaan bulan dan tahun', () {
      final a = DateTime(2026, 10, 5);
      final b = DateTime(2026, 10, 20);
      final c = DateTime(2026, 11, 20);

      expect(DateFormatter.isSameMonth(a, b), true);
      expect(DateFormatter.isSameMonth(a, c), false);
    });
  });
}
