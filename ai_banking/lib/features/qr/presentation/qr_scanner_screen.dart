import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../app/constants/app_constants.dart';
import '../../transfer/providers/transfer_providers.dart';
import '../../transfer/models/beneficiary.dart';
import '../providers/qr_providers.dart';

class QrScannerScreen extends ConsumerWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  final result = await ref.read(qrRepositoryProvider).parseQrCode(barcode.rawValue!);
                  result.fold(
                    (failure) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(failure.message)),
                    ),
                    (qrData) {
                      // Pre-fill transfer and navigate
                      final beneficiary = Beneficiary(
                        id: qrData.recipientId,
                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                        name: qrData.recipientName,
                        accountNumber: qrData.accountNumber,
                        bankName: 'SmartBank',
                      );
                      ref.read(transferControllerProvider.notifier).selectBeneficiary(beneficiary);
                      if (qrData.amount != null) {
                        ref.read(transferControllerProvider.notifier).setAmount(qrData.amount!);
                      }
                      context.pushReplacement('/transfer');
                    },
                  );
                  break;
                }
              }
            },
          ),
          // Scanner Overlay
          _buildOverlay(context),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
            ),
            const SizedBox(height: AppConstants.xl),
            const Text(
              'Align QR code within the frame',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
