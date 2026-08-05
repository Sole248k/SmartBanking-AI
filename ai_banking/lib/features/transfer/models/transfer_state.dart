import 'package:freezed_annotation/freezed_annotation.dart';
import 'beneficiary.dart';

part 'transfer_state.freezed.dart';

enum TransferStep { form, confirm, success }

@freezed
class TransferState with _$TransferState {
  const factory TransferState({
    @Default(TransferStep.form) TransferStep step,
    String? fromAccountId,
    Beneficiary? selectedBeneficiary,
    @Default('') String recipientName,
    @Default('') String recipientAccountNumber,
    @Default('SmartBank') String bankName,
    @Default(0.0) double amount,
    String? note,
    @Default(false) bool saveAsBeneficiary,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _TransferState;
}
