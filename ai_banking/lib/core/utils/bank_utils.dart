import 'dart:math';

class BankUtils {
  static final _random = Random();

  /// Generates a realistic 10-digit account number: 010-XXXX-XXXX
  static String generateAccountNumber() {
    final part1 = _random.nextInt(9000) + 1000;
    final part2 = _random.nextInt(9000) + 1000;
    return '010-$part1-$part2';
  }

  /// Generates a realistic 16-digit card number with spaces
  static String generateCardNumber({String network = 'visa'}) {
    final prefix = network.toLowerCase() == 'visa' ? '4' : '5';
    String number = prefix;
    for (int i = 0; i < 15; i++) {
      number += _random.nextInt(10).toString();
    }
    
    // Format with spaces: XXXX XXXX XXXX XXXX
    return '${number.substring(0, 4)} ${number.substring(4, 8)} ${number.substring(8, 12)} ${number.substring(12, 16)}';
  }

  /// Generates a 3-digit CVV code
  static String generateCVV() {
    return (_random.nextInt(900) + 100).toString();
  }

  /// Generates an expiry date 5 years from now in MM/YY format
  static String generateExpiryDate() {
    final now = DateTime.now();
    final year = (now.year + 5).toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    return '$month/$year';
  }
}
