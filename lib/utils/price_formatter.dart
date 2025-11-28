import 'package:intl/intl.dart';

class PriceFormatter {
  static String format(dynamic price) {
    if (price == null) return '₱0.00';

    double value;
    if (price is double) {
      value = price;
    } else if (price is int) {
      value = price.toDouble();
    } else if (price is String) {
      // Remove existing currency symbols and commas before parsing
      String cleanPrice = price.replaceAll(RegExp(r'[₱, ]'), '');
      value = double.tryParse(cleanPrice) ?? 0.0;
    } else {
      value = 0.0;
    }

    final formatter = NumberFormat("#,##0.00", "en_US");
    return '₱${formatter.format(value)}';
  }
}
