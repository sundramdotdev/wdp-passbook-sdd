import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/personal_repositories.dart';
import '../commands/account_commands.dart';

/// Orchestrates creation of a financial account.
class CreateAccountUseCase {
  final AccountRepository repository;

  const CreateAccountUseCase(this.repository);

  Future<Result<Account>> call(CreateAccountCommand command) async {
    if (command.name.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Account name cannot be empty.'));
    }
    if (command.initialBalance.minorUnits < 0) {
      return Result.failure(const ValidationFailure('Initial balance cannot be negative.'));
    }

    final account = Account(
      id: const Uuid().v4(),
      name: command.name.trim(),
      type: command.type,
      currencyCode: command.currencyCode,
      balance: command.initialBalance,
      iconName: command.iconName,
      colorHex: command.colorHex,
      isArchived: false,
      createdAt: DateTime.now(),
    );

    return repository.createAccount(account);
  }
}

/// Orchestrates updating an existing account's metadata.
class UpdateAccountUseCase {
  final AccountRepository repository;

  const UpdateAccountUseCase(this.repository);

  Future<Result<Account>> call(UpdateAccountCommand command) async {
    if (command.id.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Account ID cannot be empty.'));
    }
    if (command.name.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Account name cannot be empty.'));
    }

    final existingRes = await repository.getAccountById(command.id);
    if (existingRes.isFailure) return Result.failure(existingRes.failureOrNull!);
    final existing = existingRes.valueOrNull;
    if (existing == null) {
      return Result.failure(NotFoundFailure('Account with ID ${command.id} not found.'));
    }

    final updated = existing.copyWith(
      name: command.name.trim(),
      type: command.type,
      iconName: command.iconName,
      colorHex: command.colorHex,
      updatedAt: DateTime.now(),
    );

    return repository.updateAccount(updated);
  }
}

/// Archives an account, hiding it from default active views.
class ArchiveAccountUseCase {
  final AccountRepository repository;

  const ArchiveAccountUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Account ID cannot be empty.'));
    }
    return repository.archiveAccount(id);
  }
}

/// Restores an archived account back to active status.
class RestoreAccountUseCase {
  final AccountRepository repository;

  const RestoreAccountUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Account ID cannot be empty.'));
    }
    return repository.restoreAccount(id);
  }
}

/// Retrieves an account by its unique identifier.
class GetAccountUseCase {
  final AccountRepository repository;

  const GetAccountUseCase(this.repository);

  Future<Result<Account>> call(String id) async {
    final res = await repository.getAccountById(id);
    return res.fold(
      (account) {
        if (account == null) {
          return Result.failure(NotFoundFailure('Account with ID $id not found.'));
        }
        return Result.success(account);
      },
      (failure) => Result.failure(failure),
    );
  }
}

/// Retrieves all accounts, optionally including archived ones.
class GetAccountsUseCase {
  final AccountRepository repository;

  const GetAccountsUseCase(this.repository);

  Future<Result<List<Account>>> call({bool includeArchived = false}) {
    return repository.getAccounts(includeArchived: includeArchived);
  }
}
