import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/enums/personal_enums.dart';
import '../../domain/repositories/personal_repositories.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../commands/transaction_commands.dart';
import '../commands/transaction_filter.dart';

/// Orchestrates creation of a validated Expense transaction.
class CreateExpenseUseCase {
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;

  const CreateExpenseUseCase({
    required this.transactionRepository,
    required this.accountRepository,
    required this.categoryRepository,
  });

  Future<Result<Transaction>> call(CreateExpenseCommand command) async {
    // 1. Validate Amount
    if (command.amount.minorUnits <= 0) {
      return Result.failure(const InvalidMoneyFailure('Expense amount must be strictly greater than zero.'));
    }

    // 2. Validate Account
    final accountResult = await accountRepository.getAccountById(command.accountId);
    if (accountResult.isFailure) {
      return Result.failure(accountResult.failureOrNull!);
    }
    final account = accountResult.valueOrNull;
    if (account == null) {
      return Result.failure(NotFoundFailure('Account with ID ${command.accountId} not found.'));
    }
    if (account.isArchived) {
      return Result.failure(const ValidationFailure('Cannot add expenses to an archived account.'));
    }

    // Currency check
    if (account.currencyCode != command.amount.currencyCode) {
      return Result.failure(CurrencyMismatchFailure(
        'Transaction currency (${command.amount.currencyCode}) does not match account currency (${account.currencyCode}).',
      ));
    }

    // 3. Validate Category
    final categoryResult = await categoryRepository.getCategoryById(command.categoryId);
    if (categoryResult.isFailure) {
      return Result.failure(categoryResult.failureOrNull!);
    }
    final category = categoryResult.valueOrNull;
    if (category == null) {
      return Result.failure(NotFoundFailure('Category with ID ${command.categoryId} not found.'));
    }
    if (category.type != CategoryType.expense) {
      return Result.failure(const ValidationFailure('Selected category is not an Expense category.'));
    }

    // 4. Construct validated domain entity
    try {
      final transaction = Transaction.validated(
        id: const Uuid().v4(),
        amount: command.amount,
        type: TransactionType.expense,
        categoryId: category.id,
        categoryName: category.name,
        accountId: account.id,
        accountName: account.name,
        remark: command.remark.trim().isEmpty ? category.name : command.remark.trim(),
        paymentMethod: command.paymentMethod,
        date: command.date,
        merchantId: command.merchantId,
        merchantName: command.merchantName,
        createdAt: DateTime.now(),
      );

      return await transactionRepository.createTransaction(transaction);
    } catch (e) {
      return Result.failure(InvalidTransactionFailure('Failed to validate expense: $e'));
    }
  }
}

/// Orchestrates creation of a validated Income transaction.
class CreateIncomeUseCase {
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;

  const CreateIncomeUseCase({
    required this.transactionRepository,
    required this.accountRepository,
    required this.categoryRepository,
  });

  Future<Result<Transaction>> call(CreateIncomeCommand command) async {
    // 1. Validate Amount
    if (command.amount.minorUnits <= 0) {
      return Result.failure(const InvalidMoneyFailure('Income amount must be strictly greater than zero.'));
    }

    // 2. Validate Account
    final accountResult = await accountRepository.getAccountById(command.accountId);
    if (accountResult.isFailure) {
      return Result.failure(accountResult.failureOrNull!);
    }
    final account = accountResult.valueOrNull;
    if (account == null) {
      return Result.failure(NotFoundFailure('Account with ID ${command.accountId} not found.'));
    }
    if (account.isArchived) {
      return Result.failure(const ValidationFailure('Cannot add income to an archived account.'));
    }

    // Currency check
    if (account.currencyCode != command.amount.currencyCode) {
      return Result.failure(CurrencyMismatchFailure(
        'Transaction currency (${command.amount.currencyCode}) does not match account currency (${account.currencyCode}).',
      ));
    }

    // 3. Validate Category
    final categoryResult = await categoryRepository.getCategoryById(command.categoryId);
    if (categoryResult.isFailure) {
      return Result.failure(categoryResult.failureOrNull!);
    }
    final category = categoryResult.valueOrNull;
    if (category == null) {
      return Result.failure(NotFoundFailure('Category with ID ${command.categoryId} not found.'));
    }
    if (category.type != CategoryType.income) {
      return Result.failure(const ValidationFailure('Selected category is not an Income category.'));
    }

    // 4. Construct validated domain entity
    try {
      final transaction = Transaction.validated(
        id: const Uuid().v4(),
        amount: command.amount,
        type: TransactionType.income,
        categoryId: category.id,
        categoryName: category.name,
        accountId: account.id,
        accountName: account.name,
        remark: command.remark.trim().isEmpty ? 'Income' : command.remark.trim(),
        paymentMethod: command.paymentMethod,
        date: command.date,
        createdAt: DateTime.now(),
      );

      return await transactionRepository.createTransaction(transaction);
    } catch (e) {
      return Result.failure(InvalidTransactionFailure('Failed to validate income: $e'));
    }
  }
}

/// Orchestrates fund transfer between two distinct accounts.
class CreateTransferUseCase {
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  const CreateTransferUseCase({
    required this.transactionRepository,
    required this.accountRepository,
  });

