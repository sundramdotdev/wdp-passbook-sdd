import 'dart:async';
import 'package:wdp_passbook/core/errors/failures.dart';
import 'package:wdp_passbook/core/result/result.dart';
import 'package:wdp_passbook/domain/entities/account.dart';
import 'package:wdp_passbook/domain/entities/budget.dart';
import 'package:wdp_passbook/domain/entities/category.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/entities/savings_goal.dart';
import 'package:wdp_passbook/domain/entities/transaction.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';
import 'package:wdp_passbook/domain/repositories/personal_repositories.dart';
import 'package:wdp_passbook/domain/repositories/transaction_repository.dart';

class FakeTransactionRepository implements TransactionRepository {
  final Map<String, Transaction> transactions = {};
  final StreamController<List<Transaction>> _streamController =
      StreamController<List<Transaction>>.broadcast();

  bool shouldFail = false;

  void emit() {
    final list = transactions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _streamController.add(list);
  }

  @override
  Future<Result<Transaction>> createTransaction(Transaction transaction) async {
    if (shouldFail) {
      return Result.failure(const DatabaseFailure('Simulated database error'));
    }
    transactions[transaction.id] = transaction;
    emit();
    return Result.success(transaction);
  }

  @override
  Future<Result<Transaction>> updateTransaction(Transaction transaction) async {
    if (shouldFail) {
      return Result.failure(const DatabaseFailure('Simulated database error'));
    }
    if (!transactions.containsKey(transaction.id)) {
      return Result.failure(const NotFoundFailure('Transaction not found'));
    }
    transactions[transaction.id] = transaction;
    emit();
    return Result.success(transaction);
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    if (shouldFail) {
      return Result.failure(const DatabaseFailure('Simulated database error'));
    }
    if (!transactions.containsKey(id)) {
      return Result.failure(const NotFoundFailure('Transaction not found'));
    }
    transactions.remove(id);
    emit();
    return Result.success(null);
  }

  @override
  Future<Result<Transaction?>> getTransactionById(String id) async {
    if (shouldFail) {
      return Result.failure(const DatabaseFailure('Simulated database error'));
    }
    return Result.success(transactions[id]);
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
    if (shouldFail) {
      return Result.failure(const DatabaseFailure('Simulated database error'));
    }

    var list = transactions.values.toList();
    if (startDate != null) {
      list = list.where((t) => t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate)).toList();
    }
    if (endDate != null) {
      list = list.where((t) => t.date.isBefore(endDate) || t.date.isAtSameMomentAs(endDate)).toList();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      list = list.where((t) => t.categoryId == categoryId).toList();
    }
    if (accountId != null && accountId.isNotEmpty) {
      list = list.where((t) => t.accountId == accountId || t.targetAccountId == accountId).toList();
    }
    if (type != null) {
      list = list.where((t) => t.type == type).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((t) =>
          t.remark.toLowerCase().contains(q) ||
          t.categoryName.toLowerCase().contains(q) ||
          t.accountName.toLowerCase().contains(q)).toList();
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return Result.success(list);
  }

  @override
  Stream<List<Transaction>> watchTransactions({
    String? accountId,
    TransactionType? type,
  }) async* {
    List<Transaction> applyFilter(List<Transaction> list) {
      var filtered = list;
      if (accountId != null && accountId.isNotEmpty) {
        filtered = filtered.where((t) => t.accountId == accountId || t.targetAccountId == accountId).toList();
      }
      if (type != null) {
        filtered = filtered.where((t) => t.type == type).toList();
      }
      return filtered;
    }

    final current = transactions.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    yield applyFilter(current);
    yield* _streamController.stream.map(applyFilter);
  }

  @override
  Future<Result<Money>> calculateAccountBalance(String accountId) async {
    if (shouldFail) {
      return Result.failure(const DatabaseFailure('Simulated database error'));
    }

    int balance = 0;
    for (final t in transactions.values) {
      if (t.accountId == accountId) {
        if (t.type == TransactionType.income) {
          balance += t.amount.minorUnits;
        } else if (t.type == TransactionType.expense || t.type == TransactionType.transfer) {
          balance -= t.amount.minorUnits;
        }
      } else if (t.targetAccountId == accountId && t.type == TransactionType.transfer) {
        balance += t.amount.minorUnits;
      }
    }
    return Result.success(Money(minorUnits: balance));
  }

