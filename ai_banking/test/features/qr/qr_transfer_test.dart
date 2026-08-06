import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_banking/features/qr/data/qr_repository_impl.dart';
import 'package:ai_banking/features/qr/models/qr_data.dart';
import 'package:ai_banking/features/qr/presentation/qr_transfer_review_screen.dart';
import 'dart:convert';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Unit tests — QrRepositoryImpl
  // ─────────────────────────────────────────────────────────────────────────
  group('QrRepositoryImpl.parseQrCode', () {
    late QrRepositoryImpl repo;

    setUp(() => repo = QrRepositoryImpl());

    // ── Happy path ──────────────────────────────────────────────────────────
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
        'expiresAt': DateTime.now().toUtc().add(const Duration(hours: 1)).toIso8601String(),
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

    // ── Format validation ───────────────────────────────────────────────────
    test('rejects non-JSON string', () async {
      final result = await repo.parseQrCode('not-json-at-all');
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, contains('Invalid QR code format')),
        (_) {},
      );
    });

    test('rejects payload exceeding size limit', () async {
      final huge = 'x' * 5000;
      final result = await repo.parseQrCode(huge);
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, contains('too large')),
        (_) {},
      );
    });

    test('rejects payload missing recipientId', () async {
      final payload = jsonEncode({
        'recipientName': 'Juan',
        'accountNumber': '1001234567',
      });
      final result = await repo.parseQrCode(payload);
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, contains('recipientId')),
        (_) {},
      );
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
        (f) => expect(f.message, contains('recipientName')),
        (_) {},
      );
    });

    // ── Security ────────────────────────────────────────────────────────────
    test('strips unknown/injected keys from payload', () async {
      final payload = jsonEncode({
        'recipientId': 'uid_abc',
        'recipientName': 'Juan',
        'accountNumber': '1001234567',
        '__proto__': {'admin': true},
        'injectedField': 'malicious',
      });

      final result = await repo.parseQrCode(payload);
      // Should succeed but unknown keys are silently dropped
      expect(result.isRight(), true);
    });

    test('rejects expired QR code', () async {
      final payload = jsonEncode({
        'recipientId': 'uid_abc',
        'recipientName': 'Juan',
        'accountNumber': '1001234567',
        'expiresAt': DateTime.now().toUtc().subtract(const Duration(minutes: 5)).toIso8601String(),
      });

      final result = await repo.parseQrCode(payload);
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, contains('expired')),
        (_) {},
      );
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
        (f) => expect(f.message, contains('invalid amount')),
        (_) {},
      );
    });

    // ── generateQrPayload round-trip ────────────────────────────────────────
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
      const qr = QrData(
        recipientId: 'id',
        recipientName: 'Name',
        accountNumber: '123',
      );
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

      final json = qr.toJson();
      final restored = QrData.fromJson(json);

      expect(restored.walletId, 'w1');
      expect(restored.bankCode, 'BPI');
      expect(restored.referenceNumber, 'REF-001');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Widget tests — QrTransferReviewScreen
  // ─────────────────────────────────────────────────────────────────────────
  group('QrTransferReviewScreen', () {
    Widget buildSubject(QrData qrData) {
      return ProviderScope(
        child: MaterialApp(
          home: QrTransferReviewScreen(qrData: qrData),
        ),
      );
    }

    testWidgets('renders recipient name and masked account', (tester) async {
      const qr = QrData(
        recipientId: 'uid_abc',
        recipientName: 'Maria Santos',
        accountNumber: '1001234567',
      );

      await tester.pumpWidget(buildSubject(qr));
      await tester.pump();

      expect(find.text('Maria Santos'), findsOneWidget);
      // Masked: last 4 digits only
      expect(find.text('**** 4567'), findsOneWidget);
    });

    testWidgets('shows amount field when QR has no pre-filled amount',
        (tester) async {
      const qr = QrData(
        recipientId: 'uid_abc',
        recipientName: 'Juan',
        accountNumber: '1001234567',
      );

      await tester.pumpWidget(buildSubject(qr));
      await tester.pump();

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Amount (₱)'), findsOneWidget);
    });

    testWidgets('shows fixed amount card when QR has pre-filled amount',
        (tester) async {
      const qr = QrData(
        recipientId: 'uid_abc',
        recipientName: 'Juan',
        accountNumber: '1001234567',
        amount: 500.0,
      );

      await tester.pumpWidget(buildSubject(qr));
      await tester.pump();

      expect(find.text('Amount (fixed by QR)'), findsOneWidget);
      // Amount input field should NOT be present
      expect(find.text('Amount (₱)'), findsNothing);
    });

    testWidgets('shows validation error when amount is empty and user submits',
        (tester) async {
      const qr = QrData(
        recipientId: 'uid_abc',
        recipientName: 'Juan',
        accountNumber: '1001234567',
      );

      await tester.pumpWidget(buildSubject(qr));
      await tester.pump();

      await tester.tap(find.text('Continue to Confirm'));
      await tester.pump();

      expect(find.text('Amount is required'), findsOneWidget);
    });

    testWidgets('shows bank code and reference number when present',
        (tester) async {
      const qr = QrData(
        recipientId: 'uid_abc',
        recipientName: 'Juan',
        accountNumber: '1001234567',
        bankCode: 'BDO',
        referenceNumber: 'REF-20240101',
      );

      await tester.pumpWidget(buildSubject(qr));
      await tester.pump();

      expect(find.text('BDO'), findsOneWidget);
      expect(find.text('REF-20240101'), findsOneWidget);
    });
  });
}
