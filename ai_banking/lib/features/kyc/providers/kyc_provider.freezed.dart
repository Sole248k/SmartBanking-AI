// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$KycState {
  KycStep get currentStep => throw _privateConstructorUsedError;
  KycRecord get record => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $KycStateCopyWith<KycState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KycStateCopyWith<$Res> {
  factory $KycStateCopyWith(KycState value, $Res Function(KycState) then) =
      _$KycStateCopyWithImpl<$Res, KycState>;
  @useResult
  $Res call(
      {KycStep currentStep, KycRecord record, bool isLoading, String? error});

  $KycRecordCopyWith<$Res> get record;
}

/// @nodoc
class _$KycStateCopyWithImpl<$Res, $Val extends KycState>
    implements $KycStateCopyWith<$Res> {
  _$KycStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? record = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as KycStep,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as KycRecord,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $KycRecordCopyWith<$Res> get record {
    return $KycRecordCopyWith<$Res>(_value.record, (value) {
      return _then(_value.copyWith(record: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$KycStateImplCopyWith<$Res>
    implements $KycStateCopyWith<$Res> {
  factory _$$KycStateImplCopyWith(
          _$KycStateImpl value, $Res Function(_$KycStateImpl) then) =
      __$$KycStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {KycStep currentStep, KycRecord record, bool isLoading, String? error});

  @override
  $KycRecordCopyWith<$Res> get record;
}

/// @nodoc
class __$$KycStateImplCopyWithImpl<$Res>
    extends _$KycStateCopyWithImpl<$Res, _$KycStateImpl>
    implements _$$KycStateImplCopyWith<$Res> {
  __$$KycStateImplCopyWithImpl(
      _$KycStateImpl _value, $Res Function(_$KycStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? record = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$KycStateImpl(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as KycStep,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as KycRecord,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$KycStateImpl implements _KycState {
  const _$KycStateImpl(
      {this.currentStep = KycStep.welcome,
      this.record = const KycRecord(),
      this.isLoading = false,
      this.error});

  @override
  @JsonKey()
  final KycStep currentStep;
  @override
  @JsonKey()
  final KycRecord record;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'KycState(currentStep: $currentStep, record: $record, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KycStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, currentStep, record, isLoading, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$KycStateImplCopyWith<_$KycStateImpl> get copyWith =>
      __$$KycStateImplCopyWithImpl<_$KycStateImpl>(this, _$identity);
}

abstract class _KycState implements KycState {
  const factory _KycState(
      {final KycStep currentStep,
      final KycRecord record,
      final bool isLoading,
      final String? error}) = _$KycStateImpl;

  @override
  KycStep get currentStep;
  @override
  KycRecord get record;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$KycStateImplCopyWith<_$KycStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
