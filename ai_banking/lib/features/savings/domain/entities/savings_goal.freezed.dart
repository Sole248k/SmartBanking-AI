// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SavingsDepositEntry _$SavingsDepositEntryFromJson(Map<String, dynamic> json) {
  return _SavingsDepositEntry.fromJson(json);
}

/// @nodoc
mixin _$SavingsDepositEntry {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isAutoDeposit => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SavingsDepositEntryCopyWith<SavingsDepositEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavingsDepositEntryCopyWith<$Res> {
  factory $SavingsDepositEntryCopyWith(
          SavingsDepositEntry value, $Res Function(SavingsDepositEntry) then) =
      _$SavingsDepositEntryCopyWithImpl<$Res, SavingsDepositEntry>;
  @useResult
  $Res call(
      {String id,
      double amount,
      DateTime timestamp,
      bool isAutoDeposit,
      String? notes});
}

/// @nodoc
class _$SavingsDepositEntryCopyWithImpl<$Res, $Val extends SavingsDepositEntry>
    implements $SavingsDepositEntryCopyWith<$Res> {
  _$SavingsDepositEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? timestamp = null,
    Object? isAutoDeposit = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAutoDeposit: null == isAutoDeposit
          ? _value.isAutoDeposit
          : isAutoDeposit // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SavingsDepositEntryImplCopyWith<$Res>
    implements $SavingsDepositEntryCopyWith<$Res> {
  factory _$$SavingsDepositEntryImplCopyWith(_$SavingsDepositEntryImpl value,
          $Res Function(_$SavingsDepositEntryImpl) then) =
      __$$SavingsDepositEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double amount,
      DateTime timestamp,
      bool isAutoDeposit,
      String? notes});
}

