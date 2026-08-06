import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../models/bill_biller.dart';

part 'bill_payment_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payment step enum
// ─────────────────────────────────────────────────────────────────────────────

enum BillPaymentStep {
  /// Grid of categories + biller search/list
  selectBiller,

  /// Enter account/reference number + amount
  enterDetails,

  /// Review summary before confirming
  review,

  /// Processing spinner
  processing,

  /// Successful payment confirmation
  success,

  /// Payment failure with reason
  failure,
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class BillPaymentState {
  const BillPaymentState({
    this.step = BillPaymentStep.selectBiller,
    this.selectedCategory,
    this.selectedBiller,
    this.accountNumber = '',
    this.amount = 0.0,
    this.note = '',
    this.fromAccountId,
    this.errorMessage,
    this.referenceNumber,
    this.paidAt,
    this.searchQuery = '',
  });

  final BillPaymentStep step;
  final BillCategory? selectedCategory;
  final BillBiller? selectedBiller;
  final String accountNumber;
  final double amount;
  final String note;
  final String? fromAccountId;
  final String? errorMessage;

  /// Generated after a successful payment
  final String? referenceNumber;
  final DateTime? paidAt;

  /// Live search filter on the biller list
  final String searchQuery;

  bool get isLoading => step == BillPaymentStep.processing;

  /// Total charged to the user = amount + biller's processing fee
  double get totalCharge =>
      amount + (selectedBiller?.processingFee ?? 0.0);

  BillPaymentState copyWith({
    BillPaymentStep? step,
    BillCategory? selectedCategory,
    bool clearCategory = false,
    BillBiller? selectedBiller,
    bool clearBiller = false,
    String? accountNumber,
    double? amount,
    String? note,
    String? fromAccountId,
    String? errorMessage,
    bool clearError = false,
    String? referenceNumber,
    DateTime? paidAt,
    String? searchQuery,
  }) {
    return BillPaymentState(
      step: step ?? this.step,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedBiller:
          clearBiller ? null : (selectedBiller ?? this.selectedBiller),
      accountNumber: accountNumber ?? this.accountNumber,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      referenceNumber: referenceNumber ?? this.referenceNumber,
      paidAt: paidAt ?? this.paidAt,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
class BillPaymentNotifier extends _$BillPaymentNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  @override
  BillPaymentState build() => const BillPaymentState();

  // ── Navigation ─────────────────────────────────────────────────────────────

  void reset() => state = const BillPaymentState();

  void setSearchQuery(String q) =>
      state = state.copyWith(searchQuery: q.toLowerCase());

  void selectCategory(BillCategory category) {
    state = state.copyWith(
      selectedCategory: category,
      searchQuery: '',
    );
  }

  void clearCategory() {
    state = state.copyWith(clearCategory: true, searchQuery: '');
  }

  void selectBiller(BillBiller biller) {
    state = state.copyWith(
      selectedBiller: biller,
      step: BillPaymentStep.enterDetails,
      accountNumber: '',
      amount: biller.fixedAmount ?? 0.0,
      note: '',
      clearError: true,
    );
  }

  void backToSelectBiller() {
    state = state.copyWith(
      step: BillPaymentStep.selectBiller,
      clearError: true,
    );
  }

  void setAccountNumber(String v) =>
      state = state.copyWith(accountNumber: v, clearError: true);

  void setAmount(double v) =>
      state = state.copyWith(amount: v, clearError: true);

  void setNote(String v) => state = state.copyWith(note: v);

  void setFromAccount(String accountId) =>
      state = state.copyWith(fromAccountId: accountId);

  /// Validates the form and advances to the review step.
  String? validateAndReview() {
    final biller = state.selectedBiller;
    if (biller == null) return 'No biller selected.';

    final account = state.accountNumber.trim();
    if (account.isEmpty) {
      return '${biller.accountLabel} is required.';
    }
    final pattern = RegExp(biller.accountPattern);
    if (!pattern.hasMatch(account)) {
      return 'Invalid ${biller.accountLabel} format.';
    }

    if (state.amount <= 0) {
      return 'Please enter a valid amount.';
    }
    if (state.amount < biller.minAmount) {
      return 'Minimum payment is ₱${biller.minAmount.toStringAsFixed(0)}.';
    }
    if (state.amount > biller.maxAmount) {
      return 'Maximum payment is ₱${biller.maxAmount.toStringAsFixed(0)}.';
    }

    if (state.fromAccountId == null) {
      return 'Please select a source account.';
    }

    state = state.copyWith(
      step: BillPaymentStep.review,
      clearError: true,
    );
    return null; // no error
  }

  void backToEnterDetails() {
    state = state.copyWith(
      step: BillPaymentStep.enterDetails,
      clearError: true,
    );
  }

  // ── Payment execution ──────────────────────────────────────────────────────

  Future<void> confirmPayment() async {
    final biller = state.selectedBiller;
    final accountId = state.fromAccountId;
    if (biller == null || accountId == null) return;
    if (_uid == null) {
      state = state.copyWith(
        step: BillPaymentStep.failure,
        errorMessage: 'You must be logged in to pay bills.',
      );
      return;
    }

    state = state.copyWith(step: BillPaymentStep.processing, clearError: true);

    try {
      final total = state.totalCharge;
      final accountRef = _db.collection('accounts').doc(accountId);
      final txRef = _db.collection('transactions').doc();
      final refCode =
          'BP-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';

      final String? errorMsg = await _db.runTransaction((tx) async {
        final snap = await tx.get(accountRef);
        if (!snap.exists) return 'Source account not found.';

        final data = snap.data() as Map<String, dynamic>;
        final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;

        if (balance < total) {
          return 'Insufficient balance. Available: ₱${balance.toStringAsFixed(2)}.';
        }

        // Debit the account
        final newBalance = (balance - total).toDouble();
        tx.update(accountRef, {
          'balance': newBalance,
          'availableBalance': newBalance,
        });

        // Write transaction record
        final senderName =
            _auth.currentUser?.displayName ?? 'SmartBank User';
        final description = state.note.trim().isEmpty
            ? 'Bill Payment — ${biller.name}'
            : state.note.trim();

        tx.set(txRef, {
          'userId': _uid,
          'accountId': accountId,
          'title': 'Bill Payment — ${biller.name}',
          'description': description,
          'amount': total,
          'date': FieldValue.serverTimestamp(),
          'category': 'Bills',
          'status': 'completed',
          'type': 'debit',
          'senderName': senderName,
          'referenceNumber': refCode,
          'targetAccount': state.accountNumber.trim(),
          'targetBank': biller.name,
          'fee': biller.processingFee,
        });

        return null; // success
      });

      if (errorMsg != null) {
        state = state.copyWith(
          step: BillPaymentStep.failure,
          errorMessage: errorMsg,
        );
        return;
      }

      // Refresh dashboard providers
      ref.invalidate(dashboardAccountsProvider);
      ref.invalidate(recentTransactionsProvider);

      state = state.copyWith(
        step: BillPaymentStep.success,
        referenceNumber: refCode,
        paidAt: DateTime.now(),
        clearError: true,
      );
    } on FirebaseException catch (e) {
      debugPrint('[BillPayment] FirebaseException: ${e.message}');
      state = state.copyWith(
        step: BillPaymentStep.failure,
        errorMessage: 'Firebase error: ${e.message ?? 'Unknown error.'}',
      );
    } catch (e) {
      debugPrint('[BillPayment] Unexpected error: $e');
      state = state.copyWith(
        step: BillPaymentStep.failure,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  // ── Filtered biller list helpers ──────────────────────────────────────────

  List<BillBiller> get filteredBillers {
    final query = state.searchQuery.trim();
    final cat = state.selectedCategory;

    return kMockBillers.where((b) {
      final matchesCat = cat == null || b.category == cat;
      if (query.isEmpty) return matchesCat;
      return matchesCat &&
          (b.name.toLowerCase().contains(query) ||
              b.category.label.toLowerCase().contains(query) ||
              b.description.toLowerCase().contains(query));
    }).toList();
  }

  List<BillBiller> get featuredBillers =>
      kMockBillers.where((b) => b.isFeatured).toList();
}
