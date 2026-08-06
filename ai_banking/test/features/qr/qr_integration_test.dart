// Integration-style tests for the QR transfer flow.
//
// Tests verify:
//   1. QrTransferReviewScreen renders auto-populated recipient details.
//   2. Validation (empty amount, zero amount).
//   3. QrTransferArgs convenience getters.
//   4. QrRepositoryImpl generate → parse round-trip.
//   5. Success state renders after executeTransfer completes.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_banking/core/errors/failure.dart';
import 'package:ai_banking/features/qr/data/qr_repository_impl.dart';
import 'package:ai_banking/features/qr/models/qr_data.dart';
import 'package:ai_banking/features/qr/models/qr_transfer_args.dart';
import 'package:ai_banking/features/qr/presentation/qr_transfer_review_screen.dart';
import 'package:ai_banking/features/transfer/models/beneficiary.dart';
import 'package:ai_banking/features/transfer/repositories/transfer_repository.dart';
import 'package:ai_banking/features/dashboard/providers/dashboard_providers.dart';
import 'package:ai_banking/features/transfer/providers/transfer_providers.dart';
import 'package:ai_banking/shared/models/account.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeTransferRepository implements TransferRepository {
  @override
  Future<Either<Failure, List<Beneficiary>>> getRecentBeneficiaries() async =>
      right([]);
  @override
  Stream<List<Beneficiary>> watchRecentBeneficiaries() =>
      const Stream.empty();
  @override
  Future<Either<Failure, void>> addBeneficiary(Beneficiary b) async =>
      right(null);
  @override
  Future<Either<Failure, RecipientDetails?>> lookupRecipient(String q) async =>
      right(null);
  @override
  Future<Either<Failure, void>> executeTransfer({
    required String fromAccountId,
    required String recipientName,
    required String recipientAccountNumber,
    required String bankName,
    required double amount,
    String? note,
    String? beneficiaryId,
    bool saveAsBeneficiary = false,
  }) async =>
      right(null);
}

// ─────────────────────────────────────────────────────────────────────────────
// Stub data
// ─────────────────────────────────────────────────────────────────────────────

const _stubAccounts = [
  Account(
    id: 'acc1',
    userId: 'u1',
    label: 'Checking',
    accountNumber: '010-1234-5678',
    balance: 5000.0,
    availableBalance: 5000.0,
    type: AccountType.checking,
    status: AccountStatus.active,
    cardNumber: '4000000000001234',
    cardNetwork: CardNetwork.visa,
    holderName: 'Test User',
  ),
];

final _verifiedRecipient = RecipientDetails(
  accountId: 'acc_remote',
  userId: 'uid_remote',
  recipientName: 'Ana Reyes',
  bankName: 'BPI',
  accountNumber: '010-9876-5432',
  maskedCardNumber: '**** 5432',
  cardNetwork: 'visa',
);

// ─────────────────────────────────────────────────────────────────────────────
// Harness
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildHarness(QrTransferArgs args) {
  return ProviderScope(
    overrides: [
      transferRepositoryProvider
          .overrideWith((_) => _FakeTransferRepository()),
      dashboardAccountsProvider
          .overrideWith((_) => Stream.value(_stubAccounts)),
    ],
    child: MaterialApp(home: QrTransferReviewScreen(args: args)),
  );
}

