import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/entities/kyc_record.dart';
import '../../providers/kyc_provider.dart';

class KycReviewScreen extends ConsumerWidget {
  const KycReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycState = ref.watch(kycControllerProvider);
    final record = kycState.record;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Information'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => ref.read(kycControllerProvider.notifier).setStep(KycStep.selfieCapture),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Personal Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _ReviewItem(label: 'Full Name', value: record.fullName ?? '—'),
                _ReviewItem(
                  label: 'Date of Birth',
                  value: record.dateOfBirth != null ? DateFormat('MMM dd, yyyy').format(record.dateOfBirth!) : '—',
                ),
                _ReviewItem(label: 'Nationality', value: record.nationality ?? '—'),
                _ReviewItem(label: 'Occupation', value: record.occupation ?? '—'),
                _ReviewItem(label: 'Address', value: record.address ?? '—'),
                
                const SizedBox(height: 32),
                Text(
                  'Identification',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _ReviewItem(label: 'ID Type', value: record.idType?.name.toUpperCase() ?? '—'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (record.idFrontUrl != null)
                      Expanded(
                        child: _ImagePreview(
                          label: 'Front Side',
                          path: record.idFrontUrl!,
                          onRetake: () => ref.read(kycControllerProvider.notifier).setStep(KycStep.idCaptureFront),
                        ),
                      ),
                    const SizedBox(width: 12),
                    if (record.idBackUrl != null)
                      Expanded(
                        child: _ImagePreview(
                          label: 'Back Side',
                          path: record.idBackUrl!,
                          onRetake: () => ref.read(kycControllerProvider.notifier).setStep(KycStep.idCaptureBack),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 32),
                Text(
                  'Facial Verification',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (record.selfieUrl != null)
                  _ImagePreview(
                    label: 'Selfie',
                    path: record.selfieUrl!,
                    onRetake: () => ref.read(kycControllerProvider.notifier).setStep(KycStep.selfieCapture),
                  ),
                
                const SizedBox(height: 40),
                if (kycState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      kycState.error!,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                
                ElevatedButton(
                  onPressed: kycState.isLoading ? null : () async {
                    await ref.read(kycControllerProvider.notifier).submitKyc();
                  },
                  child: kycState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Submit Verification'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String label;
  final String path;
  final VoidCallback onRetake;

  const _ImagePreview({
    required this.label,
    required this.path,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final isMock = path.startsWith('mock_');
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 120,
                color: colorScheme.surfaceVariant,
                child: isMock 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.image, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 4),
                          Text(
                            'Simulated Image',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : (kIsWeb 
                      ? Image.network(path, fit: BoxFit.cover)
                      : Image.file(File(path), fit: BoxFit.cover)),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: onRetake,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.refreshCcw, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
