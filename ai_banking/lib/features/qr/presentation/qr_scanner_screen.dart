import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../app/constants/app_constants.dart';
import '../models/qr_data.dart';
import '../providers/qr_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Scanner overlay painter — draws a dark mask with a transparent cutout so
// the camera feed is visible through the scanning frame.
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

    // Dark mask covering entire canvas
    final maskPaint = Paint()..color = Colors.black.withValues(alpha: 0.62);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(frameRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, maskPaint);

    // Corner brackets
    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cLen = 24.0; // corner arm length
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
// Animated scan line that sweeps inside the viewport
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
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.frameSize, widget.frameSize),
          painter: _LinePainter(progress: _anim.value),
        );
      },
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
// Main scanner screen
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
  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  // ── QR processing ─────────────────────────────────────────────────────────

  Future<void> _onDetect(String rawValue) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final result = await ref.read(qrRepositoryProvider).parseQrCode(rawValue);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isProcessing = false);
        _showError(failure.message);
      },
      _navigateToReview,
    );
  }

  void _navigateToReview(QrData qrData) {
    context.pushReplacement('/qr-transfer-review', extra: qrData);
  }

  // ── Gallery / image fallback ───────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isProcessing = true);

      // Analyse the image file with MobileScanner's analyzeImage
      final BarcodeCapture? capture =
          await _scannerCtrl.analyzeImage(image.path);

      if (!mounted) return;

      final raw = capture?.barcodes.firstOrNull?.rawValue;
      if (raw == null) {
        setState(() => _isProcessing = false);
        _showError('No QR code found in the selected image.');
        return;
      }

      await _onDetect(raw);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showError('Failed to read image: $e');
      }
    }
  }

  // ── Torch ─────────────────────────────────────────────────────────────────

  Future<void> _toggleTorch() async {
    await _scannerCtrl.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  // ── Error dialog ──────────────────────────────────────────────────────────

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Invalid QR Code'),
          ],
        ),
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
          // Torch toggle
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
              color: _torchOn ? Colors.amber : Colors.white,
            ),
            tooltip: _torchOn ? 'Turn off torch' : 'Turn on torch',
            onPressed: _toggleTorch,
          ),
          // Gallery picker
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
          // ── Live camera feed ──────────────────────────────────────────────
          MobileScanner(
            controller: _scannerCtrl,
            onDetect: (capture) {
              final raw = capture.barcodes.firstOrNull?.rawValue;
              if (raw != null) _onDetect(raw);
            },
          ),

          // ── Overlay with cutout ───────────────────────────────────────────
          CustomPaint(
            painter: _ScannerOverlayPainter(
              frameSize: frameSize,
              borderRadius: borderRadius,
              borderColor: Colors.white,
              borderWidth: 3.0,
            ),
          ),

          // ── Animated scan line inside frame ───────────────────────────────
          if (!_isProcessing)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: _ScanLine(frameSize: frameSize),
              ),
            ),

          // ── Instruction label below frame ─────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.22,
            left: 0,
            right: 0,
            child: const Column(
              children: [
                Text(
                  'Align the QR code within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppConstants.sm),
                Text(
                  'Scanning happens automatically',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Processing overlay ────────────────────────────────────────────
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.72),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: AppConstants.md),
                    Text(
                      'Processing QR Code…',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
