import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../core/utils/kyc_gatekeeper.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../profile/providers/profile_providers.dart';
import '../../domain/entities/kyc_record.dart';
import '../../providers/kyc_provider.dart';

class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileControllerProvider);
    final profile = profileAsync.value;
    final kycGate = KycGateStatus.parse(profile?.kycStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppConstants.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: kycGate.statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    kycGate.icon,
                    color: kycGate.statusColor,
                    size: 52,
                  ),
                ),
                const SizedBox(height: AppConstants.xl),

                // Title
                Text(
                  kycGate.bannerTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.sm),

                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: kycGate.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMax),
                    border: Border.all(color: kycGate.statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    kycGate.badgeText,
                    style: TextStyle(
                      color: kycGate.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.lg),

                // Message Box
                Container(
                  padding: const EdgeInsets.all(AppConstants.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    kycGate == KycGateStatus.approved
                        ? 'Your identity has already been verified and approved by SmartBank compliance. You do not need to repeat the verification process.'
                        : kycGate.bannerMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppConstants.xxl),

                // Actions
                if (kycGate == KycGateStatus.approved) ...[
                  AppButton(
                    text: 'Explore Products',
                    icon: Icons.grid_view_rounded,
                    onPressed: () => context.go('/products'),
                  ),
                  const SizedBox(height: AppConstants.md),
                  AppButton(
                    text: 'Back to Home',
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/'),
                  ),
                ] else if (kycGate == KycGateStatus.rejected) ...[
                  AppButton(
                    text: 'Resubmit Verification',
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      ref.read(kycControllerProvider.notifier).setStep(KycStep.personalInfo);
                    },
                  ),
                  const SizedBox(height: AppConstants.md),
                  AppButton(
                    text: 'Back to Home',
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/'),
                  ),
                ] else ...[
                  AppButton(
                    text: 'Back to Home',
                    onPressed: () => context.go('/'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
