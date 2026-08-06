// Integration-style tests for the full QR scan → review → transfer flow.
//
// These tests use faked repositories so no Firebase connections are required.
// They verify:
//   1. QrTransferReviewScreen renders recipient details correctly.
//   2. QrTransferReviewScreen resets the TransferController before populating
//      (task 3 regression guard).
//   3. "Continue to Confirm" navigates to /transfer when amount is valid.
//   4. QrRepositoryImpl round-trip (generate → parse).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_banking/core/errors/failure.dart';
import 'package:ai_banking/features/qr/data/qr_repository_impl.dart';
import 'package:ai_banking/features/qr/models/qr_data.dart';
import 'package:ai_banking/features/qr/presentation/qr_transfer_review_screen.dart';
import 'package:ai_banking/features/transfer/models/beneficiary.dart';
import 'package:ai_banking/features/transfer/models/transfer_state.dart';
import 'package:ai_banking/features/transfer/providers/transfer_providers.dart';
import 'package:ai_banking/features/transfer/repositories/transfer_repository.dart';
import 'package:ai_banking/shared/models/account.dart';
import 'package:ai_banking/features/dashboard/providers/dashboard_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeTransferRepository implements TransferRepository {
  @override
  Future<Either<Failure, List<Beneficiary>>> getRecentBeneficiaries() async =>
      right([]);

  @override
  Stream<List<Beneficiary>> watchRecentBeneficiaries() => const Stream.empty();

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

// ─────────────────────────────────────────────────────────────────────────────
// Harness
// ─────────────────────────────────────────────────────────────────────────────

/// Router-wrapped harness — lets us assert navigation to /transfer.
Widget _buildRouterHarness(QrData qrData) {
  final router = GoRouter(
    initialLocation: '/qr-review',
    routes: [
      GoRoute(
        path: '/qr-review',
        builder: (context, _) => QrTransferReviewScreen(qrData: qrData),
      ),
      GoRoute(
        path: '/transfer',
        builder: (context, _) =>
            const Scaffold(body: Text('transfer_screen_stub')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      transferRepositoryProvider.overrideWith((_) => _FakeTransferRepository()),
      dashboardAccountsProvider.overrideWith((_) => Stream.value(_stubAccounts)),
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

  // ── 1. Rendering ──────────────────────────────────────────────────────────
  group('QrTransferReviewScreen — rendering', () {
    testWidgets('shows recipient name, masked account, and QR Verified chip',
        (tester) async {
      await tester.pumpWidget(_buildRouterHarness(validQr));
      await tester.pumpAndSettle();

      expect(find.text('Ana Reyes'), findsOneWidget);
      expect(find.text('**** 5432'), findsOneWidget);
      expect(find.text('QR Verified'), findsOneWidget);
    });

    testWidgets('shows fixed-amount card when QR has pre-filled amount',
        (tester) async {
      await tester.pumpWidget(_buildRouterHarness(validQr));
      await tester.pumpAndSettle();

      expect(find.text('Amount (fixed by QR)'), findsOneWidget);
      expect(find.text('Amount (₱)'), findsNothing);
    });

    testWidgets('shows amount input field when QR has no amount',
        (tester) async {
      const noAmountQr = QrData(
        recipientId: 'uid_test',
        recipientName: 'Ana Reyes',
        accountNumber: '010-9876-5432',
      );
      await tester.pumpWidget(_buildRouterHarness(noAmountQr));
      await tester.pumpAndSettle();

      expect(find.text('Amount (₱)'), findsOneWidget);
    });

    testWidgets('shows source account dropdown', (tester) async {
      await tester.pumpWidget(_buildRouterHarness(validQr));
      await tester.pumpAndSettle();

      expect(find.textContaining('Checking'), findsOneWidget);
    });

    testWidgets('shows bank code and reference number when present',
        (tester) async {
      const qrWithRef = QrData(
        recipientId: 'uid_test',
        recipientName: 'Ana Reyes',
        accountNumber: '010-9876-5432',
        bankCode: 'BDO',
        referenceNumber: 'REF-XYZ',
      );
      await tester.pumpWidget(_buildRouterHarness(qrWithRef));
      await tester.pumpAndSettle();

      expect(find.text('BDO'), findsWidgets);
      expect(find.text('REF-XYZ'), findsOneWidget);
    });
  });

  // ── 2. Validation ─────────────────────────────────────────────────────────
  group('QrTransferReviewScreen — validation', () {
    testWidgets('shows error when amount is empty on submit', (tester) async {
      const noAmountQr = QrData(
        recipientId: 'uid_test',
        recipientName: 'Ana Reyes',
        accountNumber: '010-9876-5432',
      );
      await tester.pumpWidget(_buildRouterHarness(noAmountQr));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue to Confirm'));
      await tester.pump();

      expect(find.text('Amount is required'), findsOneWidget);
    });

    testWidgets('shows error when amount is zero', (tester) async {
      const noAmountQr = QrData(
        recipientId: 'uid_test',
        recipientName: 'Ana Reyes',
        accountNumber: '010-9876-5432',
      );
      await tester.pumpWidget(_buildRouterHarness(noAmountQr));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.tap(find.text('Continue to Confirm'));
      await tester.pump();

      expect(find.text('Enter a valid amount'), findsOneWidget);
    });
  });

  // ── 3. Task 3 regression: TransferController reset ────────────────────────
  group('QrTransferReviewScreen — TransferController reset (task 3)', () {
    testWidgets(
        'resets stale TransferController state then populates fresh values',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          transferRepositoryProvider.overrideWith((_) => _FakeTransferRepository()),
          dashboardAccountsProvider.overrideWith((_) => Stream.value(_stubAccounts)),
        ],
      );
      addTearDown(container.dispose);

      // Inject stale state
      container.read(transferControllerProvider.notifier).setRecipientDetails(
            recipientName: 'Old Name',
            recipientAccountNumber: '010-0000-0000',
            bankName: 'OldBank',
            amount: 999.0,
          );
      expect(
        container.read(transferControllerProvider).step,
        TransferStep.confirm,
        reason: 'Pre-condition: stale confirm step',
      );

      final router = GoRouter(
        initialLocation: '/qr-review',
        routes: [
          GoRoute(
            path: '/qr-review',
            builder: (context, _) => QrTransferReviewScreen(qrData: validQr),
          ),
          GoRoute(
            path: '/transfer',
            builder: (context, _) =>
                const Scaffold(body: Text('transfer_screen_stub')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue to Confirm'));
      await tester.pumpAndSettle();

      final state = container.read(transferControllerProvider);
      expect(state.recipientName, 'Ana Reyes',
          reason: 'New recipient populated after reset');
      expect(state.amount, 250.0);
      expect(state.step, TransferStep.confirm);
    });
  });

  // ── 4. Navigation ─────────────────────────────────────────────────────────
  group('QrTransferReviewScreen — navigation', () {
    testWidgets('navigates to /transfer after successful proceed',
        (tester) async {
      await tester.pumpWidget(_buildRouterHarness(validQr));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue to Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('transfer_screen_stub'), findsOneWidget);
    });
  });

  // ── 5. QrRepositoryImpl round-trip ────────────────────────────────────────
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