  Future<Result<Transaction>> call(CreateTransferCommand command) async {
    // 1. Validate Amount
    if (command.amount.minorUnits <= 0) {
      return Result.failure(const InvalidMoneyFailure('Transfer amount must be strictly greater than zero.'));
    }

    // 2. Validate Source != Target
    if (command.sourceAccountId == command.targetAccountId) {
      return Result.failure(const ValidationFailure('Source and destination accounts must be different.'));
    }

    // 3. Validate Source Account
    final sourceResult = await accountRepository.getAccountById(command.sourceAccountId);
    if (sourceResult.isFailure) return Result.failure(sourceResult.failureOrNull!);
    final sourceAccount = sourceResult.valueOrNull;
    if (sourceAccount == null) {
      return Result.failure(NotFoundFailure('Source account with ID ${command.sourceAccountId} not found.'));
    }
    if (sourceAccount.isArchived) {
      return Result.failure(const ValidationFailure('Cannot transfer from an archived account.'));
    }

    // 4. Validate Target Account
    final targetResult = await accountRepository.getAccountById(command.targetAccountId);
    if (targetResult.isFailure) return Result.failure(targetResult.failureOrNull!);
    final targetAccount = targetResult.valueOrNull;
    if (targetAccount == null) {
      return Result.failure(NotFoundFailure('Target account with ID ${command.targetAccountId} not found.'));
    }
    if (targetAccount.isArchived) {
      return Result.failure(const ValidationFailure('Cannot transfer to an archived account.'));
    }

    // 5. Currency Check
    if (sourceAccount.currencyCode != targetAccount.currencyCode) {
      return Result.failure(CurrencyMismatchFailure(
        'Cross-currency transfers are not supported. Source: ${sourceAccount.currencyCode}, Target: ${targetAccount.currencyCode}',
      ));
    }
    if (command.amount.currencyCode != sourceAccount.currencyCode) {
      return Result.failure(CurrencyMismatchFailure(
        'Transfer currency (${command.amount.currencyCode}) must match account currency (${sourceAccount.currencyCode}).',
      ));
    }

    // 6. Construct validated domain entity
    try {
      final transaction = Transaction.validated(
        id: const Uuid().v4(),
        amount: command.amount,
        type: TransactionType.transfer,
        accountId: sourceAccount.id,
        accountName: sourceAccount.name,
        targetAccountId: targetAccount.id,
        targetAccountName: targetAccount.name,
        remark: command.remark.trim().isEmpty
            ? 'Transfer to ${targetAccount.name}'
            : command.remark.trim(),
        paymentMethod: PaymentMethod.bankTransfer,
        date: command.date,
        createdAt: DateTime.now(),
      );

      return await transactionRepository.createTransaction(transaction);
    } catch (e) {
      return Result.failure(InvalidTransactionFailure('Failed to validate transfer: $e'));
    }
  }
}

/// Orchestrates updating an existing transaction while maintaining financial invariants.
class UpdateTransactionUseCase {
  final TransactionRepository repository;

  const UpdateTransactionUseCase(this.repository);

  Future<Result<Transaction>> call(UpdateTransactionCommand command) async {
    final existingRes = await repository.getTransactionById(command.id);
    if (existingRes.isFailure) return Result.failure(existingRes.failureOrNull!);
    final existing = existingRes.valueOrNull;
    if (existing == null) {
      return Result.failure(NotFoundFailure('Transaction with ID ${command.id} not found.'));
    }

    try {
      final updated = Transaction.validated(
        id: existing.id,
        amount: command.amount,
        type: command.type,
        categoryId: command.categoryId ?? existing.categoryId,
        categoryName: existing.categoryName,
        accountId: command.accountId,
        accountName: existing.accountName,
        targetAccountId: command.targetAccountId ?? existing.targetAccountId,
        targetAccountName: existing.targetAccountName,
        remark: command.remark,
        paymentMethod: command.paymentMethod,
        date: command.date,
        merchantId: command.merchantId ?? existing.merchantId,
        merchantName: command.merchantName ?? existing.merchantName,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      return await repository.updateTransaction(updated);
    } catch (e) {
      return Result.failure(InvalidTransactionFailure('Invalid transaction update parameters: $e'));
    }
  }
}

/// Orchestrates deletion/reversal of a transaction.
class DeleteTransactionUseCase {
  final TransactionRepository repository;

  const DeleteTransactionUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Transaction ID cannot be empty.'));
    }
    return repository.deleteTransaction(id);
  }
}

/// Retrieves a single transaction by ID.
class GetTransactionUseCase {
  final TransactionRepository repository;

  const GetTransactionUseCase(this.repository);

  Future<Result<Transaction>> call(String id) async {
    final res = await repository.getTransactionById(id);
    return res.fold(
      (tx) {
        if (tx == null) {
          return Result.failure(NotFoundFailure('Transaction with ID $id not found.'));
        }
        return Result.success(tx);
      },
      (failure) => Result.failure(failure),
    );
  }
}

/// Retrieves transactions filtered by typed criteria.
class GetTransactionsUseCase {
  final TransactionRepository repository;

  const GetTransactionsUseCase(this.repository);

  Future<Result<List<Transaction>>> call({TransactionFilter? filter}) async {
    final res = await repository.getTransactions(
      startDate: filter?.startDate,
      endDate: filter?.endDate,
      categoryId: filter?.categoryId,
      accountId: filter?.accountId,
      type: filter?.type,
      searchQuery: filter?.searchQuery,
    );

    return res.fold(
      (list) {
        var resultList = list;
        if (filter?.minAmount != null) {
          resultList = resultList.where((t) => t.amount >= filter!.minAmount!).toList();
        }
        if (filter?.maxAmount != null) {
          resultList = resultList.where((t) => t.amount <= filter!.maxAmount!).toList();
        }
        return Result.success(resultList);
      },
      (failure) => Result.failure(failure),
    );
  }
}

/// Searches transactions across description, remark, and identifiers.
class SearchTransactionsUseCase {
  final TransactionRepository repository;

  const SearchTransactionsUseCase(this.repository);

  Future<Result<List<Transaction>>> call(String query) async {
    if (query.trim().isEmpty) {
      return repository.getTransactions();
    }
    return repository.getTransactions(searchQuery: query.trim());
  }
}
