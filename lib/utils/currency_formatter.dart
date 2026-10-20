import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  /// Format angka ke format Rupiah standar, contoh: Rp1.250.000
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format angka tanpa simbol "Rp", contoh: 1.250.000
  static String formatWithoutSymbol(double amount) {
    final formatted = _formatter.format(amount);
    return formatted.replaceFirst('Rp', '').trim();
  }

  /// Format angka dengan tanda + atau - untuk membedakan arus kas
  static String formatSigned(double amount, {required bool isIncome}) {
    final base = format(amount);
    if (isIncome) {
      return '+$base';
    } else {
      return '-$base';
    }
  }

  /// Bersihkan string input dari pengguna menjadi double murni
  static double parse(String input) {
    if (input.isEmpty) return 0.0;
    // Hapus 'Rp', titik pemisah ribuan, spasi
    final cleaned = input
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(' ', '')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
