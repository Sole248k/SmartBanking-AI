// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get accountId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  TransactionStatus get status => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  String? get referenceNumber => throw _privateConstructorUsedError;
  String? get senderName => throw _privateConstructorUsedError;
  String? get senderBank => throw _privateConstructorUsedError;
  String? get senderAccount => throw _privateConstructorUsedError;
  String? get recipientName => throw _privateConstructorUsedError;
  String? get targetAccount => throw _privateConstructorUsedError;
  String? get targetBank => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  double? get balanceBefore => throw _privateConstructorUsedError;
  double? get balanceAfter => throw _privateConstructorUsedError;
  String? get authMethod => throw _privateConstructorUsedError;
  double? get fee => throw _privateConstructorUsedError;
  String? get merchantLogoUrl => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get iconUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String accountId,
      String title,
      String description,
      double amount,
      DateTime date,
      String category,
      TransactionStatus status,
      TransactionType type,
      String? referenceNumber,
      String? senderName,
      String? senderBank,
      String? senderAccount,
      String? recipientName,
      String? targetAccount,
      String? targetBank,
      String? note,
      double? balanceBefore,
      double? balanceAfter,
      String? authMethod,
      double? fee,
      String? merchantLogoUrl,
      String? location,
      String? iconUrl});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? accountId = null,
    Object? title = null,
    Object? description = null,
    Object? amount = null,
    Object? date = null,
    Object? category = null,
    Object? status = null,
    Object? type = null,
    Object? referenceNumber = freezed,
    Object? senderName = freezed,
    Object? senderBank = freezed,
    Object? senderAccount = freezed,
    Object? recipientName = freezed,
    Object? targetAccount = freezed,
    Object? targetBank = freezed,
    Object? note = freezed,
    Object? balanceBefore = freezed,
    Object? balanceAfter = freezed,
    Object? authMethod = freezed,
    Object? fee = freezed,
    Object? merchantLogoUrl = freezed,
    Object? location = freezed,
    Object? iconUrl = freezed,
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
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TransactionStatus,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderBank: freezed == senderBank
          ? _value.senderBank
          : senderBank // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAccount: freezed == senderAccount
          ? _value.senderAccount
          : senderAccount // ignore: cast_nullable_to_non_nullable
              as String?,
      recipientName: freezed == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAccount: freezed == targetAccount
          ? _value.targetAccount
          : targetAccount // ignore: cast_nullable_to_non_nullable
              as String?,
      targetBank: freezed == targetBank
          ? _value.targetBank
          : targetBank // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      balanceBefore: freezed == balanceBefore
          ? _value.balanceBefore
          : balanceBefore // ignore: cast_nullable_to_non_nullable
              as double?,
      balanceAfter: freezed == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as double?,
      authMethod: freezed == authMethod
          ? _value.authMethod
          : authMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double?,
      merchantLogoUrl: freezed == merchantLogoUrl
          ? _value.merchantLogoUrl
          : merchantLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String accountId,
      String title,
      String description,
      double amount,
      DateTime date,
      String category,
      TransactionStatus status,
      TransactionType type,
      String? referenceNumber,
      String? senderName,
      String? senderBank,
      String? senderAccount,
      String? recipientName,
      String? targetAccount,
      String? targetBank,
      String? note,
      double? balanceBefore,
      double? balanceAfter,
      String? authMethod,
      double? fee,
      String? merchantLogoUrl,
      String? location,
      String? iconUrl});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? accountId = null,
    Object? title = null,
    Object? description = null,
    Object? amount = null,
    Object? date = null,
    Object? category = null,
    Object? status = null,
    Object? type = null,
    Object? referenceNumber = freezed,
    Object? senderName = freezed,
    Object? senderBank = freezed,
    Object? senderAccount = freezed,
    Object? recipientName = freezed,
    Object? targetAccount = freezed,
    Object? targetBank = freezed,
    Object? note = freezed,
    Object? balanceBefore = freezed,
    Object? balanceAfter = freezed,
    Object? authMethod = freezed,
    Object? fee = freezed,
    Object? merchantLogoUrl = freezed,
    Object? location = freezed,
    Object? iconUrl = freezed,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TransactionStatus,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderBank: freezed == senderBank
          ? _value.senderBank
          : senderBank // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAccount: freezed == senderAccount
          ? _value.senderAccount
          : senderAccount // ignore: cast_nullable_to_non_nullable
              as String?,
      recipientName: freezed == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAccount: freezed == targetAccount
          ? _value.targetAccount
          : targetAccount // ignore: cast_nullable_to_non_nullable
              as String?,
      targetBank: freezed == targetBank
          ? _value.targetBank
          : targetBank // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      balanceBefore: freezed == balanceBefore
          ? _value.balanceBefore
          : balanceBefore // ignore: cast_nullable_to_non_nullable
              as double?,
      balanceAfter: freezed == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as double?,
      authMethod: freezed == authMethod
          ? _value.authMethod
          : authMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double?,
      merchantLogoUrl: freezed == merchantLogoUrl
          ? _value.merchantLogoUrl
          : merchantLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.id,
      this.userId = '',
      this.accountId = '',
      required this.title,
      required this.description,
      required this.amount,
      required this.date,
      required this.category,
      required this.status,
      required this.type,
      this.referenceNumber,
      this.senderName,
      this.senderBank,
      this.senderAccount,
      this.recipientName,
      this.targetAccount,
      this.targetBank,
      this.note,
      this.balanceBefore,
      this.balanceAfter,
      this.authMethod,
      this.fee,
      this.merchantLogoUrl,
      this.location,
      this.iconUrl});

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String userId;
  @override
  @JsonKey()
  final String accountId;
  @override
  final String title;
  @override
  final String description;
  @override
  final double amount;
  @override
  final DateTime date;
  @override
  final String category;
  @override
  final TransactionStatus status;
  @override
  final TransactionType type;
  @override
  final String? referenceNumber;
  @override
  final String? senderName;
  @override
  final String? senderBank;
  @override
  final String? senderAccount;
  @override
  final String? recipientName;
  @override
  final String? targetAccount;
  @override
  final String? targetBank;
  @override
  final String? note;
  @override
  final double? balanceBefore;
  @override
  final double? balanceAfter;
  @override
  final String? authMethod;
  @override
  final double? fee;
  @override
  final String? merchantLogoUrl;
  @override
  final String? location;
  @override
  final String? iconUrl;

  @override
  String toString() {
    return 'Transaction(id: $id, userId: $userId, accountId: $accountId, title: $title, description: $description, amount: $amount, date: $date, category: $category, status: $status, type: $type, referenceNumber: $referenceNumber, senderName: $senderName, senderBank: $senderBank, senderAccount: $senderAccount, recipientName: $recipientName, targetAccount: $targetAccount, targetBank: $targetBank, note: $note, balanceBefore: $balanceBefore, balanceAfter: $balanceAfter, authMethod: $authMethod, fee: $fee, merchantLogoUrl: $merchantLogoUrl, location: $location, iconUrl: $iconUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderBank, senderBank) ||
                other.senderBank == senderBank) &&
            (identical(other.senderAccount, senderAccount) ||
                other.senderAccount == senderAccount) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.targetAccount, targetAccount) ||
                other.targetAccount == targetAccount) &&
            (identical(other.targetBank, targetBank) ||
                other.targetBank == targetBank) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.balanceBefore, balanceBefore) ||
                other.balanceBefore == balanceBefore) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.authMethod, authMethod) ||
                other.authMethod == authMethod) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.merchantLogoUrl, merchantLogoUrl) ||
                other.merchantLogoUrl == merchantLogoUrl) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        accountId,
        title,
        description,
        amount,
        date,
        category,
        status,
        type,
        referenceNumber,
        senderName,
        senderBank,
        senderAccount,
        recipientName,
        targetAccount,
        targetBank,
        note,
        balanceBefore,
        balanceAfter,
        authMethod,
        fee,
        merchantLogoUrl,
        location,
        iconUrl
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String id,
      final String userId,
      final String accountId,
      required final String title,
      required final String description,
      required final double amount,
      required final DateTime date,
      required final String category,
      required final TransactionStatus status,
      required final TransactionType type,
      final String? referenceNumber,
      final String? senderName,
      final String? senderBank,
      final String? senderAccount,
      final String? recipientName,
      final String? targetAccount,
      final String? targetBank,
      final String? note,
      final double? balanceBefore,
      final double? balanceAfter,
      final String? authMethod,
      final double? fee,
      final String? merchantLogoUrl,
      final String? location,
      final String? iconUrl}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get accountId;
  @override
  String get title;
  @override
  String get description;
  @override
  double get amount;
  @override
  DateTime get date;
  @override
  String get category;
  @override
  TransactionStatus get status;
  @override
  TransactionType get type;
  @override
  String? get referenceNumber;
  @override
  String? get senderName;
  @override
  String? get senderBank;
  @override
  String? get senderAccount;
  @override
  String? get recipientName;
  @override
  String? get targetAccount;
  @override
  String? get targetBank;
  @override
  String? get note;
  @override
  double? get balanceBefore;
  @override
  double? get balanceAfter;
  @override
  String? get authMethod;
  @override
  double? get fee;
  @override
  String? get merchantLogoUrl;
  @override
  String? get location;
  @override
  String? get iconUrl;
  @override
  @JsonKey(ignore: true)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
