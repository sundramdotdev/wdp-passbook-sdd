import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/domain/entities/budget.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

void main() {
  group('BudgetDateRange Accurate Calendar Calculations', () {
    test('Calculates 31-day month accurately (January)', () {
      final ref = DateTime(2026, 1, 15);
      final range = BudgetDateRange.currentMonthRange(ref);

      expect(range.start.year, equals(2026));
      expect(range.start.month, equals(1));
      expect(range.start.day, equals(1));

      expect(range.end.year, equals(2026));
      expect(range.end.month, equals(1));
      expect(range.end.day, equals(31));
      expect(range.end.hour, equals(23));
      expect(range.end.minute, equals(59));
      expect(range.end.second, equals(59));
    });

    test('Calculates 30-day month accurately (April)', () {
      final ref = DateTime(2026, 4, 10);
      final range = BudgetDateRange.currentMonthRange(ref);

      expect(range.start.day, equals(1));
      expect(range.end.month, equals(4));
      expect(range.end.day, equals(30));
    });

    test('Calculates February in non-leap year (28 days, e.g. 2023)', () {
      final ref = DateTime(2023, 2, 14);
      final range = BudgetDateRange.currentMonthRange(ref);

      expect(range.start.day, equals(1));
      expect(range.end.month, equals(2));
      expect(range.end.day, equals(28));
    });

    test('Calculates February in leap year (29 days, e.g. 2024)', () {
      final ref = DateTime(2024, 2, 5);
      final range = BudgetDateRange.currentMonthRange(ref);

      expect(range.start.day, equals(1));
      expect(range.end.month, equals(2));
      expect(range.end.day, equals(29));
    });
  });

  group('Budget & CalculatedBudget Domain Invariants', () {
    final range = BudgetDateRange.currentMonthRange(DateTime(2026, 9, 1));

    test('Under budget status when spending is below 80%', () {
      final budget = Budget(
        id: 'budget-1',
        categoryId: 'cat-food',
        categoryName: 'Food & Dining',
        limitAmount: const Money(minorUnits: 1000000), // ₹10,000
        spentAmount: const Money(minorUnits: 500000),  // ₹5,000 (50%)
        period: BudgetPeriod.monthly,
        startDate: range.start,
        endDate: range.end,
      );

      expect(budget.progress, equals(0.5));
      expect(budget.usagePercentage, equals(50.0));
      expect(budget.remainingAmount.minorUnits, equals(500000));
      expect(budget.isUnderBudget, isTrue);
      expect(budget.isNearLimit, isFalse);
      expect(budget.isExceeded, isFalse);
      expect(budget.status, equals(BudgetStatus.normal));
      expect(budget.status.isUnderBudget, isTrue);
    });

    test('Near limit status when spending is between 80% and 100%', () {
      final budget = Budget(
        id: 'budget-2',
        categoryId: 'cat-shopping',
        categoryName: 'Shopping',
        limitAmount: const Money(minorUnits: 1000000), // ₹10,000
        spentAmount: const Money(minorUnits: 850000),  // ₹8,500 (85%)
        period: BudgetPeriod.monthly,
        startDate: range.start,
        endDate: range.end,
      );

      expect(budget.progress, equals(0.85));
      expect(budget.usagePercentage, equals(85.0));
      expect(budget.remainingAmount.minorUnits, equals(150000));
      expect(budget.isUnderBudget, isFalse);
      expect(budget.isNearLimit, isTrue);
      expect(budget.isApproachingLimit, isTrue);
      expect(budget.isExceeded, isFalse);
      expect(budget.status, equals(BudgetStatus.approachingLimit));
      expect(budget.status.isNearLimit, isTrue);
    });

    test('Exceeded status when spending is above 100%', () {
      final budget = Budget(
        id: 'budget-3',
        categoryId: 'cat-travel',
        categoryName: 'Travel',
        limitAmount: const Money(minorUnits: 1000000), // ₹10,000
        spentAmount: const Money(minorUnits: 1200000), // ₹12,000 (120%)
        period: BudgetPeriod.monthly,
        startDate: range.start,
        endDate: range.end,
      );

      expect(budget.progress, equals(1.0)); // Progress clamped to 1.0 for UI bars
      expect(budget.usagePercentage, equals(120.0));
      expect(budget.remainingAmount.minorUnits, equals(-200000));
      expect(budget.isUnderBudget, isFalse);
      expect(budget.isNearLimit, isFalse);
      expect(budget.isExceeded, isTrue);
      expect(budget.status, equals(BudgetStatus.exceeded));
      expect(budget.status.isExceeded, isTrue);
    });

    test('CalculatedBudget Value Object works identically', () {
      final baseBudget = Budget(
        id: 'cb-1',
        categoryId: 'cat-groceries',
        categoryName: 'Groceries',
        limitAmount: const Money(minorUnits: 500000),
        spentAmount: Money.zero(),
        period: BudgetPeriod.monthly,
        startDate: range.start,
        endDate: range.end,
      );

      final cb = CalculatedBudget(
        budget: baseBudget,
        spentAmount: const Money(minorUnits: 450000), // 90%
      );

      expect(cb.progress, equals(0.9));
      expect(cb.usagePercentage, equals(90.0));
      expect(cb.isNearLimit, isTrue);
      expect(cb.isUnderBudget, isFalse);
      expect(cb.isExceeded, isFalse);
      expect(cb.status.isNearLimit, isTrue);
      expect(cb.status, equals(BudgetStatus.approachingLimit));
    });
  });
}
