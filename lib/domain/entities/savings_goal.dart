import 'money.dart';
import '../enums/personal_enums.dart';

class SavingsGoal {
  final String id;
  final String title;
  final Money targetAmount;
  final Money savedAmount;
  final DateTime? targetDate;
  final GoalStatus status;
  final String iconName;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    this.targetDate,
    required this.status,
    this.iconName = 'piggyBank',
    this.description = '',
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Aliases for prompt naming conformance
  String get name => title;
  Money get currentAmount => savedAmount;
  Money get progressAmount => savedAmount;
  String get currency => targetAmount.currencyCode;

  /// Remaining amount to reach target (never negative)
  Money get remainingAmount {
    if (savedAmount.minorUnits >= targetAmount.minorUnits) {
      return Money.zero(targetAmount.currencyCode);
    }
    return targetAmount - savedAmount;
  }

  /// Progress ratio clamped strictly between 0.0 and 1.0
  double get progressPercentage {
    if (targetAmount.minorUnits <= 0) return 0.0;
    return (savedAmount.minorUnits / targetAmount.minorUnits).clamp(0.0, 1.0);
  }

  /// Percentage scaled to 0..100% for UI label formatting
  double get progressPercentage100 {
    if (targetAmount.minorUnits <= 0) return 0.0;
    return (savedAmount.minorUnits / targetAmount.minorUnits * 100.0).clamp(0.0, 100.0);
  }

  bool get isAchieved => savedAmount.minorUnits >= targetAmount.minorUnits;
  bool get isCompleted => isAchieved || status.isCompleted;

  SavingsGoal copyWith({
    String? id,
    String? title,
    Money? targetAmount,
    Money? savedAmount,
    DateTime? targetDate,
    GoalStatus? status,
    String? iconName,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      iconName: iconName ?? this.iconName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoal &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SavingsGoal(id: $id, title: $title, saved: $savedAmount, target: $targetAmount, status: $status)';
}

class GoalContribution {
  final String id;
  final String goalId;
  final Money amount;
  final DateTime date;
  final String note;

  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    required this.note,
  });
}