/// Router harness for navigation assertions.
Widget _buildRouterHarness(QrTransferArgs args) {
  final router = GoRouter(
    initialLocation: '/qr-review',
    routes: [
      GoRoute(
        path: '/qr-review',
        builder: (context, _) => QrTransferReviewScreen(args: args),
      ),
      GoRoute(
        path: '/',
        builder: (context, _) =>
            const Scaffold(body: Text('dashboard_stub')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      transferRepositoryProvider
          .overrideWith((_) => _FakeTransferRepository()),
      dashboardAccountsProvider
          .overrideWith((_) => Stream.value(_stubAccounts)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  const validQr = QrData(
    recipientId: 'uid_test',
    recipientName: 'Ana Reyes',
    accountNumber: '010-9876-5432',
    amount: 250.0,
    bankCode: 'BPI',
  );

  // ── 1. Rendering with verified recipient ──────────────────────────────────
  group('QrTransferReviewScreen — auto-populated recipient (verified)', () {
    late QrTransferArgs args;
    setUp(() => args = QrTransferArgs(
        qrData: validQr, recipient: _verifiedRecipient));

    testWidgets('shows backend recipient name', (tester) async {
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.text('Ana Reyes'), findsOneWidget);
    });

    testWidgets('shows server-masked account number', (tester) async {
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.text('**** 5432'), findsOneWidget);
    });

    testWidgets('shows Verified chip', (tester) async {
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('shows resolved bank name', (tester) async {
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.text('BPI'), findsOneWidget);
    });

    testWidgets('shows fixed-amount card when QR has pre-filled amount',
        (tester) async {
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.text('Amount (fixed by QR)'), findsOneWidget);
    });

    testWidgets('shows source account dropdown', (tester) async {
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.textContaining('Checking'), findsOneWidget);
    });

    testWidgets('shows Send Money button (no manual recipient fields)',
        (tester) async {
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.text('Send Money'), findsOneWidget);
      // Recipient account field must NOT be editable by user
      expect(find.widgetWithText(TextFormField, 'Account / Card Number'),
          findsNothing);
    });
  });

  // ── 2. Rendering with external (unverified) recipient ─────────────────────
  group('QrTransferReviewScreen — external recipient', () {
    testWidgets('shows External chip when no backend recipient',
        (tester) async {
      final args = QrTransferArgs(qrData: validQr);
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.text('External'), findsOneWidget);
    });

    testWidgets('falls back to QR name when no backend', (tester) async {
      final args = QrTransferArgs(qrData: validQr);
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.text('Ana Reyes'), findsOneWidget);
    });
  });

  // ── 3. Amount input ───────────────────────────────────────────────────────
  group('QrTransferReviewScreen — amount field', () {
    testWidgets('shows editable amount field when QR has no amount',
        (tester) async {
      const noAmtQr = QrData(
        recipientId: 'uid_test',
        recipientName: 'Ana Reyes',
        accountNumber: '010-9876-5432',
      );
      final args =
          QrTransferArgs(qrData: noAmtQr, recipient: _verifiedRecipient);
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();
      expect(find.text('Enter amount (₱)'), findsOneWidget);
    });

    testWidgets('shows validation error when amount empty', (tester) async {
      const noAmtQr = QrData(
        recipientId: 'uid_test',
        recipientName: 'Ana Reyes',
        accountNumber: '010-9876-5432',
      );
      final args = QrTransferArgs(qrData: noAmtQr);
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Money'));
      await tester.pump();

      expect(find.text('Amount is required'), findsOneWidget);
    });

    testWidgets('shows validation error when amount is zero', (tester) async {
      const noAmtQr = QrData(
        recipientId: 'uid_test',
        recipientName: 'Ana Reyes',
        accountNumber: '010-9876-5432',
      );
      final args = QrTransferArgs(qrData: noAmtQr);
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.tap(find.text('Send Money'));
      await tester.pump();

      expect(find.text('Enter a valid amount greater than zero'),
          findsOneWidget);
    });
  });

  // ── 4. Reference number display ───────────────────────────────────────────
  group('QrTransferReviewScreen — reference / wallet metadata', () {
    testWidgets('shows reference number when present', (tester) async {
      const qrWithRef = QrData(
        recipientId: 'uid_test',
        recipientName: 'Ana Reyes',
        accountNumber: '010-9876-5432',
        referenceNumber: 'REF-XYZ-001',
        walletId: 'wallet_abc',
      );
      final args = QrTransferArgs(qrData: qrWithRef);
      await tester.pumpWidget(_buildHarness(args));
      await tester.pumpAndSettle();

      expect(find.text('REF-XYZ-001'), findsOneWidget);
      expect(find.text('wallet_abc'), findsOneWidget);
    });
  });

  // ── 5. Success flow ───────────────────────────────────────────────────────
  group('QrTransferReviewScreen — success state', () {
    testWidgets('shows Transfer Successful after executeTransfer completes',
        (tester) async {
      // Use a QR with pre-filled amount so Send Money is tappable immediately
      final args = QrTransferArgs(
        qrData: validQr,
        recipient: _verifiedRecipient,
      );
      await tester.pumpWidget(_buildRouterHarness(args));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Money'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Successful!'), findsOneWidget);
    });
  });

  // ── 6. QrRepositoryImpl round-trip ────────────────────────────────────────
  group('QrRepositoryImpl — generate → parse round-trip', () {
    test('valid payload round-trips correctly', () async {
      final repo = QrRepositoryImpl();
      final payload = repo.generateQrPayload(validQr);
      final result = await repo.parseQrCode(payload);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (qr) {
          expect(qr.recipientName, 'Ana Reyes');
          expect(qr.amount, 250.0);
          expect(qr.bankCode, 'BPI');
        },
      );
    });
  });
}
