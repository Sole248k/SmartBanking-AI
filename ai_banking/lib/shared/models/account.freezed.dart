// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Account _$AccountFromJson(Map<String, dynamic> json) {
  return _Account.fromJson(json);
}

/// @nodoc
mixin _$Account {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get accountNumber => throw _privateConstructorUsedError;
  String get cardNumber => throw _privateConstructorUsedError;
  String get cvv => throw _privateConstructorUsedError;
  String get expiryDate => throw _privateConstructorUsedError;
  String get holderName => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  double get availableBalance => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  AccountType get type => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  AccountStatus get status => throw _privateConstructorUsedError;
  CardNetwork get cardNetwork => throw _privateConstructorUsedError;
  List<String> get cardGradientColors => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountCopyWith<Account> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountCopyWith<$Res> {
  factory $AccountCopyWith(Account value, $Res Function(Account) then) =
      _$AccountCopyWithImpl<$Res, Account>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String accountNumber,
      String cardNumber,
      String cvv,
      String expiryDate,
      String holderName,
      double balance,
      double availableBalance,
      String currency,
      AccountType type,
      String label,
      AccountStatus status,
      CardNetwork cardNetwork,
      List<String> cardGradientColors});
}

/// @nodoc
class _$AccountCopyWithImpl<$Res, $Val extends Account>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? accountNumber = null,
    Object? cardNumber = null,
    Object? cvv = null,
    Object? expiryDate = null,
    Object? holderName = null,
    Object? balance = null,
    Object? availableBalance = null,
    Object? currency = null,
    Object? type = null,
    Object? label = null,
    Object? status = null,
    Object? cardNetwork = null,
    Object? cardGradientColors = null,
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
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      cardNumber: null == cardNumber
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String,
      cvv: null == cvv
          ? _value.cvv
          : cvv // ignore: cast_nullable_to_non_nullable
              as String,
      expiryDate: null == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String,
      holderName: null == holderName
          ? _value.holderName
          : holderName // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AccountType,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AccountStatus,
      cardNetwork: null == cardNetwork
          ? _value.cardNetwork
          : cardNetwork // ignore: cast_nullable_to_non_nullable
              as CardNetwork,
      cardGradientColors: null == cardGradientColors
          ? _value.cardGradientColors
          : cardGradientColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountImplCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$$AccountImplCopyWith(
          _$AccountImpl value, $Res Function(_$AccountImpl) then) =
      __$$AccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String accountNumber,
      String cardNumber,
      String cvv,
      String expiryDate,
      String holderName,
      double balance,
      double availableBalance,
      String currency,
      AccountType type,
      String label,
      AccountStatus status,
      CardNetwork cardNetwork,
      List<String> cardGradientColors});
}

