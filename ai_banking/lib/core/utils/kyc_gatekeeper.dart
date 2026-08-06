import 'package:flutter/material.dart';

enum KycGateStatus {
  notSubmitted,
  pending,
  approved,
  rejected,
  moreInfoRequired;

  static KycGateStatus parse(String? rawStatus) {
    if (rawStatus == null || rawStatus.trim().isEmpty) {
      return KycGateStatus.notSubmitted;
    }
    final lower = rawStatus.toLowerCase().trim();
    if (lower.contains('approve')) {
      return KycGateStatus.approved;
    }
    if (lower.contains('reject')) {
      return KycGateStatus.rejected;
    }
    if (lower.contains('more') || lower.contains('info')) {
      return KycGateStatus.moreInfoRequired;
    }
    if (lower.contains('pend') || lower.contains('review') || lower.contains('submitted')) {
      return KycGateStatus.pending;
    }
    return KycGateStatus.notSubmitted;
  }

  bool get isApproved => this == KycGateStatus.approved;

  String get bannerTitle {
    switch (this) {
      case KycGateStatus.approved:
        return 'Identity Verified (KYC Approved)';
      case KycGateStatus.pending:
        return 'KYC Verification Under Review';
      case KycGateStatus.rejected:
        return 'Identity Verification Declined';
      case KycGateStatus.moreInfoRequired:
        return 'Additional Documents Required';
      case KycGateStatus.notSubmitted:
        return 'Identity Verification (KYC) Required';
    }
  }

  String get bannerMessage {
    switch (this) {
      case KycGateStatus.approved:
        return 'Your identity verification is approved. You have full access to apply for banking products.';
      case KycGateStatus.pending:
        return 'Your identity verification is currently under review. Product applications will be available once your KYC has been approved.';
      case KycGateStatus.rejected:
        return 'Your identity verification was declined. Please review administrative feedback and resubmit your documents.';
      case KycGateStatus.moreInfoRequired:
        return 'Our compliance team has requested additional documents to complete your KYC verification.';
      case KycGateStatus.notSubmitted:
        return 'Complete your identity verification (KYC) before applying for banking products.';
    }
  }

  String get badgeText {
    switch (this) {
      case KycGateStatus.approved:
        return 'Verified';
      case KycGateStatus.pending:
        return 'KYC Pending';
      case KycGateStatus.rejected:
        return 'KYC Rejected';
      case KycGateStatus.moreInfoRequired:
        return 'Docs Needed';
      case KycGateStatus.notSubmitted:
        return 'KYC Required';
    }
  }

  String get ctaButtonText {
    switch (this) {
      case KycGateStatus.approved:
        return 'Apply Now';
      case KycGateStatus.pending:
        return 'Track KYC Status';
      case KycGateStatus.rejected:
        return 'Resubmit KYC';
      case KycGateStatus.moreInfoRequired:
        return 'Upload Requested Docs';
      case KycGateStatus.notSubmitted:
        return 'Complete KYC to Apply';
    }
  }

  Color get statusColor {
    switch (this) {
      case KycGateStatus.approved:
        return const Color(0xFF38A169);
      case KycGateStatus.pending:
        return const Color(0xFFDD6B20);
      case KycGateStatus.rejected:
        return const Color(0xFFE53E3E);
      case KycGateStatus.moreInfoRequired:
        return const Color(0xFFD69E2E);
      case KycGateStatus.notSubmitted:
        return const Color(0xFF3182CE);
    }
  }

  IconData get icon {
    switch (this) {
      case KycGateStatus.approved:
        return Icons.verified_user_rounded;
      case KycGateStatus.pending:
        return Icons.hourglass_top_rounded;
      case KycGateStatus.rejected:
        return Icons.gpp_bad_rounded;
      case KycGateStatus.moreInfoRequired:
        return Icons.document_scanner_rounded;
      case KycGateStatus.notSubmitted:
        return Icons.security_rounded;
    }
  }
}
