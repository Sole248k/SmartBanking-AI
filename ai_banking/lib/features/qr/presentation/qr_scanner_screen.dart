import 'dart:async';
// ignore_for_file: prefer_const_constructors
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../app/constants/app_constants.dart';
import '../../transfer/providers/transfer_providers.dart';
import '../models/qr_data.dart';
import '../models/qr_transfer_args.dart';
import '../providers/qr_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Scanner overlay — dark mask with transparent cutout
// ─────────────────────────────────────────────────────────────────────────────

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({
    required this.frameSize,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
  });

  final double frameSize;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = frameSize / 2;

    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - half, cy - half, cx + half, cy + half),
      Radius.circular(borderRadius),
    );

    final maskPaint = Paint()..color = Colors.black.withValues(alpha: 0.62);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(frameRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, maskPaint);

    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cLen = 24.0;
    final l = cx - half;
    final t = cy - half;
    final r = cx + half;
    final b = cy + half;
    final cr = borderRadius;

    // Top-left
    canvas.drawLine(Offset(l + cr, t), Offset(l + cr + cLen, t), cornerPaint);
    canvas.drawLine(Offset(l, t + cr), Offset(l, t + cr + cLen), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(l, t, cr * 2, cr * 2), -3.14159, 3.14159 / 2, false, cornerPaint);
    // Top-right
    canvas.drawLine(Offset(r - cr - cLen, t), Offset(r - cr, t), cornerPaint);
    canvas.drawLine(Offset(r, t + cr), Offset(r, t + cr + cLen), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(r - cr * 2, t, cr * 2, cr * 2), -3.14159 / 2, 3.14159 / 2, false, cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(l + cr, b), Offset(l + cr + cLen, b), cornerPaint);
    canvas.drawLine(Offset(l, b - cr - cLen), Offset(l, b - cr), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(l, b - cr * 2, cr * 2, cr * 2), 3.14159 / 2, 3.14159 / 2, false, cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(r - cr - cLen, b), Offset(r - cr, b), cornerPaint);
    canvas.drawLine(Offset(r, b - cr - cLen), Offset(r, b - cr), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(r - cr * 2, b - cr * 2, cr * 2, cr * 2), 0, 3.14159 / 2, false, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter old) =>
      old.frameSize != frameSize ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated scan line
// ─────────────────────────────────────────────────────────────────────────────

class _ScanLine extends StatefulWidget {
  const _ScanLine({required this.frameSize});
  final double frameSize;

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => CustomPaint(
        size: Size(widget.frameSize, widget.frameSize),
        painter: _LinePainter(progress: _anim.value),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.greenAccent.withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 1))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Processing stage — drives the label and overlay copy
// ─────────────────────────────────────────────────────────────────────────────

enum _ScanStage { scanning, parsing, lookingUp }

extension _ScanStageCopy on _ScanStage {
  String get headline {
    switch (this) {
      case _ScanStage.scanning:
        return 'Align the QR code within the frame';
      case _ScanStage.parsing:
        return 'Reading QR Code…';
      case _ScanStage.lookingUp:
        return 'Verifying recipient…';
    }
  }

