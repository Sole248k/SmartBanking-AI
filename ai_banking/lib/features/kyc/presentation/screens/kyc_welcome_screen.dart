import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/entities/kyc_record.dart';
import '../../providers/kyc_provider.dart';

class KycWelcomeScreen extends ConsumerWidget {
  const KycWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.shieldCheck,
                  color: Theme.of(context).colorScheme.primary,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Let\'s verify your identity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'To comply with banking regulations and secure your account, we need to verify your identity.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            const _KycStepItem(
              icon: LucideIcons.user,
              title: 'Personal Information',
              description: 'Your basic details and occupation',
            ),
            const _KycStepItem(
              icon: LucideIcons.creditCard,
              title: 'Valid ID capture',
              description: 'A photo of your government-issued ID',
            ),
            const _KycStepItem(
              icon: LucideIcons.smile,
              title: 'Face Verification',
              description: 'A quick live selfie check',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ref.read(kycControllerProvider.notifier).setStep(KycStep.personalInfo);
              },
              child: const Text('Start Verification'),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'This usually takes about 2-3 minutes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KycStepItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _KycStepItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
