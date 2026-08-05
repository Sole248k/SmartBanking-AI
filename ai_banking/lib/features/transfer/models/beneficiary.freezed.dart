// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'beneficiary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Beneficiary _$BeneficiaryFromJson(Map<String, dynamic> json) {
  return _Beneficiary.fromJson(json);
}

/// @nodoc
mixin _$Beneficiary {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get accountNumber => throw _privateConstructorUsedError;
  String get bankName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BeneficiaryCopyWith<Beneficiary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BeneficiaryCopyWith<$Res> {
  factory $BeneficiaryCopyWith(
          Beneficiary value, $Res Function(Beneficiary) then) =
      _$BeneficiaryCopyWithImpl<$Res, Beneficiary>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String accountNumber,
      String bankName,
      String? avatarUrl});
}

/// @nodoc
class _$BeneficiaryCopyWithImpl<$Res, $Val extends Beneficiary>
    implements $BeneficiaryCopyWith<$Res> {
  _$BeneficiaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? accountNumber = null,
    Object? bankName = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BeneficiaryImplCopyWith<$Res>
    implements $BeneficiaryCopyWith<$Res> {
  factory _$$BeneficiaryImplCopyWith(
          _$BeneficiaryImpl value, $Res Function(_$BeneficiaryImpl) then) =
      __$$BeneficiaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String accountNumber,
      String bankName,
      String? avatarUrl});
}

/// @nodoc
class __$$BeneficiaryImplCopyWithImpl<$Res>
    extends _$BeneficiaryCopyWithImpl<$Res, _$BeneficiaryImpl>
    implements _$$BeneficiaryImplCopyWith<$Res> {
  __$$BeneficiaryImplCopyWithImpl(
      _$BeneficiaryImpl _value, $Res Function(_$BeneficiaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? accountNumber = null,
    Object? bankName = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$BeneficiaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BeneficiaryImpl implements _Beneficiary {
  const _$BeneficiaryImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.accountNumber,
      required this.bankName,
      this.avatarUrl});

  factory _$BeneficiaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BeneficiaryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String accountNumber;
  @override
  final String bankName;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'Beneficiary(id: $id, userId: $userId, name: $name, accountNumber: $accountNumber, bankName: $bankName, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BeneficiaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, name, accountNumber, bankName, avatarUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BeneficiaryImplCopyWith<_$BeneficiaryImpl> get copyWith =>
      __$$BeneficiaryImplCopyWithImpl<_$BeneficiaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BeneficiaryImplToJson(
      this,
    );
  }
}

abstract class _Beneficiary implements Beneficiary {
  const factory _Beneficiary(
      {required final String id,
      required final String userId,
      required final String name,
      required final String accountNumber,
      required final String bankName,
      final String? avatarUrl}) = _$BeneficiaryImpl;

  factory _Beneficiary.fromJson(Map<String, dynamic> json) =
      _$BeneficiaryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get accountNumber;
  @override
  String get bankName;
  @override
  String? get avatarUrl;
  @override
  @JsonKey(ignore: true)
  _$$BeneficiaryImplCopyWith<_$BeneficiaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
