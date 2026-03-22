import 'package:intl/intl.dart';

class AppNumberFormat {
  static final NumberFormat _vndFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0, // VND không có số lẻ
  );

  static String format(int amount) {
    return _vndFormatter.format(amount);
  }
}
