import '../../core/result/result.dart';
import '../entities/money.dart';
import '../entities/transaction.dart';
import '../enums/personal_enums.dart';

/// Repository interface for financial transactions.
/// Pure Dart contract completely decoupled from persistence details.
abstract interface class TransactionRepository {
  Future<Result<Transaction>> createTransaction(Transaction transaction);
  Future<Result<Transaction>> updateTransaction(Transaction transaction);
  Future<Result<void>> deleteTransaction(String id);
  Future<Result<Transaction?>> getTransactionById(String id);
  Future<Result<List<Transaction>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
    TransactionType? type,
    String? searchQuery,
  });
  Stream<List<Transaction>> watchTransactions({
    String? accountId,
    TransactionType? type,
  });

  /// Derive current account balance strictly from transactions history.
  Future<Result<Money>> calculateAccountBalance(String accountId);

  /// Derive income and expense totals for a given date range.
  /// Transfers MUST be excluded from income and expense calculations.
  Future<Result<({Money income, Money expense})>> calculateIncomeAndExpense({
    required DateTime startDate,
    required DateTime endDate,
    String? accountId,
  });
}
