import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

enum SavingsGoalStatus { active, completed, paused, cancelled }

@freezed
class SavingsDepositEntry with _$SavingsDepositEntry {
  const factory SavingsDepositEntry({
    required String id,
    required double amount,
    required DateTime timestamp,
    @Default(false) bool isAutoDeposit,
    String? notes,
  }) = _SavingsDepositEntry;

  factory SavingsDepositEntry.fromJson(Map<String, dynamic> json) => _$SavingsDepositEntryFromJson(json);
}

@freezed
class SavingsGoal with _$SavingsGoal {
  const SavingsGoal._();

  const factory SavingsGoal({
    required String id,
    required String userId,
    required String title,
    String? description,
    required double targetAmount,
    required double currentAmount,
    DateTime? deadline,
    @Default('savings') String iconName,
    @Default('#4F6EF7') String colorHex,
    @Default(false) bool isAutoDeposit,
    @Default(0.0) double autoDepositAmount,
    String? autoDepositFrequency,
    @Default(SavingsGoalStatus.active) SavingsGoalStatus status,
    required DateTime createdAt,
    @Default([]) List<SavingsDepositEntry> deposits,
  }) = _SavingsGoal;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => _$SavingsGoalFromJson(json);

  double get progressPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remaining => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  bool get isCompleted => currentAmount >= targetAmount;

  int? get daysRemaining {
    if (deadline == null) return null;
    final diff = deadline!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
}
