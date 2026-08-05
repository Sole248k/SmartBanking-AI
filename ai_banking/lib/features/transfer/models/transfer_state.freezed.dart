// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TransferState {
  TransferStep get step => throw _privateConstructorUsedError;
  String? get fromAccountId => throw _privateConstructorUsedError;
  Beneficiary? get selectedBeneficiary => throw _privateConstructorUsedError;
  String get recipientName => throw _privateConstructorUsedError;
  String get recipientAccountNumber => throw _privateConstructorUsedError;
  String get bankName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  bool get saveAsBeneficiary => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TransferStateCopyWith<TransferState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferStateCopyWith<$Res> {
  factory $TransferStateCopyWith(
          TransferState value, $Res Function(TransferState) then) =
      _$TransferStateCopyWithImpl<$Res, TransferState>;
  @useResult
  $Res call(
      {TransferStep step,
      String? fromAccountId,
      Beneficiary? selectedBeneficiary,
      String recipientName,
      String recipientAccountNumber,
      String bankName,
      double amount,
      String? note,
      bool saveAsBeneficiary,
      bool isLoading,
      String? errorMessage});

  $BeneficiaryCopyWith<$Res>? get selectedBeneficiary;
}

/// @nodoc
class _$TransferStateCopyWithImpl<$Res, $Val extends TransferState>
    implements $TransferStateCopyWith<$Res> {
  _$TransferStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? fromAccountId = freezed,
    Object? selectedBeneficiary = freezed,
    Object? recipientName = null,
    Object? recipientAccountNumber = null,
    Object? bankName = null,
    Object? amount = null,
    Object? note = freezed,
    Object? saveAsBeneficiary = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      step: null == step
          ? _value.step
          : step // ignore: cast_nullable_to_non_nullable
              as TransferStep,
      fromAccountId: freezed == fromAccountId
          ? _value.fromAccountId
          : fromAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedBeneficiary: freezed == selectedBeneficiary
          ? _value.selectedBeneficiary
          : selectedBeneficiary // ignore: cast_nullable_to_non_nullable
              as Beneficiary?,
      recipientName: null == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String,
      recipientAccountNumber: null == recipientAccountNumber
          ? _value.recipientAccountNumber
          : recipientAccountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      saveAsBeneficiary: null == saveAsBeneficiary
          ? _value.saveAsBeneficiary
          : saveAsBeneficiary // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BeneficiaryCopyWith<$Res>? get selectedBeneficiary {
    if (_value.selectedBeneficiary == null) {
      return null;
    }

    return $BeneficiaryCopyWith<$Res>(_value.selectedBeneficiary!, (value) {
      return _then(_value.copyWith(selectedBeneficiary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TransferStateImplCopyWith<$Res>
    implements $TransferStateCopyWith<$Res> {
  factory _$$TransferStateImplCopyWith(
          _$TransferStateImpl value, $Res Function(_$TransferStateImpl) then) =
      __$$TransferStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TransferStep step,
      String? fromAccountId,
      Beneficiary? selectedBeneficiary,
      String recipientName,
      String recipientAccountNumber,
      String bankName,
      double amount,
      String? note,
      bool saveAsBeneficiary,
      bool isLoading,
      String? errorMessage});

  @override
  $BeneficiaryCopyWith<$Res>? get selectedBeneficiary;
}

/// @nodoc
class __$$TransferStateImplCopyWithImpl<$Res>
    extends _$TransferStateCopyWithImpl<$Res, _$TransferStateImpl>
    implements _$$TransferStateImplCopyWith<$Res> {
  __$$TransferStateImplCopyWithImpl(
      _$TransferStateImpl _value, $Res Function(_$TransferStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? fromAccountId = freezed,
    Object? selectedBeneficiary = freezed,
    Object? recipientName = null,
    Object? recipientAccountNumber = null,
    Object? bankName = null,
    Object? amount = null,
    Object? note = freezed,
    Object? saveAsBeneficiary = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$TransferStateImpl(
      step: null == step
          ? _value.step
          : step // ignore: cast_nullable_to_non_nullable
              as TransferStep,
      fromAccountId: freezed == fromAccountId
          ? _value.fromAccountId
          : fromAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedBeneficiary: freezed == selectedBeneficiary
          ? _value.selectedBeneficiary
          : selectedBeneficiary // ignore: cast_nullable_to_non_nullable
              as Beneficiary?,
      recipientName: null == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String,
      recipientAccountNumber: null == recipientAccountNumber
          ? _value.recipientAccountNumber
          : recipientAccountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      saveAsBeneficiary: null == saveAsBeneficiary
          ? _value.saveAsBeneficiary
          : saveAsBeneficiary // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TransferStateImpl implements _TransferState {
  const _$TransferStateImpl(
      {this.step = TransferStep.form,
      this.fromAccountId,
      this.selectedBeneficiary,
      this.recipientName = '',
      this.recipientAccountNumber = '',
      this.bankName = 'SmartBank',
      this.amount = 0.0,
      this.note,
      this.saveAsBeneficiary = false,
      this.isLoading = false,
      this.errorMessage});

  @override
  @JsonKey()
  final TransferStep step;
  @override
  final String? fromAccountId;
  @override
  final Beneficiary? selectedBeneficiary;
  @override
  @JsonKey()
  final String recipientName;
  @override
  @JsonKey()
  final String recipientAccountNumber;
  @override
  @JsonKey()
  final String bankName;
  @override
  @JsonKey()
  final double amount;
  @override
  final String? note;
  @override
  @JsonKey()
  final bool saveAsBeneficiary;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'TransferState(step: $step, fromAccountId: $fromAccountId, selectedBeneficiary: $selectedBeneficiary, recipientName: $recipientName, recipientAccountNumber: $recipientAccountNumber, bankName: $bankName, amount: $amount, note: $note, saveAsBeneficiary: $saveAsBeneficiary, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferStateImpl &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.fromAccountId, fromAccountId) ||
                other.fromAccountId == fromAccountId) &&
            (identical(other.selectedBeneficiary, selectedBeneficiary) ||
                other.selectedBeneficiary == selectedBeneficiary) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.recipientAccountNumber, recipientAccountNumber) ||
                other.recipientAccountNumber == recipientAccountNumber) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.saveAsBeneficiary, saveAsBeneficiary) ||
                other.saveAsBeneficiary == saveAsBeneficiary) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      step,
      fromAccountId,
      selectedBeneficiary,
      recipientName,
      recipientAccountNumber,
      bankName,
      amount,
      note,
      saveAsBeneficiary,
      isLoading,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferStateImplCopyWith<_$TransferStateImpl> get copyWith =>
      __$$TransferStateImplCopyWithImpl<_$TransferStateImpl>(this, _$identity);
}

abstract class _TransferState implements TransferState {
  const factory _TransferState(
      {final TransferStep step,
      final String? fromAccountId,
      final Beneficiary? selectedBeneficiary,
      final String recipientName,
      final String recipientAccountNumber,
      final String bankName,
      final double amount,
      final String? note,
      final bool saveAsBeneficiary,
      final bool isLoading,
      final String? errorMessage}) = _$TransferStateImpl;

  @override
  TransferStep get step;
  @override
  String? get fromAccountId;
  @override
  Beneficiary? get selectedBeneficiary;
  @override
  String get recipientName;
  @override
  String get recipientAccountNumber;
  @override
  String get bankName;
  @override
  double get amount;
  @override
  String? get note;
  @override
  bool get saveAsBeneficiary;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$TransferStateImplCopyWith<_$TransferStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
