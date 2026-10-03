import 'money.dart';
import '../enums/personal_enums.dart';

enum BudgetStatus {
  normal,
  approachingLimit,
  exceeded,
  underBudget,
  nearLimit;

  String get displayName {
    switch (this) {
      case BudgetStatus.normal:
      case BudgetStatus.underBudget:
        return 'Under Budget';
      case BudgetStatus.approachingLimit:
      case BudgetStatus.nearLimit:
        return 'Near Limit';
      case BudgetStatus.exceeded:
        return 'Exceeded';
    }
  }

  bool get isUnderBudget => this == BudgetStatus.normal || this == BudgetStatus.underBudget;
  bool get isNearLimit => this == BudgetStatus.approachingLimit || this == BudgetStatus.nearLimit;
  bool get isExceeded => this == BudgetStatus.exceeded;
}

class BudgetDateRange {
  /// Calculates the current calendar month range without hardcoding month lengths.
  /// Correctly handles 28, 29, 30, and 31 days.
  static ({DateTime start, DateTime end}) currentMonthRange([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final start = DateTime(now.year, now.month, 1, 0, 0, 0);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    return (start: start, end: end);
  }
}

class Budget {
  final String id;
  final String categoryId;
  final String categoryName;
  final Money limitAmount;
  final Money spentAmount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.limitAmount,
    required this.spentAmount,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  Money get remainingAmount => limitAmount - spentAmount;

  /// Progress ratio clamped strictly between 0.0 and 1.0 for visual progress bars.
  double get progress {
    if (limitAmount.minorUnits <= 0) return 0.0;
    return (spentAmount.minorUnits / limitAmount.minorUnits).clamp(0.0, 1.0);
  }

  double get usagePercentage {
    if (limitAmount.minorUnits <= 0) return 0.0;
    return (spentAmount.minorUnits / limitAmount.minorUnits) * 100.0;
  }

  bool get isExceeded => spentAmount.minorUnits > limitAmount.minorUnits;
  bool get isApproachingLimit => usagePercentage >= 80.0 && !isExceeded;
  bool get isNearLimit => isApproachingLimit;
  bool get isUnderBudget => !isApproachingLimit && !isExceeded;

  BudgetStatus get status {
    if (isExceeded) return BudgetStatus.exceeded;
    if (isApproachingLimit) return BudgetStatus.approachingLimit;
    return BudgetStatus.normal;
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    Money? limitAmount,
    Money? spentAmount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Represents a budget dynamically evaluated against transaction spending.
class CalculatedBudget {
  final Budget budget;
  final Money spentAmount;

  const CalculatedBudget({
    required this.budget,
    required this.spentAmount,
  });

  String get id => budget.id;
  String get categoryId => budget.categoryId;
  String get categoryName => budget.categoryName;
  Money get limitAmount => budget.limitAmount;
  BudgetPeriod get period => budget.period;
  DateTime get startDate => budget.startDate;
  DateTime get endDate => budget.endDate;

  Money get remainingAmount {
    if (spentAmount.minorUnits >= limitAmount.minorUnits) {
      return Money.zero(limitAmount.currencyCode);
    }
    return limitAmount - spentAmount;
  }

  /// Clamped between 0.0 and 1.0 for visual progress bars.
  double get progress {
    if (limitAmount.minorUnits <= 0) return 0.0;
    return (spentAmount.minorUnits / limitAmount.minorUnits).clamp(0.0, 1.0);
  }

  /// Exact percentage (can exceed 100%).
  double get usagePercentage {
    if (limitAmount.minorUnits <= 0) return 0.0;
    return (spentAmount.minorUnits / limitAmount.minorUnits) * 100.0;
  }

  bool get isExceeded => spentAmount.minorUnits > limitAmount.minorUnits;
  bool get isNearLimit => usagePercentage >= 80.0 && !isExceeded;
  bool get isUnderBudget => !isNearLimit && !isExceeded;

  BudgetStatus get status {
    if (isExceeded) return BudgetStatus.exceeded;
    if (isNearLimit) return BudgetStatus.approachingLimit;
    return BudgetStatus.normal;
  }
}