  String get subtext {
    switch (this) {
      case _ScanStage.scanning:
        return 'Scanning happens automatically';
      case _ScanStage.parsing:
        return 'Please wait';
      case _ScanStage.lookingUp:
        return 'Fetching account details from server';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QrScannerScreen
//
// Full pipeline:
//   camera detect
//     → parse (QrRepositoryImpl — security, expiry, format checks)
//     → backend lookup (TransferRepository.lookupRecipient — Firestore)
//     → self-transfer guard
//     → navigate to QrTransferReviewScreen with QrTransferArgs
//
// The review screen is SELF-CONTAINED — it never bounces the user to the
// generic Send Money form.
// ─────────────────────────────────────────────────────────────────────────────

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _scannerCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  _ScanStage _stage = _ScanStage.scanning;
  bool _torchOn = false;

  bool get _isProcessing => _stage != _ScanStage.scanning;

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  // ── Pipeline ──────────────────────────────────────────────────────────────

  Future<void> _onDetect(String rawValue) async {
    if (_isProcessing) return;
    _setStage(_ScanStage.parsing);

    // Step 1 — Parse & validate QR payload
    final parseResult =
        await ref.read(qrRepositoryProvider).parseQrCode(rawValue);

    if (!mounted) return;

    parseResult.fold(
      (failure) {
        _setStage(_ScanStage.scanning);
        _showError('Invalid QR Code', failure.message);
      },
      (qrData) => unawaited(_lookupAndNavigate(qrData)),
    );
  }

  Future<void> _lookupAndNavigate(QrData qrData) async {
    _setStage(_ScanStage.lookingUp);

    // Step 2 — Connectivity check
    final online = await _isOnline();
    if (!mounted) return;
    if (!online) {
      _setStage(_ScanStage.scanning);
      _showError(
        'No Internet Connection',
        'Please check your network and try again.',
      );
      return;
    }

    // Step 3 — Backend recipient lookup by account number
    final lookupResult = await ref
        .read(transferRepositoryProvider)
        .lookupRecipient(qrData.accountNumber);

    if (!mounted) return;

    lookupResult.fold(
      (failure) {
        _setStage(_ScanStage.scanning);
        _showError('Recipient Lookup Failed', failure.message);
      },
      (recipient) {
        // Step 4 — Self-transfer guard (authoritative check via Firestore userId)
        if (recipient != null) {
          final currentUid = FirebaseAuth.instance.currentUser?.uid;
          if (currentUid != null && recipient.userId == currentUid) {
            _setStage(_ScanStage.scanning);
            _showError(
              'Self-Transfer Not Allowed',
              'You cannot transfer money to your own account.',
            );
            return;
          }
        }

        // Step 5 — Navigate: reset stage first to avoid double-processing
        _setStage(_ScanStage.scanning);
        context.pushReplacement(
          '/qr-transfer-review',
          extra: QrTransferArgs(qrData: qrData, recipient: recipient),
        );
      },
    );
  }

  // ── Gallery fallback ──────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      _setStage(_ScanStage.parsing);
      final BarcodeCapture? capture =
          await _scannerCtrl.analyzeImage(image.path);

      if (!mounted) return;

      final raw = capture?.barcodes.firstOrNull?.rawValue;
      if (raw == null) {
        _setStage(_ScanStage.scanning);
        _showError(
            'No QR Found', 'No QR code was detected in the selected image.');
        return;
      }
      await _onDetect(raw);
    } catch (e) {
      if (mounted) {
        _setStage(_ScanStage.scanning);
        _showError('Image Error', 'Failed to read image: $e');
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _toggleTorch() async {
    await _scannerCtrl.toggleTorch();
    if (mounted) setState(() => _torchOn = !_torchOn);
  }

  void _setStage(_ScanStage stage) {
    if (mounted) setState(() => _stage = stage);
  }

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  void _showError(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.error_outline_rounded,
            color: Colors.redAccent, size: 32),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    const frameSize = 260.0;
    const borderRadius = 16.0;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _torchOn
                  ? Icons.flashlight_on_rounded
                  : Icons.flashlight_off_rounded,
              color: _torchOn ? Colors.amber : Colors.white,
            ),
            tooltip: _torchOn ? 'Turn off torch' : 'Turn on torch',
            onPressed: _isProcessing ? null : _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
            tooltip: 'Pick from gallery',
            onPressed: _isProcessing ? null : _pickFromGallery,
          ),
          const SizedBox(width: AppConstants.xs),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera feed
          MobileScanner(
            controller: _scannerCtrl,
            onDetect: (capture) {
              final raw = capture.barcodes.firstOrNull?.rawValue;
              if (raw != null) _onDetect(raw);
            },
          ),

          // Cutout overlay
          CustomPaint(
            painter: _ScannerOverlayPainter(
              frameSize: frameSize,
              borderRadius: borderRadius,
              borderColor: Colors.white,
              borderWidth: 3.0,
            ),
          ),

          // Scan line — only visible when idle
          if (!_isProcessing)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: const _ScanLine(frameSize: frameSize),
              ),
            ),

          // Instruction / status label below the frame
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.22,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Column(
                key: ValueKey(_stage),
                children: [
                  Text(
                    _stage.headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppConstants.sm),
                  Text(
                    _stage.subtext,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Full-screen processing overlay (parsing / looking up)
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.72),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: AppConstants.md),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _stage == _ScanStage.lookingUp
                            ? 'Verifying recipient…'
                            : 'Reading QR Code…',
                        key: ValueKey(_stage),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
