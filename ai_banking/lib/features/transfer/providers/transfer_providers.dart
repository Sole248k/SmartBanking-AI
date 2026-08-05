import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../data/firestore_transfer_repository_impl.dart';
import '../models/beneficiary.dart';
import '../models/transfer_state.dart';
import '../repositories/transfer_repository.dart';

part 'transfer_providers.g.dart';

@riverpod
TransferRepository transferRepository(TransferRepositoryRef ref) {
  return FirestoreTransferRepositoryImpl();
}

@riverpod
Stream<List<Beneficiary>> beneficiaries(BeneficiariesRef ref) {
  return ref.watch(transferRepositoryProvider).watchRecentBeneficiaries();
}

@riverpod
class TransferController extends _$TransferController {
  @override
  TransferState build() {
    return const TransferState();
  }

  void selectBeneficiary(Beneficiary beneficiary) {
    state = state.copyWith(
      selectedBeneficiary: beneficiary,
      step: TransferStep.enterAmount,
    );
  }

  void setAmount(double amount) {
    state = state.copyWith(
      amount: amount,
      step: TransferStep.confirm,
    );
  }

  void updateNote(String note) {
    state = state.copyWith(note: note);
  }

  void back() {
    if (state.step == TransferStep.enterAmount) {
      state = state.copyWith(step: TransferStep.selectBeneficiary, selectedBeneficiary: null);
    } else if (state.step == TransferStep.confirm) {
      state = state.copyWith(step: TransferStep.enterAmount);
    }
  }

  Future<void> confirmTransfer() async {
    if (state.selectedBeneficiary == null || state.amount <= 0) return;

    final accounts = ref.read(dashboardAccountsProvider).value;
    if (accounts == null || accounts.isEmpty) {
      state = state.copyWith(errorMessage: 'No source account found');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref.read(transferRepositoryProvider).executeTransfer(
      fromAccountId: accounts.first.id,
      beneficiaryId: state.selectedBeneficiary!.id,
      amount: state.amount,
      note: state.note,
    );

    state = result.match(
      (failure) => state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) => state.copyWith(isLoading: false, step: TransferStep.success),
    );
  }

  void reset() {
    state = const TransferState();
  }
}