/// @nodoc
class __$$AccountImplCopyWithImpl<$Res>
    extends _$AccountCopyWithImpl<$Res, _$AccountImpl>
    implements _$$AccountImplCopyWith<$Res> {
  __$$AccountImplCopyWithImpl(
      _$AccountImpl _value, $Res Function(_$AccountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? accountNumber = null,
    Object? cardNumber = null,
    Object? cvv = null,
    Object? expiryDate = null,
    Object? holderName = null,
    Object? balance = null,
    Object? availableBalance = null,
    Object? currency = null,
    Object? type = null,
    Object? label = null,
    Object? status = null,
    Object? cardNetwork = null,
    Object? cardGradientColors = null,
  }) {
    return _then(_$AccountImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      cardNumber: null == cardNumber
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String,
      cvv: null == cvv
          ? _value.cvv
          : cvv // ignore: cast_nullable_to_non_nullable
              as String,
      expiryDate: null == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String,
      holderName: null == holderName
          ? _value.holderName
          : holderName // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AccountType,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AccountStatus,
      cardNetwork: null == cardNetwork
          ? _value.cardNetwork
          : cardNetwork // ignore: cast_nullable_to_non_nullable
              as CardNetwork,
      cardGradientColors: null == cardGradientColors
          ? _value._cardGradientColors
          : cardGradientColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountImpl implements _Account {
  const _$AccountImpl(
      {required this.id,
      required this.userId,
      required this.accountNumber,
      this.cardNumber = '0000 0000 0000 0000',
      this.cvv = '000',
      this.expiryDate = '01/25',
      this.holderName = 'SmartBank User',
      this.balance = 0.0,
      this.availableBalance = 0.0,
      this.currency = 'PHP',
      required this.type,
      required this.label,
      this.status = AccountStatus.active,
      this.cardNetwork = CardNetwork.visa,
      final List<String> cardGradientColors = const ['#0A84FF', '#5E5CE6']})
      : _cardGradientColors = cardGradientColors;

  factory _$AccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String accountNumber;
  @override
  @JsonKey()
  final String cardNumber;
  @override
  @JsonKey()
  final String cvv;
  @override
  @JsonKey()
  final String expiryDate;
  @override
  @JsonKey()
  final String holderName;
  @override
  @JsonKey()
  final double balance;
  @override
  @JsonKey()
  final double availableBalance;
  @override
  @JsonKey()
  final String currency;
  @override
  final AccountType type;
  @override
  final String label;
  @override
  @JsonKey()
  final AccountStatus status;
  @override
  @JsonKey()
  final CardNetwork cardNetwork;
  final List<String> _cardGradientColors;
  @override
  @JsonKey()
  List<String> get cardGradientColors {
    if (_cardGradientColors is EqualUnmodifiableListView)
      return _cardGradientColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cardGradientColors);
  }

  @override
  String toString() {
    return 'Account(id: $id, userId: $userId, accountNumber: $accountNumber, cardNumber: $cardNumber, cvv: $cvv, expiryDate: $expiryDate, holderName: $holderName, balance: $balance, availableBalance: $availableBalance, currency: $currency, type: $type, label: $label, status: $status, cardNetwork: $cardNetwork, cardGradientColors: $cardGradientColors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.cardNumber, cardNumber) ||
                other.cardNumber == cardNumber) &&
            (identical(other.cvv, cvv) || other.cvv == cvv) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.holderName, holderName) ||
                other.holderName == holderName) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.availableBalance, availableBalance) ||
                other.availableBalance == availableBalance) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cardNetwork, cardNetwork) ||
                other.cardNetwork == cardNetwork) &&
            const DeepCollectionEquality()
                .equals(other._cardGradientColors, _cardGradientColors));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      accountNumber,
      cardNumber,
      cvv,
      expiryDate,
      holderName,
      balance,
      availableBalance,
      currency,
      type,
      label,
      status,
      cardNetwork,
      const DeepCollectionEquality().hash(_cardGradientColors));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      __$$AccountImplCopyWithImpl<_$AccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountImplToJson(
      this,
    );
  }
}

abstract class _Account implements Account {
  const factory _Account(
      {required final String id,
      required final String userId,
      required final String accountNumber,
      final String cardNumber,
      final String cvv,
      final String expiryDate,
      final String holderName,
      final double balance,
      final double availableBalance,
      final String currency,
      required final AccountType type,
      required final String label,
      final AccountStatus status,
      final CardNetwork cardNetwork,
      final List<String> cardGradientColors}) = _$AccountImpl;

  factory _Account.fromJson(Map<String, dynamic> json) = _$AccountImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get accountNumber;
  @override
  String get cardNumber;
  @override
  String get cvv;
  @override
  String get expiryDate;
  @override
  String get holderName;
  @override
  double get balance;
  @override
  double get availableBalance;
  @override
  String get currency;
  @override
  AccountType get type;
  @override
  String get label;
  @override
  AccountStatus get status;
  @override
  CardNetwork get cardNetwork;
  @override
  List<String> get cardGradientColors;
  @override
  @JsonKey(ignore: true)
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
