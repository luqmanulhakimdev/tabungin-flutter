class DateFormatter {
  DateFormatter._();

  static const List<String> _monthsId = [
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

  static const List<String> _monthsEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _monthsShortId = [
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

  static const List<String> _monthsShortEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _daysId = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _daysEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static List<String> getMonths({bool isEnglish = false}) {
    return isEnglish ? _monthsEn : _monthsId;
  }

  /// Format: 20 Oktober 2026 / 20 October 2026
  static String formatFull(DateTime date, {bool isEnglish = false}) {
    final day = date.day;
    final months = isEnglish ? _monthsEn : _monthsId;
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  /// Format: 20 Okt 2026 / 20 Oct 2026
  static String formatShort(DateTime date, {bool isEnglish = false}) {
    final day = date.day;
    final months = isEnglish ? _monthsShortEn : _monthsShortId;
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  /// Format: Oktober 2026 / October 2026
  static String formatMonthYear(DateTime date, {bool isEnglish = false}) {
    final months = isEnglish ? _monthsEn : _monthsId;
    final month = months[date.month - 1];
    return '$month ${date.year}';
  }

  /// Format: Selasa, 20 Oktober 2026 / Tuesday, 20 October 2026
  static String formatWithDay(DateTime date, {bool isEnglish = false}) {
    final days = isEnglish ? _daysEn : _daysId;
    final dayName = days[date.weekday - 1];
    return '$dayName, ${formatFull(date, isEnglish: isEnglish)}';
  }

  /// Generates a friendly greeting based on current local hour and language
  static String getGreeting({bool isEnglish = false}) {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return isEnglish ? 'Good Morning' : 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return isEnglish ? 'Good Afternoon' : 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return isEnglish ? 'Good Evening' : 'Selamat Sore';
    } else {
      return isEnglish ? 'Good Night' : 'Selamat Malam';
    }
  }

  /// Checks whether two dates fall in the same month and year
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
