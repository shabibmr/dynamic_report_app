import 'package:intl/intl.dart';

class NumberFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _quantityFormat = NumberFormat.decimalPattern();
  static final NumberFormat _percentFormat = NumberFormat.percentPattern();

  static String formatCurrency(num value) {
    return _currencyFormat.format(value);
  }

  static String formatQuantity(num value) {
    return _quantityFormat.format(value);
  }

  static String formatPercent(num value) {
    return _percentFormat.format(value);
  }

  static String formatDecimal(num value, {int decimalPlaces = 2}) {
    return value.toStringAsFixed(decimalPlaces);
  }

  static num? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return num.tryParse(value.replaceAll(RegExp(r'[^\d.-]'), ''));
  }
}