  @override
  Future<Result<({Money income, Money expense})>> calculateIncomeAndExpense({
    required DateTime startDate,
    required DateTime endDate,
    String? accountId,
  }) async {
    int income = 0;
    int expense = 0;

    for (final t in transactions.values) {
      if (accountId != null && t.accountId != accountId) continue;
      if (t.date.isBefore(startDate) || t.date.isAfter(endDate)) continue;

      if (t.type == TransactionType.income) {
        income += t.amount.minorUnits;
      } else if (t.type == TransactionType.expense) {
        expense += t.amount.minorUnits;
      }
      // Transfers strictly excluded
    }

    return Result.success((
      income: Money(minorUnits: income),
      expense: Money(minorUnits: expense),
    ));
  }
}

class FakeAccountRepository implements AccountRepository {
  final Map<String, Account> accounts = {};
  final StreamController<List<Account>> _streamController =
      StreamController<List<Account>>.broadcast();

  bool shouldFail = false;

  void emit() {
    _streamController.add(accounts.values.toList());
  }

  @override
  Future<Result<Account>> createAccount(Account account) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    accounts[account.id] = account;
    emit();
    return Result.success(account);
  }

  @override
  Future<Result<Account>> updateAccount(Account account) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    if (!accounts.containsKey(account.id)) {
      return Result.failure(const NotFoundFailure('Account not found'));
    }
    accounts[account.id] = account;
    emit();
    return Result.success(account);
  }

  @override
  Future<Result<Account?>> getAccountById(String id) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    return Result.success(accounts[id]);
  }

  @override
  Future<Result<List<Account>>> getAccounts({bool includeArchived = false}) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    final list = accounts.values.where((a) => includeArchived || !a.isArchived).toList();
    return Result.success(list);
  }

  @override
  Stream<List<Account>> watchAccounts({bool includeArchived = false}) async* {
    List<Account> applyFilter(List<Account> list) {
      return list.where((a) => includeArchived || !a.isArchived).toList();
    }

    yield applyFilter(accounts.values.toList());
    yield* _streamController.stream.map(applyFilter);
  }

  @override
  Future<Result<void>> archiveAccount(String id) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    final acc = accounts[id];
    if (acc == null) return Result.failure(const NotFoundFailure('Account not found'));
    accounts[id] = acc.copyWith(isArchived: true);
    emit();
    return Result.success(null);
  }

  @override
  Future<Result<void>> restoreAccount(String id) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    final acc = accounts[id];
    if (acc == null) return Result.failure(const NotFoundFailure('Account not found'));
    accounts[id] = acc.copyWith(isArchived: false);
    emit();
    return Result.success(null);
  }
}

class FakeCategoryRepository implements CategoryRepository {
  final Map<String, Category> categories = {};
  final StreamController<List<Category>> _streamController =
      StreamController<List<Category>>.broadcast();

  bool shouldFail = false;

  void emit() {
    _streamController.add(categories.values.toList());
  }

  @override
  Future<Result<Category>> createCategory(Category category) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    categories[category.id] = category;
    emit();
    return Result.success(category);
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    if (!categories.containsKey(category.id)) {
      return Result.failure(const NotFoundFailure('Category not found'));
    }
    categories[category.id] = category;
    emit();
    return Result.success(category);
  }

  @override
  Future<Result<Category?>> getCategoryById(String id) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    return Result.success(categories[id]);
  }

  @override
  Future<Result<List<Category>>> getCategories({
    CategoryType? type,
    bool includeArchived = false,
  }) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    var list = categories.values.where((c) => includeArchived || !c.isArchived);
    if (type != null) {
      list = list.where((c) => c.type == type);
    }
    return Result.success(list.toList());
  }

  @override
  Stream<List<Category>> watchCategories({
    CategoryType? type,
    bool includeArchived = false,
  }) async* {
    List<Category> applyFilter(List<Category> list) {
      var filtered = list.where((c) => includeArchived || !c.isArchived);
      if (type != null) {
        filtered = filtered.where((c) => c.type == type);
      }
      return filtered.toList();
    }

    yield applyFilter(categories.values.toList());
    yield* _streamController.stream.map(applyFilter);
  }

  @override
  Future<Result<void>> archiveCategory(String id) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    final cat = categories[id];
    if (cat == null) return Result.failure(const NotFoundFailure('Category not found'));
    categories[id] = cat.copyWith(isArchived: true);
    emit();
    return Result.success(null);
  }
}

