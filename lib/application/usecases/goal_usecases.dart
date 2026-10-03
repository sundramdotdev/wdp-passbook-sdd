import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/enums/personal_enums.dart';
import '../../domain/repositories/personal_repositories.dart';
import '../commands/goal_commands.dart';

/// Orchestrates validated creation of a savings goal.
class CreateGoalUseCase {
  final GoalRepository repository;

  const CreateGoalUseCase(this.repository);

  Future<Result<SavingsGoal>> call(CreateGoalCommand command) async {
    final title = command.title.trim();
    if (title.isEmpty) {
      return Result.failure(const ValidationFailure('Goal name cannot be empty.'));
    }

    if (command.targetAmount.minorUnits <= 0) {
      return Result.failure(const ValidationFailure('Target amount must be strictly greater than zero.'));
    }

    final goal = SavingsGoal(
      id: const Uuid().v4(),
      title: title,
      targetAmount: command.targetAmount,
      savedAmount: Money.zero(command.targetAmount.currencyCode),
      targetDate: command.targetDate,
      status: GoalStatus.active,
      iconName: command.iconName.isEmpty ? 'piggyBank' : command.iconName,
      description: command.description.trim(),
      createdAt: DateTime.now(),
    );

    return repository.createGoal(goal);
  }
}

/// Orchestrates depositing money into an existing goal.
class AddGoalMoneyUseCase {
  final GoalRepository repository;

  const AddGoalMoneyUseCase(this.repository);

  Future<Result<SavingsGoal>> call(AddGoalMoneyCommand command) async {
    if (command.amount.minorUnits <= 0) {
      return Result.failure(const ValidationFailure('Deposit amount must be strictly greater than zero.'));
    }

    final goalRes = await repository.getGoalById(command.goalId);
    if (goalRes.isFailure) return Result.failure(goalRes.failureOrNull!);
    final goal = goalRes.valueOrNull;
    if (goal == null) {
      return Result.failure(NotFoundFailure('Goal with ID ${command.goalId} not found.'));
    }

    if (command.amount.currencyCode != goal.targetAmount.currencyCode) {
      return Result.failure(CurrencyMismatchFailure(
        'Currency ${command.amount.currencyCode} does not match goal currency ${goal.targetAmount.currencyCode}.',
      ));
    }

    final newSaved = goal.savedAmount + command.amount;
    final isNowCompleted = newSaved.minorUnits >= goal.targetAmount.minorUnits;

    final updated = goal.copyWith(
      savedAmount: newSaved,
      status: isNowCompleted ? GoalStatus.completed : goal.status,
      updatedAt: DateTime.now(),
    );

    return repository.updateGoal(updated);
  }
}

/// Orchestrates withdrawing money from an existing goal.
class RemoveGoalMoneyUseCase {
  final GoalRepository repository;

  const RemoveGoalMoneyUseCase(this.repository);

  Future<Result<SavingsGoal>> call(RemoveGoalMoneyCommand command) async {
    if (command.amount.minorUnits <= 0) {
      return Result.failure(const ValidationFailure('Withdrawal amount must be strictly greater than zero.'));
    }

    final goalRes = await repository.getGoalById(command.goalId);
    if (goalRes.isFailure) return Result.failure(goalRes.failureOrNull!);
    final goal = goalRes.valueOrNull;
    if (goal == null) {
      return Result.failure(NotFoundFailure('Goal with ID ${command.goalId} not found.'));
    }

    if (command.amount.currencyCode != goal.targetAmount.currencyCode) {
      return Result.failure(CurrencyMismatchFailure(
        'Currency ${command.amount.currencyCode} does not match goal currency ${goal.targetAmount.currencyCode}.',
      ));
    }

    if (goal.savedAmount.minorUnits < command.amount.minorUnits) {
      return Result.failure(const ValidationFailure('Cannot withdraw more than current saved amount.'));
    }

    final newSaved = goal.savedAmount - command.amount;
    final isStillCompleted = newSaved.minorUnits >= goal.targetAmount.minorUnits;

    final updated = goal.copyWith(
      savedAmount: newSaved,
      status: isStillCompleted ? goal.status : GoalStatus.active,
      updatedAt: DateTime.now(),
    );

    return repository.updateGoal(updated);
  }
}

/// Archives a savings goal.
class ArchiveGoalUseCase {
  final GoalRepository repository;

  const ArchiveGoalUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Goal ID cannot be empty.'));
    }
    return repository.archiveGoal(id);
  }
}

/// Retrieves goals.
class GetGoalsUseCase {
  final GoalRepository repository;

  const GetGoalsUseCase(this.repository);

  Future<Result<List<SavingsGoal>>> call({bool includeArchived = false}) {
    return repository.getGoals(includeArchived: includeArchived);
  }
}
