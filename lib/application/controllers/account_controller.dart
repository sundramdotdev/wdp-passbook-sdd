import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../commands/account_commands.dart';
import '../state/action_state.dart';
import '../state/error_mapper.dart';
import '../usecases/account_usecases.dart';

/// Presentation-safe controller managing account lifecycle.
class AccountController extends StateNotifier<ActionState<Account>> {
  final CreateAccountUseCase _createAccountUseCase;
  final UpdateAccountUseCase _updateAccountUseCase;
  final ArchiveAccountUseCase _archiveAccountUseCase;
  final RestoreAccountUseCase _restoreAccountUseCase;

  AccountController({
    required CreateAccountUseCase createAccountUseCase,
    required UpdateAccountUseCase updateAccountUseCase,
    required ArchiveAccountUseCase archiveAccountUseCase,
    required RestoreAccountUseCase restoreAccountUseCase,
  })  : _createAccountUseCase = createAccountUseCase,
        _updateAccountUseCase = updateAccountUseCase,
        _archiveAccountUseCase = archiveAccountUseCase,
        _restoreAccountUseCase = restoreAccountUseCase,
        super(const ActionState.idle());

  void reset() => state = const ActionState.idle();

  Future<bool> createAccount(CreateAccountCommand command) async {
    state = const ActionState.loading();
    final result = await _createAccountUseCase(command);
    return result.fold(
      (account) {
        state = ActionState.success(account);
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }

  Future<bool> updateAccount(UpdateAccountCommand command) async {
    state = const ActionState.loading();
    final result = await _updateAccountUseCase(command);
    return result.fold(
      (account) {
        state = ActionState.success(account);
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }

  Future<bool> archiveAccount(String id) async {
    state = const ActionState.loading();
    final result = await _archiveAccountUseCase(id);
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

  Future<bool> restoreAccount(String id) async {
    state = const ActionState.loading();
    final result = await _restoreAccountUseCase(id);
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
