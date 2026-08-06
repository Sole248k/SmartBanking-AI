// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qr_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QrData _$QrDataFromJson(Map<String, dynamic> json) {
  return _QrData.fromJson(json);
}

/// @nodoc
mixin _$QrData {
  String get recipientId => throw _privateConstructorUsedError;
  String get recipientName => throw _privateConstructorUsedError;
  String get accountNumber => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get walletId => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get bankCode => throw _privateConstructorUsedError;
  String? get referenceNumber => throw _privateConstructorUsedError;
  String? get expiresAt => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QrDataCopyWith<QrData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrDataCopyWith<$Res> {
  factory $QrDataCopyWith(QrData value, $Res Function(QrData) then) =
      _$QrDataCopyWithImpl<$Res, QrData>;
  @useResult
  $Res call({
    String recipientId,
    String recipientName,
    String accountNumber,
    double? amount,
    String? note,
    String? walletId,
    String? userId,
    String? bankCode,
    String? referenceNumber,
    String? expiresAt,
    String version,
  });
}

/// @nodoc
class _$QrDataCopyWithImpl<$Res, $Val extends QrData>
    implements $QrDataCopyWith<$Res> {
  _$QrDataCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipientId = null,
    Object? recipientName = null,
    Object? accountNumber = null,
    Object? amount = freezed,
    Object? note = freezed,
    Object? walletId = freezed,
    Object? userId = freezed,
    Object? bankCode = freezed,
    Object? referenceNumber = freezed,
    Object? expiresAt = freezed,
    Object? version = null,
  }) {
    return _then(_value.copyWith(
      recipientId: null == recipientId
          ? _value.recipientId
          : recipientId as String,
      recipientName: null == recipientName
          ? _value.recipientName
          : recipientName as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber as String,
      amount: freezed == amount ? _value.amount : amount as double?,
      note: freezed == note ? _value.note : note as String?,
      walletId: freezed == walletId ? _value.walletId : walletId as String?,
      userId: freezed == userId ? _value.userId : userId as String?,
      bankCode: freezed == bankCode ? _value.bankCode : bankCode as String?,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber as String?,
      expiresAt:
          freezed == expiresAt ? _value.expiresAt : expiresAt as String?,
      version: null == version ? _value.version : version as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QrDataImplCopyWith<$Res> implements $QrDataCopyWith<$Res> {
  factory _$$QrDataImplCopyWith(
          _$QrDataImpl value, $Res Function(_$QrDataImpl) then) =
      __$$QrDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String recipientId,
    String recipientName,
    String accountNumber,
    double? amount,
    String? note,
    String? walletId,
    String? userId,
    String? bankCode,
    String? referenceNumber,
    String? expiresAt,
    String version,
  });
}

/// @nodoc
class __$$QrDataImplCopyWithImpl<$Res>
    extends _$QrDataCopyWithImpl<$Res, _$QrDataImpl>
    implements _$$QrDataImplCopyWith<$Res> {
  __$$QrDataImplCopyWithImpl(
      _$QrDataImpl _value, $Res Function(_$QrDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipientId = null,
    Object? recipientName = null,
    Object? accountNumber = null,
    Object? amount = freezed,
    Object? note = freezed,
    Object? walletId = freezed,
    Object? userId = freezed,
    Object? bankCode = freezed,
    Object? referenceNumber = freezed,
    Object? expiresAt = freezed,
    Object? version = null,
  }) {
    return _then(_$QrDataImpl(
      recipientId: null == recipientId
          ? _value.recipientId
          : recipientId as String,
      recipientName: null == recipientName
          ? _value.recipientName
          : recipientName as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber as String,
      amount: freezed == amount ? _value.amount : amount as double?,
      note: freezed == note ? _value.note : note as String?,
      walletId: freezed == walletId ? _value.walletId : walletId as String?,
      userId: freezed == userId ? _value.userId : userId as String?,
      bankCode: freezed == bankCode ? _value.bankCode : bankCode as String?,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber as String?,
      expiresAt:
          freezed == expiresAt ? _value.expiresAt : expiresAt as String?,
      version: null == version ? _value.version : version as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QrDataImpl implements _QrData {
  const _$QrDataImpl({
    required this.recipientId,
    required this.recipientName,
    required this.accountNumber,
    this.amount,
    this.note,
    this.walletId,
    this.userId,
    this.bankCode,
    this.referenceNumber,
    this.expiresAt,
    this.version = '1',
  });

  factory _$QrDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$QrDataImplFromJson(json);

  @override
  final String recipientId;
  @override
  final String recipientName;
  @override
  final String accountNumber;
  @override
  final double? amount;
  @override
  final String? note;
  @override
  final String? walletId;
  @override
  final String? userId;
  @override
  final String? bankCode;
  @override
  final String? referenceNumber;
  @override
  final String? expiresAt;
  @override
  @JsonKey()
  final String version;

  @override
  String toString() {
    return 'QrData(recipientId: $recipientId, recipientName: $recipientName, accountNumber: $accountNumber, amount: $amount, note: $note, walletId: $walletId, userId: $userId, bankCode: $bankCode, referenceNumber: $referenceNumber, expiresAt: $expiresAt, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QrDataImpl &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.walletId, walletId) ||
                other.walletId == walletId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bankCode, bankCode) ||
                other.bankCode == bankCode) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, recipientId, recipientName,
      accountNumber, amount, note, walletId, userId, bankCode, referenceNumber,
      expiresAt, version);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QrDataImplCopyWith<_$QrDataImpl> get copyWith =>
      __$$QrDataImplCopyWithImpl<_$QrDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QrDataImplToJson(this);
  }
}

abstract class _QrData implements QrData {
  const factory _QrData({
    required final String recipientId,
    required final String recipientName,
    required final String accountNumber,
    final double? amount,
    final String? note,
    final String? walletId,
    final String? userId,
    final String? bankCode,
    final String? referenceNumber,
    final String? expiresAt,
    final String version,
  }) = _$QrDataImpl;

  factory _QrData.fromJson(Map<String, dynamic> json) =
      _$QrDataImpl.fromJson;

  @override
  String get recipientId;
  @override
  String get recipientName;
  @override
  String get accountNumber;
  @override
  double? get amount;
  @override
  String? get note;
  @override
  String? get walletId;
  @override
  String? get userId;
  @override
  String? get bankCode;
  @override
  String? get referenceNumber;
  @override
  String? get expiresAt;
  @override
  String get version;
  @override
  @JsonKey(ignore: true)
  _$$QrDataImplCopyWith<_$QrDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