/// @nodoc
class __$$SavingsDepositEntryImplCopyWithImpl<$Res>
    extends _$SavingsDepositEntryCopyWithImpl<$Res, _$SavingsDepositEntryImpl>
    implements _$$SavingsDepositEntryImplCopyWith<$Res> {
  __$$SavingsDepositEntryImplCopyWithImpl(_$SavingsDepositEntryImpl _value,
      $Res Function(_$SavingsDepositEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? timestamp = null,
    Object? isAutoDeposit = null,
    Object? notes = freezed,
  }) {
    return _then(_$SavingsDepositEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAutoDeposit: null == isAutoDeposit
          ? _value.isAutoDeposit
          : isAutoDeposit // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SavingsDepositEntryImpl implements _SavingsDepositEntry {
  const _$SavingsDepositEntryImpl(
      {required this.id,
      required this.amount,
      required this.timestamp,
      this.isAutoDeposit = false,
      this.notes});

  factory _$SavingsDepositEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavingsDepositEntryImplFromJson(json);

  @override
  final String id;
  @override
  final double amount;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool isAutoDeposit;
  @override
  final String? notes;

  @override
  String toString() {
    return 'SavingsDepositEntry(id: $id, amount: $amount, timestamp: $timestamp, isAutoDeposit: $isAutoDeposit, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavingsDepositEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isAutoDeposit, isAutoDeposit) ||
                other.isAutoDeposit == isAutoDeposit) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, amount, timestamp, isAutoDeposit, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SavingsDepositEntryImplCopyWith<_$SavingsDepositEntryImpl> get copyWith =>
      __$$SavingsDepositEntryImplCopyWithImpl<_$SavingsDepositEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavingsDepositEntryImplToJson(
      this,
    );
  }
}

abstract class _SavingsDepositEntry implements SavingsDepositEntry {
  const factory _SavingsDepositEntry(
      {required final String id,
      required final double amount,
      required final DateTime timestamp,
      final bool isAutoDeposit,
      final String? notes}) = _$SavingsDepositEntryImpl;

  factory _SavingsDepositEntry.fromJson(Map<String, dynamic> json) =
      _$SavingsDepositEntryImpl.fromJson;

  @override
  String get id;
  @override
  double get amount;
  @override
  DateTime get timestamp;
  @override
  bool get isAutoDeposit;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$SavingsDepositEntryImplCopyWith<_$SavingsDepositEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SavingsGoal _$SavingsGoalFromJson(Map<String, dynamic> json) {
  return _SavingsGoal.fromJson(json);
}

/// @nodoc
mixin _$SavingsGoal {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get targetAmount => throw _privateConstructorUsedError;
  double get currentAmount => throw _privateConstructorUsedError;
  DateTime? get deadline => throw _privateConstructorUsedError;
  String get iconName => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;
  bool get isAutoDeposit => throw _privateConstructorUsedError;
  double get autoDepositAmount => throw _privateConstructorUsedError;
  String? get autoDepositFrequency => throw _privateConstructorUsedError;
  SavingsGoalStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<SavingsDepositEntry> get deposits => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SavingsGoalCopyWith<SavingsGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavingsGoalCopyWith<$Res> {
  factory $SavingsGoalCopyWith(
          SavingsGoal value, $Res Function(SavingsGoal) then) =
      _$SavingsGoalCopyWithImpl<$Res, SavingsGoal>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String? description,
      double targetAmount,
      double currentAmount,
      DateTime? deadline,
      String iconName,
      String colorHex,
      bool isAutoDeposit,
      double autoDepositAmount,
      String? autoDepositFrequency,
      SavingsGoalStatus status,
      DateTime createdAt,
      List<SavingsDepositEntry> deposits});
}

/// @nodoc
class _$SavingsGoalCopyWithImpl<$Res, $Val extends SavingsGoal>
    implements $SavingsGoalCopyWith<$Res> {
  _$SavingsGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? deadline = freezed,
    Object? iconName = null,
    Object? colorHex = null,
    Object? isAutoDeposit = null,
    Object? autoDepositAmount = null,
    Object? autoDepositFrequency = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? deposits = null,
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currentAmount: null == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      iconName: null == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String,
      colorHex: null == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String,
      isAutoDeposit: null == isAutoDeposit
          ? _value.isAutoDeposit
          : isAutoDeposit // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDepositAmount: null == autoDepositAmount
          ? _value.autoDepositAmount
          : autoDepositAmount // ignore: cast_nullable_to_non_nullable
              as double,
      autoDepositFrequency: freezed == autoDepositFrequency
          ? _value.autoDepositFrequency
          : autoDepositFrequency // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SavingsGoalStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deposits: null == deposits
          ? _value.deposits
          : deposits // ignore: cast_nullable_to_non_nullable
              as List<SavingsDepositEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SavingsGoalImplCopyWith<$Res>
    implements $SavingsGoalCopyWith<$Res> {
  factory _$$SavingsGoalImplCopyWith(
          _$SavingsGoalImpl value, $Res Function(_$SavingsGoalImpl) then) =
      __$$SavingsGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String? description,
      double targetAmount,
      double currentAmount,
      DateTime? deadline,
      String iconName,
      String colorHex,
      bool isAutoDeposit,
      double autoDepositAmount,
      String? autoDepositFrequency,
      SavingsGoalStatus status,
      DateTime createdAt,
      List<SavingsDepositEntry> deposits});
}

