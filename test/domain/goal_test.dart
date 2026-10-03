import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/entities/savings_goal.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

void main() {
  group('SavingsGoal Domain Entity & Invariants', () {
    test('Initializes with correct fields and default progress', () {
      final goal = SavingsGoal(
        id: 'goal-1',
        title: 'Emergency Fund',
        targetAmount: const Money(minorUnits: 5000000), // ₹50,000
        savedAmount: Money.zero(),
        status: GoalStatus.active,
        iconName: 'piggyBank',
      );

      expect(goal.title, equals('Emergency Fund'));
      expect(goal.name, equals('Emergency Fund'));
      expect(goal.targetAmount.minorUnits, equals(5000000));
      expect(goal.savedAmount.minorUnits, equals(0));
      expect(goal.currentAmount.minorUnits, equals(0));
      expect(goal.progressPercentage, equals(0.0));
      expect(goal.progressPercentage100, equals(0.0));
      expect(goal.remainingAmount.minorUnits, equals(5000000));
      expect(goal.isAchieved, isFalse);
      expect(goal.isCompleted, isFalse);
    });

    test('Halfway progress calculation', () {
      final goal = SavingsGoal(
        id: 'goal-2',
        title: 'New Laptop',
        targetAmount: const Money(minorUnits: 10000000), // ₹1,00,000
        savedAmount: const Money(minorUnits: 5000000),  // ₹50,000
        status: GoalStatus.active,
      );

      expect(goal.progressPercentage, equals(0.5));
      expect(goal.progressPercentage100, equals(50.0));
      expect(goal.remainingAmount.minorUnits, equals(5000000));
      expect(goal.isAchieved, isFalse);
    });

    test('Goal reached target (100% achieved)', () {
      final goal = SavingsGoal(
        id: 'goal-3',
        title: 'Vacation',
        targetAmount: const Money(minorUnits: 2500000), // ₹25,000
        savedAmount: const Money(minorUnits: 2500000),  // ₹25,000
        status: GoalStatus.completed,
      );

      expect(goal.progressPercentage, equals(1.0));
      expect(goal.progressPercentage100, equals(100.0));
      expect(goal.remainingAmount.minorUnits, equals(0));
      expect(goal.isAchieved, isTrue);
      expect(goal.isCompleted, isTrue);
    });

    test('Progress percentage is strictly clamped between 0.0 and 1.0 even if overfunded', () {
      final goal = SavingsGoal(
        id: 'goal-4',
        title: 'Overfunded Goal',
        targetAmount: const Money(minorUnits: 2000000), // ₹20,000
        savedAmount: const Money(minorUnits: 3000000),  // ₹30,000 (150%)
        status: GoalStatus.completed,
      );

      expect(goal.progressPercentage, equals(1.0)); // Clamped to 1.0
      expect(goal.progressPercentage100, equals(100.0)); // Clamped to 100.0
      expect(goal.remainingAmount.minorUnits, equals(0)); // Never negative
      expect(goal.isAchieved, isTrue);
    });

    test('Zero target amount edge case does not divide by zero', () {
      final goal = SavingsGoal(
        id: 'goal-5',
        title: 'Zero Target Goal',
        targetAmount: Money.zero(),
        savedAmount: Money.zero(),
        status: GoalStatus.active,
      );

      expect(goal.progressPercentage, equals(0.0));
      expect(goal.progressPercentage100, equals(0.0));
    });

    test('GoalStatus enum properties and helpers', () {
      expect(GoalStatus.active.isCompleted, isFalse);
      expect(GoalStatus.completed.isCompleted, isTrue);
      expect(GoalStatus.archived.isCompleted, isFalse);
    });
  });
}
