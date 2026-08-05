import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/repositories/firebase_kyc_repository.dart';
import '../domain/entities/kyc_record.dart';
import '../domain/repositories/kyc_repository.dart';
import '../../auth/providers/auth_provider.dart';

part 'kyc_provider.freezed.dart';
part 'kyc_provider.g.dart';

@freezed
class KycState with _$KycState {
  const factory KycState({
    @Default(KycStep.welcome) KycStep currentStep,
    @Default(KycRecord()) KycRecord record,
    @Default(false) bool isLoading,
    String? error,
  }) = _KycState;
}

@riverpod
KycRepository kycRepository(KycRepositoryRef ref) {
  return FirebaseKycRepository();
}

@riverpod
class KycController extends _$KycController {
  @override
  KycState build() {
    return const KycState();
  }

  void setStep(KycStep step) {
    state = state.copyWith(currentStep: step);
  }

  void updateRecord(KycRecord record) {
    state = state.copyWith(record: record);
  }

  Future<void> submitKyc() async {
    final user = await ref.read(authNotifierProvider.future);
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await ref.read(kycRepositoryProvider).submitKyc(
      userId: user.id,
      record: state.record,
    );
    
    state = result.match(
      (l) => state.copyWith(isLoading: false, error: l.message),
      (r) => state.copyWith(isLoading: false, currentStep: KycStep.submitted),
    );
  }

  Future<String?> uploadImage(String filePath, String folderName) async {
    final result = await ref.read(kycRepositoryProvider).uploadKycImage(
      filePath: filePath,
      folderName: folderName,
    );
    return result.match((l) => null, (r) => r);
  }
}