/// @nodoc
class __$$SavingsGoalImplCopyWithImpl<$Res>
    extends _$SavingsGoalCopyWithImpl<$Res, _$SavingsGoalImpl>
    implements _$$SavingsGoalImplCopyWith<$Res> {
  __$$SavingsGoalImplCopyWithImpl(
      _$SavingsGoalImpl _value, $Res Function(_$SavingsGoalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? deadline = freezed,
    Object? iconName = null,
    Object? colorHex = null,
    Object? isAutoDeposit = null,
    Object? autoDepositAmount = null,
    Object? autoDepositFrequency = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? deposits = null,
  }) {
    return _then(_$SavingsGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currentAmount: null == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      iconName: null == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String,
      colorHex: null == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String,
      isAutoDeposit: null == isAutoDeposit
          ? _value.isAutoDeposit
          : isAutoDeposit // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDepositAmount: null == autoDepositAmount
          ? _value.autoDepositAmount
          : autoDepositAmount // ignore: cast_nullable_to_non_nullable
              as double,
      autoDepositFrequency: freezed == autoDepositFrequency
          ? _value.autoDepositFrequency
          : autoDepositFrequency // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SavingsGoalStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deposits: null == deposits
          ? _value._deposits
          : deposits // ignore: cast_nullable_to_non_nullable
              as List<SavingsDepositEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SavingsGoalImpl extends _SavingsGoal {
  const _$SavingsGoalImpl(
      {required this.id,
      required this.userId,
      required this.title,
      this.description,
      required this.targetAmount,
      required this.currentAmount,
      this.deadline,
      this.iconName = 'savings',
      this.colorHex = '#4F6EF7',
      this.isAutoDeposit = false,
      this.autoDepositAmount = 0.0,
      this.autoDepositFrequency,
      this.status = SavingsGoalStatus.active,
      required this.createdAt,
      final List<SavingsDepositEntry> deposits = const []})
      : _deposits = deposits,
        super._();

  factory _$SavingsGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavingsGoalImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final double targetAmount;
  @override
  final double currentAmount;
  @override
  final DateTime? deadline;
  @override
  @JsonKey()
  final String iconName;
  @override
  @JsonKey()
  final String colorHex;
  @override
  @JsonKey()
  final bool isAutoDeposit;
  @override
  @JsonKey()
  final double autoDepositAmount;
  @override
  final String? autoDepositFrequency;
  @override
  @JsonKey()
  final SavingsGoalStatus status;
  @override
  final DateTime createdAt;
  final List<SavingsDepositEntry> _deposits;
  @override
  @JsonKey()
  List<SavingsDepositEntry> get deposits {
    if (_deposits is EqualUnmodifiableListView) return _deposits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deposits);
  }

  @override
  String toString() {
    return 'SavingsGoal(id: $id, userId: $userId, title: $title, description: $description, targetAmount: $targetAmount, currentAmount: $currentAmount, deadline: $deadline, iconName: $iconName, colorHex: $colorHex, isAutoDeposit: $isAutoDeposit, autoDepositAmount: $autoDepositAmount, autoDepositFrequency: $autoDepositFrequency, status: $status, createdAt: $createdAt, deposits: $deposits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavingsGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.isAutoDeposit, isAutoDeposit) ||
                other.isAutoDeposit == isAutoDeposit) &&
            (identical(other.autoDepositAmount, autoDepositAmount) ||
                other.autoDepositAmount == autoDepositAmount) &&
            (identical(other.autoDepositFrequency, autoDepositFrequency) ||
                other.autoDepositFrequency == autoDepositFrequency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._deposits, _deposits));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      description,
      targetAmount,
      currentAmount,
      deadline,
      iconName,
      colorHex,
      isAutoDeposit,
      autoDepositAmount,
      autoDepositFrequency,
      status,
      createdAt,
      const DeepCollectionEquality().hash(_deposits));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SavingsGoalImplCopyWith<_$SavingsGoalImpl> get copyWith =>
      __$$SavingsGoalImplCopyWithImpl<_$SavingsGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavingsGoalImplToJson(
      this,
    );
  }
}

abstract class _SavingsGoal extends SavingsGoal {
  const factory _SavingsGoal(
      {required final String id,
      required final String userId,
      required final String title,
      final String? description,
      required final double targetAmount,
      required final double currentAmount,
      final DateTime? deadline,
      final String iconName,
      final String colorHex,
      final bool isAutoDeposit,
      final double autoDepositAmount,
      final String? autoDepositFrequency,
      final SavingsGoalStatus status,
      required final DateTime createdAt,
      final List<SavingsDepositEntry> deposits}) = _$SavingsGoalImpl;
  const _SavingsGoal._() : super._();

  factory _SavingsGoal.fromJson(Map<String, dynamic> json) =
      _$SavingsGoalImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  String? get description;
  @override
  double get targetAmount;
  @override
  double get currentAmount;
  @override
  DateTime? get deadline;
  @override
  String get iconName;
  @override
  String get colorHex;
  @override
  bool get isAutoDeposit;
  @override
  double get autoDepositAmount;
  @override
  String? get autoDepositFrequency;
  @override
  SavingsGoalStatus get status;
  @override
  DateTime get createdAt;
  @override
  List<SavingsDepositEntry> get deposits;
  @override
  @JsonKey(ignore: true)
  _$$SavingsGoalImplCopyWith<_$SavingsGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
