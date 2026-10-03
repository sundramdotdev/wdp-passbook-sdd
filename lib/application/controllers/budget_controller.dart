import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget.dart';
import '../commands/budget_commands.dart';
import '../state/action_state.dart';
import '../state/error_mapper.dart';
import '../usecases/budget_usecases.dart';

/// Presentation-safe controller managing budget operations.
class BudgetController extends StateNotifier<ActionState<Budget>> {
  final CreateBudgetUseCase _createBudgetUseCase;
  final DeleteBudgetUseCase _deleteBudgetUseCase;

  BudgetController({
    required CreateBudgetUseCase createBudgetUseCase,
    required DeleteBudgetUseCase deleteBudgetUseCase,
  })  : _createBudgetUseCase = createBudgetUseCase,
        _deleteBudgetUseCase = deleteBudgetUseCase,
        super(const ActionState.idle());

  void reset() => state = const ActionState.idle();

  Future<bool> createBudget(CreateBudgetCommand command) async {
    state = const ActionState.loading();
    final result = await _createBudgetUseCase(command);
    return result.fold(
      (budget) {
        state = ActionState.success(budget);
        return true;
      },
      (failure) {
        final msg = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(msg, failure: failure);
        return false;
      },
    );
  }

  Future<bool> deleteBudget(String id) async {
    state = const ActionState.loading();
    final result = await _deleteBudgetUseCase(id);
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
