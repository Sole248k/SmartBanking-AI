import 'package:flutter/material.dart';
import '../../shared/models/account.dart';

class BankCardStyle {
  final String bankName;
  final List<Color> gradientColors;
  final Color accentColor;
  final Color textColor;
  final String? badgeText;

  const BankCardStyle({
    required this.bankName,
    required this.gradientColors,
    required this.accentColor,
    required this.textColor,
    this.badgeText,
  });
}

class BankCardTheme {
  BankCardTheme._();

  /// Retrieve full bank card styling by bank name
  static BankCardStyle getBankStyle(String bankName) {
    final name = bankName.toLowerCase();

    if (name.contains('eastwest') || name.contains('east west')) {
      return const BankCardStyle(
        bankName: 'EastWest Bank',
        gradientColors: [Color(0xFF5B1568), Color(0xFF2E0537)],
        accentColor: Color(0xFFFFB703),
        textColor: Colors.white,
      );
    }
    if (name.contains('bdo')) {
      return const BankCardStyle(
        bankName: 'BDO Unibank',
        gradientColors: [Color(0xFF003399), Color(0xFF001A4D)],
        accentColor: Color(0xFFFFCC00),
        textColor: Colors.white,
      );
    }
    if (name.contains('bpi')) {
      return const BankCardStyle(
        bankName: 'BPI',
        gradientColors: [Color(0xFF8B0000), Color(0xFF4A0000)],
        accentColor: Color(0xFFFFD700),
        textColor: Colors.white,
      );
    }
    if (name.contains('metrobank')) {
      return const BankCardStyle(
        bankName: 'Metrobank',
        gradientColors: [Color(0xFF004445), Color(0xFF001F20)],
        accentColor: Color(0xFF2C7A7B),
        textColor: Colors.white,
      );
    }
    if (name.contains('landbank') || name.contains('land bank')) {
      return const BankCardStyle(
        bankName: 'LandBank',
        gradientColors: [Color(0xFF0B4F26), Color(0xFF042612)],
        accentColor: Color(0xFF28A745),
        textColor: Colors.white,
      );
    }
    if (name.contains('pnb') || name.contains('philippine national')) {
      return const BankCardStyle(
        bankName: 'PNB',
        gradientColors: [Color(0xFF002B49), Color(0xFF001525)],
        accentColor: Color(0xFFD4AF37),
        textColor: Colors.white,
      );
    }
    if (name.contains('unionbank') || name.contains('union bank')) {
      return const BankCardStyle(
        bankName: 'UnionBank',
        gradientColors: [Color(0xFFF37021), Color(0xFF0C2340)],
        accentColor: Color(0xFFFF9F1C),
        textColor: Colors.white,
      );
    }
    if (name.contains('security bank')) {
      return const BankCardStyle(
        bankName: 'Security Bank',
        gradientColors: [Color(0xFF005691), Color(0xFF002D4C)],
        accentColor: Color(0xFF00A86B),
        textColor: Colors.white,
      );
    }
    if (name.contains('rcbc')) {
      return const BankCardStyle(
        bankName: 'RCBC',
        gradientColors: [Color(0xFF0066B2), Color(0xFF003366)],
        accentColor: Color(0xFF00C9FF),
        textColor: Colors.white,
      );
    }
    if (name.contains('chinabank') || name.contains('china bank')) {
      return const BankCardStyle(
        bankName: 'Chinabank',
        gradientColors: [Color(0xFF7A001E), Color(0xFF3D000F)],
        accentColor: Color(0xFFFFC107),
        textColor: Colors.white,
      );
    }
    if (name.contains('maya')) {
      return const BankCardStyle(
        bankName: 'Maya Bank',
        gradientColors: [Color(0xFF00D66C), Color(0xFF0D1117)],
        accentColor: Color(0xFF00FF7F),
        textColor: Colors.white,
      );
    }
    if (name.contains('gotyme') || name.contains('go tyme')) {
      return const BankCardStyle(
        bankName: 'GoTyme Bank',
        gradientColors: [Color(0xFF00E5FF), Color(0xFF0052CC)],
        accentColor: Color(0xFF00F0FF),
        textColor: Colors.white,
      );
    }
    if (name.contains('cimb')) {
      return const BankCardStyle(
        bankName: 'CIMB Bank',
        gradientColors: [Color(0xFFDC143C), Color(0xFF1A0000)],
        accentColor: Color(0xFFFF4500),
        textColor: Colors.white,
      );
    }
    if (name.contains('tonik')) {
      return const BankCardStyle(
        bankName: 'Tonik Bank',
        gradientColors: [Color(0xFF7B2CBF), Color(0xFF3D0066)],
        accentColor: Color(0xFFFF007F),
        textColor: Colors.white,
      );
    }
    if (name.contains('uno')) {
      return const BankCardStyle(
        bankName: 'UNO Digital Bank',
        gradientColors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
        accentColor: Color(0xFF00E5FF),
        textColor: Colors.white,
      );
    }
    if (name.contains('smartbank')) {
      return const BankCardStyle(
        bankName: 'SmartBank AI',
        gradientColors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
        accentColor: Color(0xFF64D2FF),
        textColor: Colors.white,
      );
    }

    // Default Fallback
    return BankCardStyle(
      bankName: bankName.isEmpty ? 'Bank Card' : bankName,
      gradientColors: const [Color(0xFF2D3748), Color(0xFF1A202C)],
      accentColor: const Color(0xFFA0AEC0),
      textColor: Colors.white,
    );
  }
}
