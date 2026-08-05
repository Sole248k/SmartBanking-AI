import 'package:flutter/material.dart';
import '../../shared/models/account.dart';

class CardUtils {
  CardUtils._();

  /// Detect Card Network from number prefix
  static CardNetwork detectCardNetwork(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return CardNetwork.visa;

    if (clean.startsWith('4')) {
      return CardNetwork.visa;
    }

    final firstTwo = int.tryParse(clean.substring(0, clean.length >= 2 ? 2 : clean.length)) ?? 0;
    final firstFour = int.tryParse(clean.substring(0, clean.length >= 4 ? 4 : clean.length)) ?? 0;

    if ((firstTwo >= 51 && firstTwo <= 55) || (firstFour >= 2221 && firstFour <= 2720)) {
      return CardNetwork.mastercard;
    }
    if (firstTwo == 34 || firstTwo == 37) {
      return CardNetwork.amex;
    }
    if (firstFour == 6011 || (firstTwo >= 64 && firstTwo <= 65) || firstTwo == 60) {
      return CardNetwork.discover;
    }
    if (firstFour >= 3528 && firstFour <= 3589) {
      return CardNetwork.jcb;
    }

    return CardNetwork.visa;
  }

  /// Luhn Algorithm Check
  static bool validateLuhn(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 13 || clean.length > 19) return false;

    int sum = 0;
    bool isSecond = false;
    for (int i = clean.length - 1; i >= 0; i--) {
      int d = int.parse(clean[i]);
      if (isSecond) {
        d = d * 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      isSecond = !isSecond;
    }
    return (sum % 10 == 0);
  }

  /// Expiry Date validation (MM/YY)
  static bool validateExpiry(String expiry) {
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(expiry)) return false;
    final parts = expiry.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');

    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0); // last day of month
    return expiryDate.isAfter(now);
  }

  /// CVV validation length based on card network
  static bool validateCVV(String cvv, CardNetwork network) {
    final clean = cvv.replaceAll(RegExp(r'\D'), '');
    if (network == CardNetwork.amex) {
      return clean.length == 4;
    }
    return clean.length == 3;
  }

  /// Format Card Number with spaces as user types
  static String formatCardNumber(String input, CardNetwork network) {
    final clean = input.replaceAll(RegExp(r'\D'), '');
    final maxLen = network == CardNetwork.amex ? 15 : 16;
    final trimmed = clean.length > maxLen ? clean.substring(0, maxLen) : clean;

    if (network == CardNetwork.amex) {
      // 4 - 6 - 5
      final buffer = StringBuffer();
      for (int i = 0; i < trimmed.length; i++) {
        if (i == 4 || i == 10) buffer.write(' ');
        buffer.write(trimmed[i]);
      }
      return buffer.toString();
    } else {
      // 4 - 4 - 4 - 4
      final buffer = StringBuffer();
      for (int i = 0; i < trimmed.length; i++) {
        if (i > 0 && i % 4 == 0) buffer.write(' ');
        buffer.write(trimmed[i]);
      }
      return buffer.toString();
    }
  }

  /// Mask Card Number (e.g., •••• •••• •••• 1234)
  static String maskCardNumber(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 4) return '•••• •••• •••• ••••';
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• •••• $last4';
  }

  /// Get Gradient Colors for Card Network / Bank
  static List<String> getCardGradient(CardNetwork network, String bankName) {
    if (bankName.toLowerCase().contains('eastwest') || bankName.toLowerCase().contains('east west')) {
      return ['#8A1B6A', '#4A0033'];
    }
    if (bankName.toLowerCase().contains('bdo')) {
      return ['#003399', '#001A4D'];
    }
    if (bankName.toLowerCase().contains('bpi')) {
      return ['#B30000', '#660000'];
    }
    if (bankName.toLowerCase().contains('metrobank')) {
      return ['#002B49', '#005596'];
    }
    if (bankName.toLowerCase().contains('gcash')) {
      return ['#0052FF', '#002B80'];
    }
    if (bankName.toLowerCase().contains('maya')) {
      return ['#00D66C', '#006633'];
    }
    switch (network) {
      case CardNetwork.mastercard:
        return ['#FF5F00', '#EB001B'];
      case CardNetwork.amex:
        return ['#006FCF', '#002663'];
      case CardNetwork.discover:
      case CardNetwork.discovery:
        return ['#FF6000', '#B34300'];
      case CardNetwork.jcb:
        return ['#006000', '#003300'];
      case CardNetwork.visa:
      default:
        return ['#0A84FF', '#5E5CE6'];
    }
  }

  /// Get display name for Card Network
  static String getNetworkName(CardNetwork network) {
    switch (network) {
      case CardNetwork.visa:
        return 'Visa';
      case CardNetwork.mastercard:
        return 'Mastercard';
      case CardNetwork.amex:
        return 'American Express';
      case CardNetwork.discover:
      case CardNetwork.discovery:
        return 'Discover';
      case CardNetwork.jcb:
        return 'JCB';
      case CardNetwork.unionpay:
        return 'UnionPay';
    }
  }
}
