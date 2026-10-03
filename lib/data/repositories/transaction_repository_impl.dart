import 'package:isar/isar.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/enums/personal_enums.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/isar_transaction_datasource.dart';
import '../local/isar/isar_account.dart';
import '../local/isar/isar_transaction.dart';
import '../mappers/transaction_mapper.dart';
import '../services/isar_service.dart';

class IsarTransactionRepository implements TransactionRepository {
  final IsarService isarService;
  late final IsarTransactionDataSource _dataSource;

  IsarTransactionRepository(this.isarService, [IsarTransactionDataSource? dataSource]) {
    _dataSource = dataSource ?? IsarTransactionDataSource(isarService.db);
  }

  @override
  Future<Result<Transaction>> createTransaction(Transaction transaction) async {
    try {
      // 1. Validate domain invariants
      final validatedTx = Transaction.validated(
        id: transaction.id,
        amount: transaction.amount,
        type: transaction.type,
        categoryId: transaction.categoryId,
        categoryName: transaction.categoryName,
        accountId: transaction.accountId,
        accountName: transaction.accountName,
        targetAccountId: transaction.targetAccountId,
        targetAccountName: transaction.targetAccountName,
        remark: transaction.remark,
        paymentMethod: transaction.paymentMethod,
        date: transaction.date,
        merchantId: transaction.merchantId,
        merchantName: transaction.merchantName,
        isUpiVerified: transaction.isUpiVerified,
        upiTxnId: transaction.upiTxnId,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
      );

      final isar = await isarService.db;
      late IsarTransaction createdIsar;

      // 2. Atomic write transaction
      await isar.writeTxn(() async {
        final isarTxn = TransactionMapper.toIsar(validatedTx);
        await isar.isarTransactions.put(isarTxn);
        createdIsar = isarTxn;

        // Synchronize source account cached balance atomically
        final account = await isar.isarAccounts
            .filter()
            .uuidEqualTo(validatedTx.accountId)
            .findFirst();
        if (account != null) {
          if (validatedTx.type == TransactionType.expense ||
              validatedTx.type == TransactionType.transfer) {
            account.balanceMinorUnits -= validatedTx.amount.minorUnits;
          } else if (validatedTx.type == TransactionType.income) {
            account.balanceMinorUnits += validatedTx.amount.minorUnits;
          }
          account.updatedAt = DateTime.now();
          await isar.isarAccounts.put(account);
        }

        // Synchronize target destination account in transfers atomically
        if (validatedTx.type == TransactionType.transfer &&
            validatedTx.targetAccountId != null) {
          final targetAccount = await isar.isarAccounts
              .filter()
              .uuidEqualTo(validatedTx.targetAccountId!)
              .findFirst();
          if (targetAccount != null) {
            targetAccount.balanceMinorUnits += validatedTx.amount.minorUnits;
            targetAccount.updatedAt = DateTime.now();
            await isar.isarAccounts.put(targetAccount);
          }
        }
      });

      return Result.success(TransactionMapper.toDomain(createdIsar));
    } on InvalidTransactionException catch (e) {
      return Result.failure(InvalidTransactionFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create transaction: $e'));
    }
  }

  @override
  Future<Result<Transaction>> updateTransaction(Transaction transaction) async {
    try {
      final isar = await isarService.db;
      final existing = await isar.isarTransactions
          .filter()
          .uuidEqualTo(transaction.id)
          .findFirst();

      if (existing == null) {
        return Result.failure(NotFoundFailure('Transaction with ID "${transaction.id}" not found'));
      }

      await isar.writeTxn(() async {
        final updatedIsar = TransactionMapper.toIsar(transaction, existing);
        await isar.isarTransactions.put(updatedIsar);
      });

      return Result.success(transaction);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update transaction: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    try {
      final isar = await isarService.db;
      final existing = await isar.isarTransactions
          .filter()
          .uuidEqualTo(id)
          .findFirst();

      if (existing == null) {
        return Result.failure(NotFoundFailure('Transaction with ID "$id" not found'));
      }

      await isar.writeTxn(() async {
        // Reverse account balance adjustment atomically
        final account = await isar.isarAccounts
            .filter()
            .uuidEqualTo(existing.accountId)
            .findFirst();
        if (account != null) {
          if (existing.type == 'expense' || existing.type == 'transfer') {
            account.balanceMinorUnits += existing.minorUnits;
          } else if (existing.type == 'income') {
            account.balanceMinorUnits -= existing.minorUnits;
          }
          account.updatedAt = DateTime.now();
          await isar.isarAccounts.put(account);
        }

        if (existing.type == 'transfer' && existing.targetAccountId != null) {
          final targetAccount = await isar.isarAccounts
              .filter()
              .uuidEqualTo(existing.targetAccountId!)
              .findFirst();
          if (targetAccount != null) {
            targetAccount.balanceMinorUnits -= existing.minorUnits;
            targetAccount.updatedAt = DateTime.now();
            await isar.isarAccounts.put(targetAccount);
          }
        }

        await isar.isarTransactions.delete(existing.id);
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete transaction: $e'));
    }
  }

  @override
  Future<Result<Transaction?>> getTransactionById(String id) async {
    try {
      final isarTx = await _dataSource.getById(id);
      if (isarTx == null) {
        return Result.success(null);
      }
      return Result.success(TransactionMapper.toDomain(isarTx));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to retrieve transaction: $e'));
    }
  }

  @override
  Future<Result<List<Transaction>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
    TransactionType? type,
    String? searchQuery,
  }) async {
    try {
      final isarList = await _dataSource.query(
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        accountId: accountId,
        type: type?.name,
        searchQuery: searchQuery,
      );

      final domainList = isarList.map(TransactionMapper.toDomain).toList();
      return Result.success(domainList);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch transactions: $e'));
    }
  }

  @override
  Stream<List<Transaction>> watchTransactions({
    String? accountId,
    TransactionType? type,
  }) async* {
    yield* _dataSource
        .watchAll(accountId: accountId, type: type?.name)
        .map((list) => list.map(TransactionMapper.toDomain).toList());
  }

  @override
  Future<Result<Money>> calculateAccountBalance(String accountId) async {
    try {
      final balanceMinor = await _dataSource.calculateAccountBalanceMinor(accountId);
      return Result.success(Money.fromMinor(balanceMinor));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to calculate balance: $e'));
    }
  }

  @override
  Future<Result<({Money income, Money expense})>> calculateIncomeAndExpense({
    required DateTime startDate,
    required DateTime endDate,
    String? accountId,
  }) async {
    try {
      final res = await _dataSource.calculateIncomeAndExpense(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
      );
      return Result.success((
        income: Money.fromMinor(res.incomeMinor),
        expense: Money.fromMinor(res.expenseMinor),
      ));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to calculate income/expense: $e'));
    }
  }
}
