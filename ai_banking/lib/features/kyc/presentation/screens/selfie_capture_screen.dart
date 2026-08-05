import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/entities/kyc_record.dart';
import '../../providers/kyc_provider.dart';
import '../widgets/kyc_progress_stepper.dart';

class SelfieCaptureScreen extends ConsumerStatefulWidget {
  const SelfieCaptureScreen({super.key});

  @override
  ConsumerState<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends ConsumerState<SelfieCaptureScreen> {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _cameraFailed = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  final ImagePicker _picker = ImagePicker();
  bool _isCapturing = false;

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
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        front,
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
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _uploadSelfie() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _finishSelfie(image.path);
    }
  }

  Future<void> _capture() async {
    if (_isCapturing) return;

    if (_cameraFailed) {
      _finishSelfie('mock_selfie_path.jpg');
      return;
    }

    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isCapturing = true);

    try {
      final file = await _controller!.takePicture();

      if (!kIsWeb) {
        try {
          final inputImage = InputImage.fromFilePath(file.path);
          final faces = await _faceDetector.processImage(inputImage);

          if (faces.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No face detected. Please ensure good lighting.')),
              );
              setState(() => _isCapturing = false);
            }
            return;
          }
        } catch (e) {
          debugPrint('ML Kit skipped: $e');
        }
      }

      _finishSelfie(file.path);
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        setState(() => _isCapturing = false);
        _finishSelfie('mock_selfie_path.jpg');
      }
    }
  }

  void _finishSelfie(String path) {
    final current = ref.read(kycControllerProvider).record;
    ref.read(kycControllerProvider.notifier).updateRecord(current.copyWith(selfieUrl: path));
    ref.read(kycControllerProvider.notifier).setStep(KycStep.review);
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
        title: const Text('Face Verification'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () {
            final record = ref.read(kycControllerProvider).record;
            ref.read(kycControllerProvider.notifier).setStep(
                  record.idType == IdType.passport ? KycStep.idCaptureFront : KycStep.idCaptureBack,
                );
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: _uploadSelfie,
            icon: const Icon(LucideIcons.upload, color: Colors.white),
            label: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          const KycProgressStepper(currentStep: 4),
          Expanded(
            child: Stack(
              children: [
                if (_cameraFailed)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.smile, size: 80, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text('Simulation Mode', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Front camera unavailable.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60)),
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

                // Face Oval Overlay
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.width * 0.75 * 1.3,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.primary, width: 3),
                      borderRadius: BorderRadius.all(Radius.elliptical(
                        MediaQuery.of(context).size.width * 0.375,
                        MediaQuery.of(context).size.width * 0.375 * 1.3,
                      )),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        _cameraFailed ? 'Tap button to simulate selfie' : 'Center your face inside the frame',
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
                          child: _isCapturing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _cameraFailed ? const Icon(LucideIcons.user, color: Colors.black) : null,
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
