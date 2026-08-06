import '../../transfer/repositories/transfer_repository.dart';
import 'qr_data.dart';

/// Passed as GoRouter [extra] from [QrScannerScreen] to [QrTransferReviewScreen].
///
/// Carries the raw decoded payload ([qrData]) plus the Firestore-verified
/// recipient identity ([recipient]).  If Firestore has no matching account the
/// reviewer falls back to the QR payload fields only.
class QrTransferArgs {
  const QrTransferArgs({
    required this.qrData,
    this.recipient,
  });

  /// Decoded and security-validated QR payload.
  final QrData qrData;

  /// Live recipient details fetched from the backend after scanning.
  /// Null when the account was not found in the local ecosystem (external bank).
  final RecipientDetails? recipient;

  // ── Convenience getters ────────────────────────────────────────────────────

  /// Best-available display name: backend name > QR name.
  String get resolvedName =>
      (recipient?.recipientName.isNotEmpty == true)
          ? recipient!.recipientName
          : qrData.recipientName;

  /// Best-available account number: backend account > QR account.
  String get resolvedAccountNumber =>
      (recipient?.accountNumber.isNotEmpty == true)
          ? recipient!.accountNumber
          : qrData.accountNumber;

  /// Best-available bank name: backend bank > QR bankCode > default.
  String get resolvedBankName {
    if (recipient?.bankName.isNotEmpty == true) return recipient!.bankName;
    if (qrData.bankCode?.isNotEmpty == true) return qrData.bankCode!;
    return 'SmartBank AI';
  }

  /// Masked last-4 for display.
  String get maskedAccount {
    final raw = recipient?.maskedCardNumber ?? resolvedAccountNumber;
    if (raw.contains('****')) return raw; // already masked by server
    final clean = raw.replaceAll(RegExp(r'\s'), '');
    if (clean.length <= 4) return clean;
    return '**** ${clean.substring(clean.length - 4)}';
  }
}
