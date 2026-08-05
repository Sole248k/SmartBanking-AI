import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/entities/kyc_record.dart';
import '../../providers/kyc_provider.dart';
import '../widgets/kyc_progress_stepper.dart';

class IdCaptureScreen extends ConsumerStatefulWidget {
  final bool isFront;
  const IdCaptureScreen({super.key, required this.isFront});

  @override
  ConsumerState<IdCaptureScreen> createState() => _IdCaptureScreenState();
}

class _IdCaptureScreenState extends ConsumerState<IdCaptureScreen> {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _cameraFailed = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _cameraFailed = true;
      _isInitializing = false;
    } else {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _cameraFailed = true;
          _isInitializing = false;
        });
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) {
        setState(() {
          _cameraFailed = true;
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _uploadFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _processCapturedImage(image.path);
    }
  }

  Future<void> _capture() async {
    if (_cameraFailed) {
      _processCapturedImage('mock_path_${widget.isFront ? 'front' : 'back'}.jpg');
      return;
    }

    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final file = await _controller!.takePicture();
      _processCapturedImage(file.path);
    } catch (e) {
      debugPrint('Capture error: $e');
      _processCapturedImage('mock_path_${widget.isFront ? 'front' : 'back'}.jpg');
    }
  }

  void _processCapturedImage(String path) {
    final current = ref.read(kycControllerProvider).record;
    if (widget.isFront) {
      ref.read(kycControllerProvider.notifier).updateRecord(current.copyWith(idFrontUrl: path));
      if (current.idType == IdType.passport) {
        ref.read(kycControllerProvider.notifier).setStep(KycStep.selfieCapture);
      } else {
        ref.read(kycControllerProvider.notifier).setStep(KycStep.idCaptureBack);
      }
    } else {
      ref.read(kycControllerProvider.notifier).updateRecord(current.copyWith(idBackUrl: path));
      ref.read(kycControllerProvider.notifier).setStep(KycStep.selfieCapture);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(widget.isFront ? 'Front of ID' : 'Back of ID'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => ref.read(kycControllerProvider.notifier).setStep(
                widget.isFront ? KycStep.idSelection : KycStep.idCaptureFront,
              ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _uploadFromGallery,
            icon: const Icon(LucideIcons.upload, color: Colors.white),
            label: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          KycProgressStepper(currentStep: widget.isFront ? 2 : 3),
          Expanded(
            child: Stack(
              children: [
                if (_cameraFailed)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.cameraOff, size: 80, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          'Simulation Mode',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hardware camera unavailable on this device.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1 / (_controller?.value.aspectRatio ?? 1),
                      child: CameraPreview(_controller!),
                    ),
                  ),

                // ID Guide Overlay
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.9 * 0.63,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _cameraFailed
                        ? const Center(
                            child: Text(
                              'PLACE ID HERE',
                              style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        _cameraFailed ? 'Tap button to simulate capture' : 'Align your ID card within the frame',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _capture,
                        child: Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: _cameraFailed ? const Icon(LucideIcons.mousePointer, color: Colors.black) : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
