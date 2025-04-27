import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _displayDateTimeFormat = DateFormat(
    'dd MMM yyyy HH:mm',
  );

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  static String formatDisplayDateTime(DateTime dateTime) {
    return _displayDateTimeFormat.format(dateTime);
  }

  static DateTime? tryParse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }
}
