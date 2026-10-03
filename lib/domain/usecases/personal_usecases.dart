import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../entities/analytics_summary.dart';
import '../entities/money.dart';
import '../entities/transaction.dart';
import '../enums/personal_enums.dart';
import '../repositories/transaction_repository.dart';

class CreateExpenseUseCase {
  final TransactionRepository repository;
  const CreateExpenseUseCase(this.repository);

  Future<Result<Transaction>> call({
    required Money amount,
    required String categoryId,
    required String categoryName,
    required String accountId,
    required String accountName,
    required String remark,
    required PaymentMethod paymentMethod,
    required DateTime date,
    String? merchantId,
    String? merchantName,
  }) async {
    if (amount.minorUnits <= 0) {
      return Result.failure(const ValidationFailure('Expense amount must be greater than zero.'));
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: TransactionType.expense,
      categoryId: categoryId,
      categoryName: categoryName,
      accountId: accountId,
      accountName: accountName,
      remark: remark.trim().isEmpty ? categoryName : remark.trim(),
      paymentMethod: paymentMethod,
      date: date,
      merchantId: merchantId,
      merchantName: merchantName,
      createdAt: DateTime.now(),
    );

    return repository.createTransaction(transaction);
  }
}

class CreateIncomeUseCase {
  final TransactionRepository repository;
  const CreateIncomeUseCase(this.repository);

  Future<Result<Transaction>> call({
    required Money amount,
    required String categoryId,
    required String categoryName,
    required String accountId,
    required String accountName,
    required String remark,
    required PaymentMethod paymentMethod,
    required DateTime date,
  }) async {
    if (amount.minorUnits <= 0) {
      return Result.failure(const ValidationFailure('Income amount must be greater than zero.'));
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: TransactionType.income,
      categoryId: categoryId,
      categoryName: categoryName,
      accountId: accountId,
      accountName: accountName,
      remark: remark.trim().isEmpty ? 'Income' : remark.trim(),
      paymentMethod: paymentMethod,
      date: date,
      createdAt: DateTime.now(),
    );

    return repository.createTransaction(transaction);
  }
}

class CreateTransferUseCase {
  final TransactionRepository repository;
  const CreateTransferUseCase(this.repository);

  Future<Result<Transaction>> call({
    required Money amount,
    required String sourceAccountId,
    required String sourceAccountName,
    required String targetAccountId,
    required String targetAccountName,
    required String remark,
    required DateTime date,
  }) async {
    if (amount.minorUnits <= 0) {
      return Result.failure(const ValidationFailure('Transfer amount must be greater than zero.'));
    }
    if (sourceAccountId == targetAccountId) {
      return Result.failure(const ValidationFailure('Source and target accounts must be different.'));
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: TransactionType.transfer,
      categoryId: 'cat_transfer',
      categoryName: 'Transfer',
      accountId: sourceAccountId,
      accountName: sourceAccountName,
      targetAccountId: targetAccountId,
      targetAccountName: targetAccountName,
      remark: remark.trim().isEmpty ? 'Transfer to $targetAccountName' : remark.trim(),
      paymentMethod: PaymentMethod.bankTransfer,
      date: date,
      createdAt: DateTime.now(),
    );

    return repository.createTransaction(transaction);
  }
}

class DeleteTransactionUseCase {
  final TransactionRepository repository;
  const DeleteTransactionUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    return repository.deleteTransaction(id);
  }
}

class GetAnalyticsUseCase {
  final TransactionRepository repository;
  const GetAnalyticsUseCase(this.repository);

  Future<Result<AnalyticsSummary>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = await repository.getTransactions(startDate: startDate, endDate: endDate);
    return result.fold(
      (transactions) {
        int incomeSum = 0;
        int expenseSum = 0;
        final categoryMap = <String, ({String name, int total})>{};

        for (final t in transactions) {
          if (t.isIncome) {
            incomeSum += t.amount.minorUnits;
          } else if (t.isExpense) {
            expenseSum += t.amount.minorUnits;
            final existing = categoryMap[t.categoryId];
            categoryMap[t.categoryId] = (
              name: t.categoryName,
              total: (existing?.total ?? 0) + t.amount.minorUnits,
            );
          }
        }

        final categoryBreakdown = categoryMap.entries.map((e) {
          final pct = expenseSum <= 0 ? 0.0 : (e.value.total / expenseSum) * 100.0;
          return CategorySpending(
            categoryId: e.key,
            categoryName: e.value.name,
            totalAmount: Money(minorUnits: e.value.total),
            percentage: pct,
            colorHex: '#F97316',
          );
        }).toList()
          ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

        return Result.success(AnalyticsSummary(
          totalIncome: Money(minorUnits: incomeSum),
          totalExpense: Money(minorUnits: expenseSum),
          netCashFlow: Money(minorUnits: incomeSum - expenseSum),
          categoryBreakdown: categoryBreakdown,
          dailyCashFlows: const [],
          topCategories: categoryBreakdown.take(5).toList(),
        ));
      },
      (failure) => Result.failure(failure),
    );
  }
}
