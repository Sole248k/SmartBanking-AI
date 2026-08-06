import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ai_banking/core/errors/failure.dart';
import 'package:ai_banking/features/qr/data/qr_repository_impl.dart';
import 'package:ai_banking/features/qr/models/qr_data.dart';
import 'package:ai_banking/features/qr/models/qr_transfer_args.dart';
import 'package:ai_banking/features/qr/presentation/qr_transfer_review_screen.dart';
import 'package:ai_banking/features/transfer/models/beneficiary.dart';
import 'package:ai_banking/features/transfer/repositories/transfer_repository.dart';
import 'package:ai_banking/features/dashboard/providers/dashboard_providers.dart';
import 'package:ai_banking/features/qr/providers/qr_transfer_provider.dart';
import 'package:ai_banking/shared/models/account.dart';
import 'package:ai_banking/features/transfer/providers/transfer_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake transfer repository
// ─────────────────────────────────────────────────────────────────────────────

class _FakeTransferRepo implements TransferRepository {
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

Widget _buildSubject(QrTransferArgs args) {
  return ProviderScope(
    overrides: [
      transferRepositoryProvider.overrideWith((_) => _FakeTransferRepo()),
      dashboardAccountsProvider
          .overrideWith((_) => Stream.value(_stubAccounts)),
    ],
    child: MaterialApp(
      home: QrTransferReviewScreen(args: args),
    ),
  );
}

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Unit tests — QrRepositoryImpl
  // ─────────────────────────────────────────────────────────────────────────
  group('QrRepositoryImpl.parseQrCode', () {
    late QrRepositoryImpl repo;
    setUp(() => repo = QrRepositoryImpl());

    test('parses a valid minimal v1 payload', () async {
      final payload = jsonEncode({
        'recipientId': 'uid_abc',
        'recipientName': 'Juan dela Cruz',
        'accountNumber': '1001234567',
      });
      final result = await repo.parseQrCode(payload);
      expect(result.isRight(), true);
      result.fold((_) {}, (qr) {
        expect(qr.recipientId, 'uid_abc');
        expect(qr.recipientName, 'Juan dela Cruz');
        expect(qr.accountNumber, '1001234567');
        expect(qr.amount, isNull);
        expect(qr.version, '1');
      });
    });

    test('parses a full extended payload with all optional fields', () async {
      final payload = jsonEncode({
        'recipientId': 'uid_abc',
        'recipientName': 'Maria Santos',
        'accountNumber': '2009876543',
        'amount': 500.0,
        'note': 'Lunch payment',
        'walletId': 'wallet_xyz',
        'userId': 'user_xyz',
        'bankCode': 'BDO',
        'referenceNumber': 'REF-20240101',
        'expiresAt': DateTime.now()
            .toUtc()
            .add(const Duration(hours: 1))
            .toIso8601String(),
        'version': '1',
      });
      final result = await repo.parseQrCode(payload);
      expect(result.isRight(), true);
      result.fold((_) {}, (qr) {
        expect(qr.amount, 500.0);
        expect(qr.walletId, 'wallet_xyz');
        expect(qr.bankCode, 'BDO');
        expect(qr.referenceNumber, 'REF-20240101');
      });
    });

    test('rejects non-JSON string', () async {
      final result = await repo.parseQrCode('not-json-at-all');
      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, contains('Invalid QR code format')),
          (_) {});
    });

    test('rejects payload exceeding size limit', () async {
      final result = await repo.parseQrCode('x' * 5000);
      expect(result.isLeft(), true);
      result.fold(
          (f) => expect(f.message, contains('too large')), (_) {});
    });

    test('rejects payload missing recipientId', () async {
      final payload = jsonEncode(
          {'recipientName': 'Juan', 'accountNumber': '1001234567'});
      final result = await repo.parseQrCode(payload);
      expect(result.isLeft(), true);
      result.fold(
          (f) => expect(f.message, contains('recipientId')), (_) {});
    });

    test('rejects payload with empty recipientName', () async {
      final payload = jsonEncode({
        'recipientId': 'uid_abc',
        'recipientName': '   ',
        'accountNumber': '1001234567',
      });
      final result = await repo.parseQrCode(payload);
      expect(result.isLeft(), true);
      result.fold(
          (f) => expect(f.message, contains('recipientName')), (_) {});
    });

