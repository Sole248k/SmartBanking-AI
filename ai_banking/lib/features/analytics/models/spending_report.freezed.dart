// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spending_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpendingReport _$SpendingReportFromJson(Map<String, dynamic> json) {
  return _SpendingReport.fromJson(json);
}

/// @nodoc
mixin _$SpendingReport {
  double get totalSpent => throw _privateConstructorUsedError;
  double get totalIncome => throw _privateConstructorUsedError;
  Map<String, double> get categoryBreakdown =>
      throw _privateConstructorUsedError;
  List<DailyPoint> get dailyTrend => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SpendingReportCopyWith<SpendingReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpendingReportCopyWith<$Res> {
  factory $SpendingReportCopyWith(
          SpendingReport value, $Res Function(SpendingReport) then) =
      _$SpendingReportCopyWithImpl<$Res, SpendingReport>;
  @useResult
  $Res call(
      {double totalSpent,
      double totalIncome,
      Map<String, double> categoryBreakdown,
      List<DailyPoint> dailyTrend});
}

/// @nodoc
class _$SpendingReportCopyWithImpl<$Res, $Val extends SpendingReport>
    implements $SpendingReportCopyWith<$Res> {
  _$SpendingReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSpent = null,
    Object? totalIncome = null,
    Object? categoryBreakdown = null,
    Object? dailyTrend = null,
  }) {
    return _then(_value.copyWith(
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as double,
      totalIncome: null == totalIncome
          ? _value.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as double,
      categoryBreakdown: null == categoryBreakdown
          ? _value.categoryBreakdown
          : categoryBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      dailyTrend: null == dailyTrend
          ? _value.dailyTrend
          : dailyTrend // ignore: cast_nullable_to_non_nullable
              as List<DailyPoint>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpendingReportImplCopyWith<$Res>
    implements $SpendingReportCopyWith<$Res> {
  factory _$$SpendingReportImplCopyWith(_$SpendingReportImpl value,
          $Res Function(_$SpendingReportImpl) then) =
      __$$SpendingReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double totalSpent,
      double totalIncome,
      Map<String, double> categoryBreakdown,
      List<DailyPoint> dailyTrend});
}

/// @nodoc
class __$$SpendingReportImplCopyWithImpl<$Res>
    extends _$SpendingReportCopyWithImpl<$Res, _$SpendingReportImpl>
    implements _$$SpendingReportImplCopyWith<$Res> {
  __$$SpendingReportImplCopyWithImpl(
      _$SpendingReportImpl _value, $Res Function(_$SpendingReportImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSpent = null,
    Object? totalIncome = null,
    Object? categoryBreakdown = null,
    Object? dailyTrend = null,
  }) {
    return _then(_$SpendingReportImpl(
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as double,
      totalIncome: null == totalIncome
          ? _value.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as double,
      categoryBreakdown: null == categoryBreakdown
          ? _value._categoryBreakdown
          : categoryBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      dailyTrend: null == dailyTrend
          ? _value._dailyTrend
          : dailyTrend // ignore: cast_nullable_to_non_nullable
              as List<DailyPoint>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpendingReportImpl implements _SpendingReport {
  const _$SpendingReportImpl(
      {this.totalSpent = 0.0,
      this.totalIncome = 0.0,
      final Map<String, double> categoryBreakdown = const {},
      final List<DailyPoint> dailyTrend = const []})
      : _categoryBreakdown = categoryBreakdown,
        _dailyTrend = dailyTrend;

  factory _$SpendingReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpendingReportImplFromJson(json);

  @override
  @JsonKey()
  final double totalSpent;
  @override
  @JsonKey()
  final double totalIncome;
  final Map<String, double> _categoryBreakdown;
  @override
  @JsonKey()
  Map<String, double> get categoryBreakdown {
    if (_categoryBreakdown is EqualUnmodifiableMapView)
      return _categoryBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryBreakdown);
  }

  final List<DailyPoint> _dailyTrend;
  @override
  @JsonKey()
  List<DailyPoint> get dailyTrend {
    if (_dailyTrend is EqualUnmodifiableListView) return _dailyTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyTrend);
  }

  @override
  String toString() {
    return 'SpendingReport(totalSpent: $totalSpent, totalIncome: $totalIncome, categoryBreakdown: $categoryBreakdown, dailyTrend: $dailyTrend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpendingReportImpl &&
            (identical(other.totalSpent, totalSpent) ||
                other.totalSpent == totalSpent) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            const DeepCollectionEquality()
                .equals(other._categoryBreakdown, _categoryBreakdown) &&
            const DeepCollectionEquality()
                .equals(other._dailyTrend, _dailyTrend));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalSpent,
      totalIncome,
      const DeepCollectionEquality().hash(_categoryBreakdown),
      const DeepCollectionEquality().hash(_dailyTrend));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpendingReportImplCopyWith<_$SpendingReportImpl> get copyWith =>
      __$$SpendingReportImplCopyWithImpl<_$SpendingReportImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpendingReportImplToJson(
      this,
    );
  }
}

abstract class _SpendingReport implements SpendingReport {
  const factory _SpendingReport(
      {final double totalSpent,
      final double totalIncome,
      final Map<String, double> categoryBreakdown,
      final List<DailyPoint> dailyTrend}) = _$SpendingReportImpl;

  factory _SpendingReport.fromJson(Map<String, dynamic> json) =
      _$SpendingReportImpl.fromJson;

  @override
  double get totalSpent;
  @override
  double get totalIncome;
  @override
  Map<String, double> get categoryBreakdown;
  @override
  List<DailyPoint> get dailyTrend;
  @override
  @JsonKey(ignore: true)
  _$$SpendingReportImplCopyWith<_$SpendingReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPoint _$DailyPointFromJson(Map<String, dynamic> json) {
  return _DailyPoint.fromJson(json);
}

/// @nodoc
mixin _$DailyPoint {
  DateTime get date => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyPointCopyWith<DailyPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPointCopyWith<$Res> {
  factory $DailyPointCopyWith(
          DailyPoint value, $Res Function(DailyPoint) then) =
      _$DailyPointCopyWithImpl<$Res, DailyPoint>;
  @useResult
  $Res call({DateTime date, double value});
}

/// @nodoc
class _$DailyPointCopyWithImpl<$Res, $Val extends DailyPoint>
    implements $DailyPointCopyWith<$Res> {
  _$DailyPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyPointImplCopyWith<$Res>
    implements $DailyPointCopyWith<$Res> {
  factory _$$DailyPointImplCopyWith(
          _$DailyPointImpl value, $Res Function(_$DailyPointImpl) then) =
      __$$DailyPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, double value});
}

/// @nodoc
class __$$DailyPointImplCopyWithImpl<$Res>
    extends _$DailyPointCopyWithImpl<$Res, _$DailyPointImpl>
    implements _$$DailyPointImplCopyWith<$Res> {
  __$$DailyPointImplCopyWithImpl(
      _$DailyPointImpl _value, $Res Function(_$DailyPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
  }) {
    return _then(_$DailyPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPointImpl implements _DailyPoint {
  const _$DailyPointImpl({required this.date, this.value = 0.0});

  factory _$DailyPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPointImplFromJson(json);

  @override
  final DateTime date;
  @override
  @JsonKey()
  final double value;

  @override
  String toString() {
    return 'DailyPoint(date: $date, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPointImplCopyWith<_$DailyPointImpl> get copyWith =>
      __$$DailyPointImplCopyWithImpl<_$DailyPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPointImplToJson(
      this,
    );
  }
}

abstract class _DailyPoint implements DailyPoint {
  const factory _DailyPoint(
      {required final DateTime date, final double value}) = _$DailyPointImpl;

  factory _DailyPoint.fromJson(Map<String, dynamic> json) =
      _$DailyPointImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get value;
  @override
  @JsonKey(ignore: true)
  _$$DailyPointImplCopyWith<_$DailyPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
