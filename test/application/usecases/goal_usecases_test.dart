import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/commands/goal_commands.dart';
import 'package:wdp_passbook/application/usecases/goal_usecases.dart';
import 'package:wdp_passbook/core/errors/failures.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

import '../fakes/fake_repositories.dart';

void main() {
  group('Goal Use Cases & Invariants', () {
    late FakeGoalRepository goalRepo;
    late CreateGoalUseCase createGoalUseCase;
    late AddGoalMoneyUseCase addGoalMoneyUseCase;
    late RemoveGoalMoneyUseCase removeGoalMoneyUseCase;
    late ArchiveGoalUseCase archiveGoalUseCase;
    late GetGoalsUseCase getGoalsUseCase;

    setUp(() {
      goalRepo = FakeGoalRepository();
      createGoalUseCase = CreateGoalUseCase(goalRepo);
      addGoalMoneyUseCase = AddGoalMoneyUseCase(goalRepo);
      removeGoalMoneyUseCase = RemoveGoalMoneyUseCase(goalRepo);
      archiveGoalUseCase = ArchiveGoalUseCase(goalRepo);
      getGoalsUseCase = GetGoalsUseCase(goalRepo);
    });

    test('Creates valid Savings Goal', () async {
      final res = await createGoalUseCase(
        const CreateGoalCommand(
          title: 'Car Down Payment',
          targetAmount: Money(minorUnits: 20000000), // ₹2,00,000
          iconName: 'car',
        ),
      );

      expect(res.isSuccess, isTrue);
      final goal = res.valueOrNull!;
      expect(goal.title, equals('Car Down Payment'));
      expect(goal.targetAmount.minorUnits, equals(20000000));
      expect(goal.savedAmount.minorUnits, equals(0));
      expect(goal.status, equals(GoalStatus.active));
      expect(goal.isCompleted, isFalse);
    });

    test('Rejects goal with zero or negative target amount', () async {
      final res = await createGoalUseCase(
        const CreateGoalCommand(
          title: 'Invalid Target Goal',
          targetAmount: Money(minorUnits: 0),
        ),
      );

      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('Rejects goal with empty title', () async {
      final res = await createGoalUseCase(
        const CreateGoalCommand(
          title: '   ',
          targetAmount: Money(minorUnits: 500000),
        ),
      );

      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('Add money increases saved amount and updates progress', () async {
      final createRes = await createGoalUseCase(
        const CreateGoalCommand(
          title: 'Emergency Fund',
          targetAmount: Money(minorUnits: 10000000), // ₹1,00,000
        ),
      );
      final goal = createRes.valueOrNull!;

      // Add ₹25,000 contribution
      final addRes = await addGoalMoneyUseCase(
        AddGoalMoneyCommand(
          goalId: goal.id,
          amount: const Money(minorUnits: 2500000),
          note: 'First monthly deposit',
        ),
      );

      expect(addRes.isSuccess, isTrue);
      final updated = addRes.valueOrNull!;
      expect(updated.savedAmount.minorUnits, equals(2500000));
      expect(updated.progressPercentage, equals(0.25));
      expect(updated.remainingAmount.minorUnits, equals(7500000));
      expect(updated.status, equals(GoalStatus.active));
    });

    test('Goal automatically reaches completed status when target is achieved', () async {
      final createRes = await createGoalUseCase(
        const CreateGoalCommand(
          title: 'iPhone Upgrade',
          targetAmount: Money(minorUnits: 10000000), // ₹1,00,000
        ),
      );
      final goal = createRes.valueOrNull!;

      // Add ₹1,00,000
      final addRes = await addGoalMoneyUseCase(
        AddGoalMoneyCommand(
          goalId: goal.id,
          amount: const Money(minorUnits: 10000000),
        ),
      );

      expect(addRes.isSuccess, isTrue);
      final updated = addRes.valueOrNull!;
      expect(updated.savedAmount.minorUnits, equals(10000000));
      expect(updated.progressPercentage, equals(1.0));
      expect(updated.remainingAmount.minorUnits, equals(0));
      expect(updated.isAchieved, isTrue);
      expect(updated.status, equals(GoalStatus.completed));
      expect(updated.isCompleted, isTrue);
    });

    test('Remove / withdraw money decreases saved amount', () async {
      final createRes = await createGoalUseCase(
        const CreateGoalCommand(
          title: 'Travel Fund',
          targetAmount: Money(minorUnits: 5000000), // ₹50,000
        ),
      );
      final goal = createRes.valueOrNull!;

      await addGoalMoneyUseCase(
        AddGoalMoneyCommand(goalId: goal.id, amount: const Money(minorUnits: 3000000)),
      );

      // Withdraw ₹10,000
      final withdrawRes = await removeGoalMoneyUseCase(
        RemoveGoalMoneyCommand(
          goalId: goal.id,
          amount: const Money(minorUnits: 1000000),
          note: 'Flight booking',
        ),
      );

      expect(withdrawRes.isSuccess, isTrue);
      final afterWithdraw = withdrawRes.valueOrNull!;
      expect(afterWithdraw.savedAmount.minorUnits, equals(2000000));
      expect(afterWithdraw.remainingAmount.minorUnits, equals(3000000));
    });

    test('Rejects withdrawal exceeding saved balance (prevents negative balance)', () async {
      final createRes = await createGoalUseCase(
        const CreateGoalCommand(
          title: 'Emergency Fund',
          targetAmount: Money(minorUnits: 5000000),
        ),
      );
      final goal = createRes.valueOrNull!;

      await addGoalMoneyUseCase(
        AddGoalMoneyCommand(goalId: goal.id, amount: const Money(minorUnits: 1000000)), // Saved ₹10,000
      );

      // Attempt withdrawing ₹15,000
      final withdrawRes = await removeGoalMoneyUseCase(
        RemoveGoalMoneyCommand(
          goalId: goal.id,
          amount: const Money(minorUnits: 1500000),
        ),
      );

      expect(withdrawRes.isFailure, isTrue);
      expect(withdrawRes.failureOrNull, isA<ValidationFailure>());
    });

    test('Archives goal successfully', () async {
      final createRes = await createGoalUseCase(
        const CreateGoalCommand(
          title: 'Old Goal',
          targetAmount: Money(minorUnits: 1000000),
        ),
      );
      final goal = createRes.valueOrNull!;

      final archiveRes = await archiveGoalUseCase(goal.id);
      expect(archiveRes.isSuccess, isTrue);

      final activeGoals = await getGoalsUseCase(includeArchived: false);
      expect(activeGoals.valueOrNull!.isEmpty, isTrue);

      final allGoals = await getGoalsUseCase(includeArchived: true);
      expect(allGoals.valueOrNull!.length, equals(1));
      expect(allGoals.valueOrNull!.first.status, equals(GoalStatus.archived));
    });
  });
}
