import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';
import '../commands/transaction_commands.dart';
import '../state/action_state.dart';
import '../state/error_mapper.dart';
import '../usecases/transaction_usecases.dart';

/// Presentation-safe controller managing transaction mutations.
class TransactionController extends StateNotifier<ActionState<Transaction>> {
  final CreateExpenseUseCase _createExpenseUseCase;
  final CreateIncomeUseCase _createIncomeUseCase;
  final CreateTransferUseCase _createTransferUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;

  TransactionController({
    required CreateExpenseUseCase createExpenseUseCase,
    required CreateIncomeUseCase createIncomeUseCase,
    required CreateTransferUseCase createTransferUseCase,
    required UpdateTransactionUseCase updateTransactionUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
  })  : _createExpenseUseCase = createExpenseUseCase,
        _createIncomeUseCase = createIncomeUseCase,
        _createTransferUseCase = createTransferUseCase,
        _updateTransactionUseCase = updateTransactionUseCase,
        _deleteTransactionUseCase = deleteTransactionUseCase,
        super(const ActionState.idle());

  void reset() => state = const ActionState.idle();

  Future<bool> createExpense(CreateExpenseCommand command) async {
    state = const ActionState.loading();
    final result = await _createExpenseUseCase(command);
    return result.fold(
      (tx) {
        state = ActionState.success(tx);
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }

  Future<bool> createIncome(CreateIncomeCommand command) async {
    state = const ActionState.loading();
    final result = await _createIncomeUseCase(command);
    return result.fold(
      (tx) {
        state = ActionState.success(tx);
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }

  Future<bool> createTransfer(CreateTransferCommand command) async {
    state = const ActionState.loading();
    final result = await _createTransferUseCase(command);
    return result.fold(
      (tx) {
        state = ActionState.success(tx);
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }

  Future<bool> updateTransaction(UpdateTransactionCommand command) async {
    state = const ActionState.loading();
    final result = await _updateTransactionUseCase(command);
    return result.fold(
      (tx) {
        state = ActionState.success(tx);
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }

  Future<bool> deleteTransaction(String id) async {
    state = const ActionState.loading();
    final result = await _deleteTransactionUseCase(id);
    return result.fold(
      (_) {
        state = const ActionState.idle();
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }
}