class FakeBudgetRepository implements BudgetRepository {
  final Map<String, Budget> budgets = {};
  final StreamController<List<Budget>> _streamController =
      StreamController<List<Budget>>.broadcast();

  bool shouldFail = false;

  void emit() {
    _streamController.add(budgets.values.toList());
  }

  @override
  Future<Result<Budget>> createBudget(Budget budget) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    budgets[budget.id] = budget;
    emit();
    return Result.success(budget);
  }

  @override
  Future<Result<Budget>> updateBudget(Budget budget) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    if (!budgets.containsKey(budget.id)) {
      return Result.failure(const NotFoundFailure('Budget not found'));
    }
    budgets[budget.id] = budget;
    emit();
    return Result.success(budget);
  }

  @override
  Future<Result<void>> deleteBudget(String id) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    budgets.remove(id);
    emit();
    return Result.success(null);
  }

  @override
  Future<Result<List<Budget>>> getBudgets() async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    return Result.success(budgets.values.toList());
  }

  @override
  Stream<List<Budget>> watchBudgets() async* {
    yield budgets.values.toList();
    yield* _streamController.stream;
  }
}

class FakeGoalRepository implements GoalRepository {
  final Map<String, SavingsGoal> goals = {};
  final StreamController<List<SavingsGoal>> _streamController =
      StreamController<List<SavingsGoal>>.broadcast();

  bool shouldFail = false;

  void emit() {
    _streamController.add(goals.values.toList());
  }

  @override
  Future<Result<SavingsGoal>> createGoal(SavingsGoal goal) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    goals[goal.id] = goal;
    emit();
    return Result.success(goal);
  }

  @override
  Future<Result<SavingsGoal>> updateGoal(SavingsGoal goal) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    if (!goals.containsKey(goal.id)) {
      return Result.failure(const NotFoundFailure('Goal not found'));
    }
    goals[goal.id] = goal;
    emit();
    return Result.success(goal);
  }

  @override
  Future<Result<SavingsGoal?>> getGoalById(String id) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    return Result.success(goals[id]);
  }

  @override
  Future<Result<SavingsGoal>> addContribution(GoalContribution contribution) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    final goal = goals[contribution.goalId];
    if (goal == null) return Result.failure(const NotFoundFailure('Goal not found'));

    final newSaved = goal.savedAmount + contribution.amount;
    final newStatus = newSaved.minorUnits >= goal.targetAmount.minorUnits
        ? GoalStatus.completed
        : goal.status;
    final updated = goal.copyWith(
      savedAmount: newSaved,
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    goals[goal.id] = updated;
    emit();
    return Result.success(updated);
  }

  @override
  Future<Result<SavingsGoal>> withdrawMoney({
    required String goalId,
    required Money amount,
    String? note,
  }) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    final goal = goals[goalId];
    if (goal == null) return Result.failure(const NotFoundFailure('Goal not found'));

    if (goal.savedAmount.minorUnits < amount.minorUnits) {
      return Result.failure(const ValidationFailure('Cannot withdraw more than current amount'));
    }

    final newSaved = goal.savedAmount - amount;
    final newStatus = (newSaved.minorUnits < goal.targetAmount.minorUnits && goal.status == GoalStatus.completed)
        ? GoalStatus.active
        : goal.status;
    final updated = goal.copyWith(
      savedAmount: newSaved,
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    goals[goal.id] = updated;
    emit();
    return Result.success(updated);
  }

  @override
  Future<Result<void>> archiveGoal(String id) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    final goal = goals[id];
    if (goal == null) return Result.failure(const NotFoundFailure('Goal not found'));
    goals[id] = goal.copyWith(status: GoalStatus.archived, updatedAt: DateTime.now());
    emit();
    return Result.success(null);
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    goals.remove(id);
    emit();
    return Result.success(null);
  }

  @override
  Future<Result<List<SavingsGoal>>> getGoals({bool includeArchived = false}) async {
    if (shouldFail) return Result.failure(const DatabaseFailure('Simulated db error'));
    final list = goals.values
        .where((g) => includeArchived || g.status != GoalStatus.archived)
        .toList();
    return Result.success(list);
  }

  @override
  Stream<List<SavingsGoal>> watchGoals({bool includeArchived = false}) async* {
    List<SavingsGoal> applyFilter(List<SavingsGoal> list) {
      return list
          .where((g) => includeArchived || g.status != GoalStatus.archived)
          .toList();
    }

    yield applyFilter(goals.values.toList());
    yield* _streamController.stream.map(applyFilter);
  }
}