    test('strips unknown/injected keys from payload', () async {
      final payload = jsonEncode({
        'recipientId': 'uid_abc',
        'recipientName': 'Juan',
        'accountNumber': '1001234567',
        '__proto__': {'admin': true},
        'injectedField': 'malicious',
      });
      final result = await repo.parseQrCode(payload);
      expect(result.isRight(), true);
    });

    test('rejects expired QR code', () async {
      final payload = jsonEncode({
        'recipientId': 'uid_abc',
        'recipientName': 'Juan',
        'accountNumber': '1001234567',
        'expiresAt': DateTime.now()
            .toUtc()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
      });
      final result = await repo.parseQrCode(payload);
      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, contains('expired')), (_) {});
    });

    test('rejects QR with zero or negative amount', () async {
      final payload = jsonEncode({
        'recipientId': 'uid_abc',
        'recipientName': 'Juan',
        'accountNumber': '1001234567',
        'amount': -100.0,
      });
      final result = await repo.parseQrCode(payload);
      expect(result.isLeft(), true);
      result.fold(
          (f) => expect(f.message, contains('invalid amount')), (_) {});
    });

    test('generateQrPayload produces valid JSON that round-trips', () async {
      const qr = QrData(
        recipientId: 'uid_abc',
        recipientName: 'Juan',
        accountNumber: '1001234567',
        amount: 250.0,
      );
      final payload = repo.generateQrPayload(qr);
      final result = await repo.parseQrCode(payload);
      expect(result.isRight(), true);
      result.fold((_) {}, (parsed) {
        expect(parsed.recipientId, qr.recipientId);
        expect(parsed.amount, qr.amount);
      });
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // QrData model tests
  // ─────────────────────────────────────────────────────────────────────────
  group('QrData model', () {
    test('defaults version to "1"', () {
      const qr =
          QrData(recipientId: 'id', recipientName: 'Name', accountNumber: '123');
      expect(qr.version, '1');
    });

    test('serializes and deserializes all fields correctly', () {
      const qr = QrData(
        recipientId: 'id',
        recipientName: 'Name',
        accountNumber: '123',
        walletId: 'w1',
        userId: 'u1',
        bankCode: 'BPI',
        referenceNumber: 'REF-001',
        amount: 100.0,
        note: 'test',
        version: '1',
      );
      final restored = QrData.fromJson(qr.toJson());
      expect(restored.walletId, 'w1');
      expect(restored.bankCode, 'BPI');
      expect(restored.referenceNumber, 'REF-001');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // QrTransferArgs — convenience getters
  // ─────────────────────────────────────────────────────────────────────────
  group('QrTransferArgs', () {
    const baseQr = QrData(
      recipientId: 'uid_abc',
      recipientName: 'QR Name',
      accountNumber: '1001234567',
      bankCode: 'BPI',
    );

    test('resolvedName prefers backend recipientName over QR', () {
      final details = RecipientDetails(
        accountId: 'acc1',
        userId: 'u1',
        recipientName: 'Backend Name',
        bankName: 'Backend Bank',
        accountNumber: '1001234567',
        maskedCardNumber: '**** 4567',
        cardNetwork: 'visa',
      );
      final args = QrTransferArgs(qrData: baseQr, recipient: details);
      expect(args.resolvedName, 'Backend Name');
    });

    test('resolvedName falls back to QR name when no backend', () {
      final args = QrTransferArgs(qrData: baseQr);
      expect(args.resolvedName, 'QR Name');
    });

    test('resolvedBankName prefers backend, then QR bankCode, then default',
        () {
      // Backend wins
      final withBackend = QrTransferArgs(
        qrData: baseQr,
        recipient: RecipientDetails(
          accountId: 'a',
          userId: 'u',
          recipientName: 'N',
          bankName: 'Metrobank',
          accountNumber: '123',
          maskedCardNumber: '**** 3456',
          cardNetwork: 'visa',
        ),
      );
      expect(withBackend.resolvedBankName, 'Metrobank');

      // QR bankCode wins when no backend
      expect(QrTransferArgs(qrData: baseQr).resolvedBankName, 'BPI');

      // Default when neither
      const noBank =
          QrData(recipientId: 'x', recipientName: 'X', accountNumber: '9');
      expect(QrTransferArgs(qrData: noBank).resolvedBankName, 'SmartBank AI');
    });

    test('maskedAccount uses server masked number when present', () {
      final args = QrTransferArgs(
        qrData: baseQr,
        recipient: RecipientDetails(
          accountId: 'a',
          userId: 'u',
          recipientName: 'N',
          bankName: 'B',
          accountNumber: '1001234567',
          maskedCardNumber: '**** **** **** 4567',
          cardNetwork: 'visa',
        ),
      );
      expect(args.maskedAccount, '**** **** **** 4567');
    });

    test('maskedAccount derives last-4 when no server mask', () {
      final args = QrTransferArgs(qrData: baseQr);
      expect(args.maskedAccount, '**** 4567');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Widget tests — QrTransferReviewScreen
  // ─────────────────────────────────────────────────────────────────────────
  group('QrTransferReviewScreen', () {
    const baseQr = QrData(
      recipientId: 'uid_abc',
      recipientName: 'Maria Santos',
      accountNumber: '1001234567',
    );

    testWidgets('renders recipient name and masked account', (tester) async {
      await tester.pumpWidget(
          _buildSubject(QrTransferArgs(qrData: baseQr)));
      await tester.pump();

      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('**** 4567'), findsOneWidget);
    });

    testWidgets('shows Verified chip for backend-confirmed recipient',
        (tester) async {
      final args = QrTransferArgs(
        qrData: baseQr,
        recipient: RecipientDetails(
          accountId: 'acc1',
          userId: 'u1',
          recipientName: 'Maria Santos',
          bankName: 'BPI',
          accountNumber: '1001234567',
          maskedCardNumber: '**** 4567',
          cardNetwork: 'visa',
        ),
      );
      await tester.pumpWidget(_buildSubject(args));
      await tester.pump();
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('shows External chip when no backend recipient',
        (tester) async {
      await tester.pumpWidget(
          _buildSubject(QrTransferArgs(qrData: baseQr)));
      await tester.pump();
      expect(find.text('External'), findsOneWidget);
    });

    testWidgets('shows amount field when QR has no pre-filled amount',
        (tester) async {
      await tester.pumpWidget(
          _buildSubject(QrTransferArgs(qrData: baseQr)));
      await tester.pump();
      expect(find.text('Enter amount (₱)'), findsOneWidget);
    });

    testWidgets('shows fixed amount card when QR has pre-filled amount',
        (tester) async {
      const qrWithAmt = QrData(
        recipientId: 'uid_abc',
        recipientName: 'Juan',
        accountNumber: '1001234567',
        amount: 500.0,
      );
      await tester.pumpWidget(
          _buildSubject(QrTransferArgs(qrData: qrWithAmt)));
      await tester.pump();
      expect(find.text('Amount (fixed by QR)'), findsOneWidget);
    });

    testWidgets(
        'shows validation error when amount is empty and user taps Send Money',
        (tester) async {
      await tester.pumpWidget(
          _buildSubject(QrTransferArgs(qrData: baseQr)));
      await tester.pump();

      await tester.tap(find.text('Send Money'));
      await tester.pump();

      expect(find.text('Amount is required'), findsOneWidget);
    });

    testWidgets('shows reference number when present', (tester) async {
      const qrWithRef = QrData(
        recipientId: 'uid_abc',
        recipientName: 'Juan',
        accountNumber: '1001234567',
        referenceNumber: 'REF-20240101',
      );
      await tester.pumpWidget(
          _buildSubject(QrTransferArgs(qrData: qrWithRef)));
      await tester.pump();
      expect(find.text('REF-20240101'), findsOneWidget);
    });

    testWidgets('QrTransferState resets on screen entry', (tester) async {
      final container = ProviderContainer(
        overrides: [
          transferRepositoryProvider.overrideWith((_) => _FakeTransferRepo()),
          dashboardAccountsProvider
              .overrideWith((_) => Stream.value(_stubAccounts)),
        ],
      );
      addTearDown(container.dispose);

      // Seed a stale error state
      container.read(qrTransferNotifierProvider.notifier).setAmount(99.0);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: QrTransferReviewScreen(
                args: QrTransferArgs(qrData: baseQr)),
          ),
        ),
      );
      await tester.pump();

      // After build callback, state should be reset
      final state = container.read(qrTransferNotifierProvider);
      expect(state.step, QrTransferStep.review);
    });
  });
}
