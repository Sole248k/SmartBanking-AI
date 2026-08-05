import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';

class QrHubScreen extends StatelessWidget {
  const QrHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Payments'),
      ),
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppConstants.lg),
            Text(
              'Pay & receive instantly',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.sm),
            Text(
              'Scan a code to pay or share yours to get paid.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppConstants.xxl),
            _QrActionTile(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan to Pay',
              subtitle: 'Scan a merchant or friend\'s QR code',
              onTap: () => context.push('/qr-scanner'),
            ),
            const SizedBox(height: AppConstants.md),
            _QrActionTile(
              icon: Icons.qr_code_rounded,
              label: 'My QR Code',
              subtitle: 'Show your code to receive payments',
              onTap: () => context.push('/my-qr'),
            ),
            const SizedBox(height: AppConstants.md),
            _QrActionTile(
              icon: Icons.call_received_rounded,
              label: 'Request Money',
              subtitle: 'Generate a QR with a specific amount',
              onTap: () => context.push('/request-money'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrActionTile extends StatelessWidget {
  const _QrActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(width: AppConstants.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
