import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../profile/providers/profile_providers.dart';

class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final kycStatus = profileAsync.value?.kycStatus ?? 'Pending Review';
    final isApproved = kycStatus == 'Approved';
    final isRejected = kycStatus == 'Rejected';

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Status'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatusIcon(kycStatus: kycStatus),
            const SizedBox(height: 32),
            Text(
              isApproved
                  ? 'Identity Verified'
                  : isRejected
                      ? 'Verification Rejected'
                      : 'Verification Pending',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isApproved
                  ? 'Congratulations! Your identity has been successfully verified. You now have full access to all banking features.'
                  : isRejected
                      ? 'Your verification was not approved. Please re-submit with clearer documents.'
                      : 'Our team is currently reviewing your documents. This usually takes less than 24 hours. We will notify you once done.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String kycStatus;
  const _StatusIcon({required this.kycStatus});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color color;
    final IconData icon;

    switch (kycStatus) {
      case 'Approved':
        color = colorScheme.primary;
        icon = LucideIcons.circleCheck;
        break;
      case 'Rejected':
        color = colorScheme.error;
        icon = LucideIcons.circleX;
        break;
      default:
        color = Colors.orange;
        icon = LucideIcons.clock;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 50),
    );
  }
}
