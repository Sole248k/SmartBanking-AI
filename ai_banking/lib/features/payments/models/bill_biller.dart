import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BillCategory
// ─────────────────────────────────────────────────────────────────────────────

enum BillCategory {
  electric,
  water,
  internet,
  mobile,
  creditCard,
  tuition,
  government,
  insurance,
  streaming,
  others,
}

extension BillCategoryInfo on BillCategory {
  String get label {
    switch (this) {
      case BillCategory.electric:
        return 'Electric';
      case BillCategory.water:
        return 'Water';
      case BillCategory.internet:
        return 'Internet';
      case BillCategory.mobile:
        return 'Mobile';
      case BillCategory.creditCard:
        return 'Credit Card';
      case BillCategory.tuition:
        return 'Tuition';
      case BillCategory.government:
        return 'Government';
      case BillCategory.insurance:
        return 'Insurance';
      case BillCategory.streaming:
        return 'Streaming';
      case BillCategory.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case BillCategory.electric:
        return Icons.electric_bolt_rounded;
      case BillCategory.water:
        return Icons.water_drop_rounded;
      case BillCategory.internet:
        return Icons.wifi_rounded;
      case BillCategory.mobile:
        return Icons.phone_android_rounded;
      case BillCategory.creditCard:
        return Icons.credit_card_rounded;
      case BillCategory.tuition:
        return Icons.school_rounded;
      case BillCategory.government:
        return Icons.account_balance_rounded;
      case BillCategory.insurance:
        return Icons.health_and_safety_rounded;
      case BillCategory.streaming:
        return Icons.play_circle_fill_rounded;
      case BillCategory.others:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case BillCategory.electric:
        return const Color(0xFFFFB800);
      case BillCategory.water:
        return const Color(0xFF0A84FF);
      case BillCategory.internet:
        return const Color(0xFF5E5CE6);
      case BillCategory.mobile:
        return const Color(0xFF30D158);
      case BillCategory.creditCard:
        return const Color(0xFFFF3B30);
      case BillCategory.tuition:
        return const Color(0xFFFF9500);
      case BillCategory.government:
        return const Color(0xFF34C759);
      case BillCategory.insurance:
        return const Color(0xFF64D2FF);
      case BillCategory.streaming:
        return const Color(0xFFBF5AF2);
      case BillCategory.others:
        return const Color(0xFF8E8E93);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BillBiller
// ─────────────────────────────────────────────────────────────────────────────

class BillBiller {
  const BillBiller({
    required this.id,
    required this.name,
    required this.category,
    required this.accountLabel,
    required this.accountHint,
    required this.accountPattern,
    this.fixedAmount,
    this.minAmount = 1.0,
    this.maxAmount = 50000.0,
    this.processingFee = 0.0,
    this.description = '',
    this.isFeatured = false,
    this.supportedPaymentChannels = const ['SmartBank AI'],
  });

  final String id;
  final String name;
  final BillCategory category;

  /// Field label shown to the user (e.g. "Customer ID", "Account Number")
  final String accountLabel;

  /// Hint text for the account/reference input field
  final String accountHint;

  /// RegExp pattern string — used to validate the account/reference field
  final String accountPattern;

  /// If non-null, the amount is fixed and not editable
  final double? fixedAmount;

  final double minAmount;
  final double maxAmount;

  /// Flat processing fee added to the payment (0 = free)
  final double processingFee;

  final String description;
  final bool isFeatured;
  final List<String> supportedPaymentChannels;

  IconData get icon => category.icon;
  Color get color => category.color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Master biller catalogue (mock data — all 20 billers)
// ─────────────────────────────────────────────────────────────────────────────

final kMockBillers = <BillBiller>[
  // ── Electric ──────────────────────────────────────────────────────────────
  const BillBiller(
    id: 'meralco',
    name: 'Meralco',
    category: BillCategory.electric,
    accountLabel: 'Customer ID',
    accountHint: 'e.g. 1234567890',
    accountPattern: r'^\d{10}$',
    minAmount: 100.0,
    maxAmount: 100000.0,
    description: 'Manila Electric Company',
    isFeatured: true,
  ),
  const BillBiller(
    id: 'visayan_electric',
    name: 'Visayan Electric',
    category: BillCategory.electric,
    accountLabel: 'Customer Account No.',
    accountHint: 'e.g. 100-12345-67',
    accountPattern: r'^\d{3}-\d{5}-\d{2}$',
    minAmount: 50.0,
    maxAmount: 50000.0,
    description: 'Visayan Electric Co., Inc.',
  ),

  // ── Water ─────────────────────────────────────────────────────────────────
  const BillBiller(
    id: 'manila_water',
    name: 'Manila Water',
    category: BillCategory.water,
    accountLabel: 'Account Number',
    accountHint: 'e.g. 0987654321',
    accountPattern: r'^\d{10}$',
    minAmount: 50.0,
    maxAmount: 30000.0,
    description: 'Manila Water Company',
    isFeatured: true,
  ),
  const BillBiller(
    id: 'maynilad',
    name: 'Maynilad Water',
    category: BillCategory.water,
    accountLabel: 'Customer No.',
    accountHint: 'e.g. 00123456789',
    accountPattern: r'^\d{11}$',
    minAmount: 50.0,
    maxAmount: 30000.0,
    description: 'Maynilad Water Services, Inc.',
  ),

  // ── Internet ──────────────────────────────────────────────────────────────
  const BillBiller(
    id: 'pldt',
    name: 'PLDT Home',
    category: BillCategory.internet,
    accountLabel: 'Account Number',
    accountHint: 'e.g. 5566778899',
    accountPattern: r'^\d{10}$',
    minAmount: 100.0,
    maxAmount: 20000.0,
    description: 'PLDT Home Broadband',
    isFeatured: true,
  ),
  const BillBiller(
    id: 'converge',
    name: 'Converge ICT',
    category: BillCategory.internet,
    accountLabel: 'Account Number',
    accountHint: 'e.g. 0010123456',
    accountPattern: r'^\d{10}$',
    minAmount: 100.0,
    maxAmount: 20000.0,
    description: 'Converge ICT Solutions, Inc.',
  ),
  const BillBiller(
    id: 'sky_broadband',
    name: 'Sky Broadband',
    category: BillCategory.internet,
    accountLabel: 'Account Number',
    accountHint: 'e.g. 8012345678',
    accountPattern: r'^\d{10}$',
    minAmount: 100.0,
    maxAmount: 20000.0,
    description: 'Sky Cable Corporation',
  ),

  // ── Mobile ────────────────────────────────────────────────────────────────
  const BillBiller(
    id: 'smart',
    name: 'Smart Postpaid',
    category: BillCategory.mobile,
    accountLabel: 'Mobile Number',
    accountHint: 'e.g. 09171234567',
    accountPattern: r'^09\d{9}$',
    minAmount: 99.0,
    maxAmount: 10000.0,
    description: 'Smart Communications, Inc.',
    isFeatured: true,
  ),
  const BillBiller(
    id: 'globe',
    name: 'Globe Postpaid',
    category: BillCategory.mobile,
    accountLabel: 'Mobile Number',
    accountHint: 'e.g. 09171234567',
    accountPattern: r'^09\d{9}$',
    minAmount: 99.0,
    maxAmount: 10000.0,
    description: 'Globe Telecom, Inc.',
    isFeatured: true,
  ),
  const BillBiller(
    id: 'dito',
    name: 'DITO Telecom',
    category: BillCategory.mobile,
    accountLabel: 'Mobile Number',
    accountHint: 'e.g. 09951234567',
    accountPattern: r'^09\d{9}$',
    minAmount: 50.0,
    maxAmount: 5000.0,
    description: 'DITO Telecommunity Corporation',
  ),

  // ── Credit Card ───────────────────────────────────────────────────────────
  const BillBiller(
    id: 'bpi_cc',
    name: 'BPI Credit Card',
    category: BillCategory.creditCard,
    accountLabel: 'Credit Card No.',
    accountHint: 'e.g. 4111111111111111',
    accountPattern: r'^\d{16}$',
    minAmount: 100.0,
    maxAmount: 200000.0,
    processingFee: 15.0,
    description: 'Bank of the Philippine Islands',
    isFeatured: true,
  ),
  const BillBiller(
    id: 'bdo_cc',
    name: 'BDO Credit Card',
    category: BillCategory.creditCard,
    accountLabel: 'Credit Card No.',
    accountHint: 'e.g. 4111111111111111',
    accountPattern: r'^\d{16}$',
    minAmount: 100.0,
    maxAmount: 200000.0,
    processingFee: 15.0,
    description: 'Banco de Oro Unibank, Inc.',
  ),

  // ── Tuition ───────────────────────────────────────────────────────────────
  const BillBiller(
    id: 'ateneo',
    name: 'Ateneo de Manila',
    category: BillCategory.tuition,
    accountLabel: 'Student ID',
    accountHint: 'e.g. 20200001',
    accountPattern: r'^\d{8}$',
    minAmount: 500.0,
    maxAmount: 200000.0,
    description: 'Ateneo de Manila University',
  ),
  const BillBiller(
    id: 'up',
    name: 'UP System',
    category: BillCategory.tuition,
    accountLabel: 'Student No.',
    accountHint: 'e.g. 2020-12345',
    accountPattern: r'^\d{4}-\d{5}$',
    minAmount: 500.0,
    maxAmount: 100000.0,
    description: 'University of the Philippines',
  ),

  // ── Government ────────────────────────────────────────────────────────────
  const BillBiller(
    id: 'sss',
    name: 'SSS Contribution',
    category: BillCategory.government,
    accountLabel: 'SS Number',
    accountHint: 'e.g. 01-2345678-9',
    accountPattern: r'^\d{2}-\d{7}-\d{1}$',
    minAmount: 100.0,
    maxAmount: 10000.0,
    description: 'Social Security System',
  ),
  const BillBiller(
    id: 'philhealth',
    name: 'PhilHealth',
    category: BillCategory.government,
    accountLabel: 'PhilHealth ID No.',
    accountHint: 'e.g. 12-345678901-2',
    accountPattern: r'^\d{2}-\d{9}-\d{1}$',
    minAmount: 100.0,
    maxAmount: 5000.0,
    description: 'Philippine Health Insurance Corp.',
  ),

  // ── Insurance ─────────────────────────────────────────────────────────────
  const BillBiller(
    id: 'sunlife',
    name: 'Sun Life Philippines',
    category: BillCategory.insurance,
    accountLabel: 'Policy Number',
    accountHint: 'e.g. SL-12345678',
    accountPattern: r'^SL-\d{8}$',
    minAmount: 500.0,
    maxAmount: 100000.0,
    description: 'Sun Life of Canada Philippines, Inc.',
  ),

  // ── Streaming ─────────────────────────────────────────────────────────────
  const BillBiller(
    id: 'netflix',
    name: 'Netflix',
    category: BillCategory.streaming,
    accountLabel: 'Email Address',
    accountHint: 'e.g. you@example.com',
    accountPattern: r'^[^@]+@[^@]+\.[^@]+$',
    minAmount: 149.0,
    maxAmount: 2000.0,
    description: 'Netflix, Inc.',
  ),
  const BillBiller(
    id: 'youtube_premium',
    name: 'YouTube Premium',
    category: BillCategory.streaming,
    accountLabel: 'Email Address',
    accountHint: 'e.g. you@gmail.com',
    accountPattern: r'^[^@]+@[^@]+\.[^@]+$',
    minAmount: 149.0,
    maxAmount: 500.0,
    description: 'Google LLC',
  ),

  // ── Others ────────────────────────────────────────────────────────────────
  const BillBiller(
    id: 'barangay',
    name: 'Barangay Dues',
    category: BillCategory.others,
    accountLabel: 'Resident ID',
    accountHint: 'e.g. BRG-12345',
    accountPattern: r'^BRG-\d{5}$',
    minAmount: 50.0,
    maxAmount: 5000.0,
    description: 'Local Barangay Association',
  ),
];

/// Quick lookup by ID
BillBiller? findBillerById(String id) {
  try {
    return kMockBillers.firstWhere((b) => b.id == id);
  } catch (_) {
    return null;
  }
}
