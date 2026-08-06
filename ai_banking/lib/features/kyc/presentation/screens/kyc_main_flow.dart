import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/kyc_gatekeeper.dart';
import '../../../profile/providers/profile_providers.dart';
import '../../domain/entities/kyc_record.dart';
import '../../providers/kyc_provider.dart';
import 'id_capture_screen.dart';
import 'id_selection_screen.dart';
import 'kyc_review_screen.dart';
import 'kyc_status_screen.dart';
import 'kyc_welcome_screen.dart';
import 'personal_info_screen.dart';
import 'selfie_capture_screen.dart';

class KycMainFlow extends ConsumerWidget {
  const KycMainFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final kycGate = KycGateStatus.parse(profileAsync.value?.kycStatus);

    // If KYC is already approved, pending review, or more info required:
    // Route directly to KycStatusScreen so the user cannot repeat the verification steps!
    if (kycGate == KycGateStatus.approved ||
        kycGate == KycGateStatus.pending ||
        kycGate == KycGateStatus.moreInfoRequired) {
      return const KycStatusScreen();
    }

    final kycState = ref.watch(kycControllerProvider);

    switch (kycState.currentStep) {
      case KycStep.welcome:
        return const KycWelcomeScreen();
      case KycStep.personalInfo:
        return const PersonalInfoScreen();
      case KycStep.idSelection:
        return const IdSelectionScreen();
      case KycStep.idCaptureFront:
        return const IdCaptureScreen(isFront: true);
      case KycStep.idCaptureBack:
        return const IdCaptureScreen(isFront: false);
      case KycStep.selfieCapture:
        return const SelfieCaptureScreen();
      case KycStep.review:
        return const KycReviewScreen();
      case KycStep.submitted:
        return const KycStatusScreen();
    }
  }
}
