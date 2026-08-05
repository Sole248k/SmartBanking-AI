import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static const String currencySymbol = '₱';
  static const String currencyLocale = 'en_PH';

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: currencyLocale,
    symbol: currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: currencyLocale,
    symbol: currencySymbol,
    decimalDigits: 1,
  );

  static final NumberFormat _noDecimalFormatter = NumberFormat.currency(
    locale: currencyLocale,
    symbol: currencySymbol,
    decimalDigits: 0,
  );

  /// Format as full currency: ₱12,345.00
  static String format(double amount) => _formatter.format(amount);

  /// Format compact: ₱12.3K
  static String compact(double amount) => _compactFormatter.format(amount);

  /// Format without decimals: ₱12,345
  static String noDecimal(double amount) => _noDecimalFormatter.format(amount);

  /// Parse currency string back to double
  static double? parse(String value) {
    try {
      final cleaned = value.replaceAll(currencySymbol, '').replaceAll(',', '').trim();
      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Return colored sign prefix for transactions
  static String signedFormat(double amount) {
    return amount >= 0 ? '+${format(amount)}' : format(amount);
  }
}
