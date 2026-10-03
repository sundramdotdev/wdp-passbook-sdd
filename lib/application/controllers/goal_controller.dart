import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal.dart';
import '../commands/goal_commands.dart';
import '../state/action_state.dart';
import '../state/error_mapper.dart';
import '../usecases/goal_usecases.dart';

/// Presentation-safe controller managing savings goals.
class GoalController extends StateNotifier<ActionState<SavingsGoal>> {
  final CreateGoalUseCase _createGoalUseCase;
  final AddGoalMoneyUseCase _addGoalMoneyUseCase;
  final RemoveGoalMoneyUseCase _removeGoalMoneyUseCase;
  final ArchiveGoalUseCase _archiveGoalUseCase;

  GoalController({
    required CreateGoalUseCase createGoalUseCase,
    required AddGoalMoneyUseCase addGoalMoneyUseCase,
    required RemoveGoalMoneyUseCase removeGoalMoneyUseCase,
    required ArchiveGoalUseCase archiveGoalUseCase,
  })  : _createGoalUseCase = createGoalUseCase,
        _addGoalMoneyUseCase = addGoalMoneyUseCase,
        _removeGoalMoneyUseCase = removeGoalMoneyUseCase,
        _archiveGoalUseCase = archiveGoalUseCase,
        super(const ActionState.idle());

  void reset() => state = const ActionState.idle();

  Future<bool> createGoal(CreateGoalCommand command) async {
    state = const ActionState.loading();
    final result = await _createGoalUseCase(command);
    return result.fold(
      (goal) {
        state = ActionState.success(goal);
        return true;
      },
      (failure) {
        final msg = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(msg, failure: failure);
        return false;
      },
    );
  }

  Future<bool> addMoney(AddGoalMoneyCommand command) async {
    state = const ActionState.loading();
    final result = await _addGoalMoneyUseCase(command);
    return result.fold(
      (goal) {
        state = ActionState.success(goal);
        return true;
      },
      (failure) {
        final msg = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(msg, failure: failure);
        return false;
      },
    );
  }

  Future<bool> removeMoney(RemoveGoalMoneyCommand command) async {
    state = const ActionState.loading();
    final result = await _removeGoalMoneyUseCase(command);
    return result.fold(
      (goal) {
        state = ActionState.success(goal);
        return true;
      },
      (failure) {
        final msg = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(msg, failure: failure);
        return false;
      },
    );
  }

  Future<bool> archiveGoal(String id) async {
    state = const ActionState.loading();
    final result = await _archiveGoalUseCase(id);
    return result.fold(
      (_) {
        state = const ActionState.idle();
        return true;
      },
      (failure) {
        final msg = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(msg, failure: failure);
        return false;
      },
    );
  }
}
