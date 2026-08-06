import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transfer/providers/transfer_providers.dart';
import '../../transfer/repositories/transfer_repository.dart';
import '../../dashboard/providers/dashboard_providers.dart';

part 'qr_transfer_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

enum QrTransferStep { review, processing, success, error }

@immutable
class QrTransferState {
  const QrTransferState({
    this.step = QrTransferStep.review,
    this.amount,
    this.note,
    this.fromAccountId,
    this.errorMessage,
    this.referenceNumber,
  });

  final QrTransferStep step;
  final double? amount;
  final String? note;
  final String? fromAccountId;
  final String? errorMessage;
  final String? referenceNumber;

  bool get isLoading => step == QrTransferStep.processing;
  bool get isSuccess => step == QrTransferStep.success;
  bool get hasError => step == QrTransferStep.error;

  QrTransferState copyWith({
    QrTransferStep? step,
    double? amount,
    String? note,
    String? fromAccountId,
    String? errorMessage,
    String? referenceNumber,
  }) {
    return QrTransferState(
      step: step ?? this.step,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      errorMessage: errorMessage ?? this.errorMessage,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Manages state for the self-contained QR transfer flow.
///
/// This is intentionally separate from [TransferController] so QR transfers
/// have isolated state and don't bleed into or from the manual Send Money flow.
@riverpod
class QrTransferNotifier extends _$QrTransferNotifier {
  @override
  QrTransferState build() => const QrTransferState();

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void setNote(String note) {
    state = state.copyWith(note: note.isEmpty ? null : note);
  }

  void setFromAccount(String accountId) {
    state = state.copyWith(fromAccountId: accountId);
  }

  void reset() {
    state = const QrTransferState();
  }

  /// Executes the transfer using the existing [TransferRepository.executeTransfer].
  /// This is the ONLY place transfer logic runs for the QR flow — the review
  /// screen never navigates to the generic [TransferScreen].
  Future<void> executeTransfer({
    required RecipientDetails recipient,
    required String bankName,
    double? prefilledAmount,
  }) async {
    final amount = prefilledAmount ?? state.amount ?? 0.0;

    if (amount <= 0) {
      state = state.copyWith(
        step: QrTransferStep.error,
        errorMessage: 'Please enter a valid amount.',
      );
      return;
    }

    // Resolve source account: explicit selection > first available
    final accounts = ref.read(dashboardAccountsProvider).value ?? [];
    if (accounts.isEmpty) {
      state = state.copyWith(
        step: QrTransferStep.error,
        errorMessage: 'No source account found. Please try again.',
      );
      return;
    }
    final fromId = state.fromAccountId ?? accounts.first.id;

    state = state.copyWith(step: QrTransferStep.processing, errorMessage: null);

    final result = await ref.read(transferRepositoryProvider).executeTransfer(
          fromAccountId: fromId,
          recipientName: recipient.recipientName,
          recipientAccountNumber: recipient.accountNumber,
          bankName: bankName,
          amount: amount,
          note: state.note,
        );

    result.fold(
      (failure) {
        debugPrint('[QrTransfer] executeTransfer failed: ${failure.message}');
        state = state.copyWith(
          step: QrTransferStep.error,
          errorMessage: _friendlyError(failure.message),
        );
      },
      (_) {
        // Refresh dashboard data so balances update immediately
        ref.invalidate(dashboardAccountsProvider);
        ref.invalidate(recentTransactionsProvider);
        state = state.copyWith(step: QrTransferStep.success);
      },
    );
  }

  // ── Error mapping ──────────────────────────────────────────────────────────

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('insufficient')) {
      return 'Insufficient balance to complete this transfer.';
    }
    if (lower.contains('not found') || lower.contains('no such document')) {
      return 'Account not found. Please check the QR code and try again.';
    }
    if (lower.contains('network') || lower.contains('unavailable')) {
      return 'Network error. Please check your connection and try again.';
    }
    if (lower.contains('permission') || lower.contains('unauthorized')) {
      return 'Transfer not authorized. Please re-authenticate and try again.';
    }
    return 'Transfer failed. Please try again.';
  }
}
