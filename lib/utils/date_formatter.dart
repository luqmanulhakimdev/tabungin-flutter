class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  /// Format: 20 Oktober 2026
  static String formatFull(DateTime date) {
    final day = date.day;
    final month = _months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  /// Format: 20 Okt 2026
  static String formatShort(DateTime date) {
    final day = date.day;
    final month = _monthsShort[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  /// Format: Oktober 2026
  static String formatMonthYear(DateTime date) {
    final month = _months[date.month - 1];
    return '$month ${date.year}';
  }

  /// Format: Selasa, 20 Oktober 2026
  static String formatWithDay(DateTime date) {
    final dayName = _days[date.weekday - 1];
    return '$dayName, ${formatFull(date)}';
  }

  /// Generates a friendly Indonesian greeting based on the current local hour
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  /// Checks whether two dates fall in the same month and year
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
