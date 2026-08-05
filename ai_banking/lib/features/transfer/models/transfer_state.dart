import 'package:freezed_annotation/freezed_annotation.dart';
import 'beneficiary.dart';

part 'transfer_state.freezed.dart';

enum TransferStep { selectBeneficiary, enterAmount, confirm, success }

@freezed
class TransferState with _$TransferState {
  const factory TransferState({
    @Default(TransferStep.selectBeneficiary) TransferStep step,
    Beneficiary? selectedBeneficiary,
    @Default(0.0) double amount,
    String? note,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _TransferState;
}
