import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';
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
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  if (user == null) return const Stream.empty();
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
      recipientName: beneficiary.name,
      recipientAccountNumber: beneficiary.accountNumber,
      bankName: beneficiary.bankName,
    );
  }

  void clearBeneficiary() {
    state = state.copyWith(
      selectedBeneficiary: null,
      recipientName: '',
      recipientAccountNumber: '',
      bankName: 'SmartBank',
    );
  }

  void setRecipientDetails({
    String? fromAccountId,
    required String recipientName,
    required String recipientAccountNumber,
    required String bankName,
    required double amount,
    String? note,
    bool saveAsBeneficiary = false,
  }) {
    state = state.copyWith(
      fromAccountId: fromAccountId,
      recipientName: recipientName,
      recipientAccountNumber: recipientAccountNumber,
      bankName: bankName,
      amount: amount,
      note: note,
      saveAsBeneficiary: saveAsBeneficiary,
      step: TransferStep.confirm,
    );
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void updateNote(String note) {
    state = state.copyWith(note: note);
  }

  void back() {
    if (state.step == TransferStep.confirm) {
      state = state.copyWith(step: TransferStep.form);
    }
  }

  Future<void> confirmTransfer() async {
    if (state.recipientName.isEmpty ||
        state.recipientAccountNumber.isEmpty ||
        state.amount <= 0) {
      state = state.copyWith(errorMessage: 'Please fill in recipient details and amount');
      return;
    }

    final accounts = ref.read(dashboardAccountsProvider).value;
    if (accounts == null || accounts.isEmpty) {
      state = state.copyWith(errorMessage: 'No source account found');
      return;
    }

    final sourceId = state.fromAccountId ?? accounts.first.id;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref.read(transferRepositoryProvider).executeTransfer(
      fromAccountId: sourceId,
      recipientName: state.recipientName,
      recipientAccountNumber: state.recipientAccountNumber,
      bankName: state.bankName,
      amount: state.amount,
      note: state.note,
      beneficiaryId: state.selectedBeneficiary?.id,
      saveAsBeneficiary: state.saveAsBeneficiary,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        ref.invalidate(dashboardAccountsProvider);
        ref.invalidate(recentTransactionsProvider);
        state = state.copyWith(isLoading: false, step: TransferStep.success);
      },
    );
  }

  void reset() {
    state = const TransferState();
  }
}
