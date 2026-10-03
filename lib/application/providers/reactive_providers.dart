import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/enums/personal_enums.dart';
import '../../domain/usecases/personal_usecases.dart';
import '../commands/transaction_filter.dart';
import 'repository_providers.dart';

/// Reactive stream of transactions directly from database.
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchTransactions();
});

/// Current active transaction filter.
final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return const TransactionFilter.empty();
});

/// Reactive stream of transactions filtered by the active TransactionFilter.
final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final filter = ref.watch(transactionFilterProvider);

  return transactionsAsync.whenData((transactions) {
    if (!filter.isActive) return transactions;

    return transactions.where((t) {
      if (filter.startDate != null && t.date.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null && t.date.isAfter(filter.endDate!)) {
        return false;
      }
      if (filter.categoryId != null &&
          filter.categoryId!.isNotEmpty &&
          t.categoryId != filter.categoryId) {
        return false;
      }
      if (filter.accountId != null &&
          filter.accountId!.isNotEmpty &&
          t.accountId != filter.accountId &&
          t.targetAccountId != filter.accountId) {
        return false;
      }
      if (filter.type != null && t.type != filter.type) {
        return false;
      }
      if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
        final query = filter.searchQuery!.trim().toLowerCase();
        final matchesRemark = t.remark.toLowerCase().contains(query);
        final matchesCategory = t.categoryName.toLowerCase().contains(query);
        final matchesAccount = t.accountName.toLowerCase().contains(query);
        if (!matchesRemark && !matchesCategory && !matchesAccount) {
          return false;
        }
      }
      if (filter.minAmount != null && t.amount < filter.minAmount!) {
        return false;
      }
      if (filter.maxAmount != null && t.amount > filter.maxAmount!) {
        return false;
      }
      return true;
    }).toList();
  });
});

/// Reactive stream of active accounts.
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAccounts(includeArchived: false);
});

/// Reactive stream of all accounts (including archived).
final allAccountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAccounts(includeArchived: true);
});

/// Single account family provider.
final accountByIdProvider = Provider.family<Account?, String>((ref, id) {
  final accountsAsync = ref.watch(allAccountsStreamProvider);
  return accountsAsync.valueOrNull?.firstWhere(
    (a) => a.id == id,
    orElse: () => null as dynamic,
  );
});

/// Reactive stream of categories by type.
final categoriesStreamProvider =
    StreamProvider.family<List<Category>, CategoryType?>((ref, type) {
  return ref.watch(categoryRepositoryProvider).watchCategories(
        type: type,
        includeArchived: false,
      );
});

/// Reactive stream of active Expense categories.
final expenseCategoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories(
        type: CategoryType.expense,
        includeArchived: false,
      );
});

/// Reactive stream of active Income categories.
final incomeCategoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories(
        type: CategoryType.income,
        includeArchived: false,
      );
});

/// Future provider of categories for quick one-time pickers.
final categoriesFutureProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  final res = await useCase.call();
  return res.fold((cats) => cats, (_) => []);
});

/// Derived total portfolio balance across all active accounts.
final totalBalanceProvider = Provider<AsyncValue<Money>>((ref) {
  final accountsAsync = ref.watch(accountsStreamProvider);
  return accountsAsync.whenData((accounts) {
    int totalMinor = 0;
    for (final acc in accounts) {
      if (!acc.isArchived) {
        totalMinor += acc.balance.minorUnits;
      }
    }
    return Money(minorUnits: totalMinor);
  });
});

/// Derived account balance strictly from transactions history.
final accountBalanceProvider =
    FutureProvider.family<Money, String>((ref, accountId) async {
  // Recompute whenever transactions stream emits a new event
  ref.watch(transactionsStreamProvider);
  final useCase = ref.watch(getAccountBalanceUseCaseProvider);
  final result = await useCase.call(accountId);
  return result.fold(
    (money) => money,
    (_) => const Money.zero(),
  );
});

/// Derived monthly income and expenses strictly excluding transfers.
final monthlyInsightProvider =
    Provider<AsyncValue<({Money income, Money expense})>>((ref) {
  final txnsAsync = ref.watch(transactionsStreamProvider);
  return txnsAsync.whenData((txns) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    int income = 0;
    int expense = 0;

    for (final t in txns) {
      if (t.date.isAfter(firstDayOfMonth) || t.date.isAtSameMomentAs(firstDayOfMonth)) {
        if (t.isIncome) income += t.amount.minorUnits;
        if (t.isExpense) expense += t.amount.minorUnits;
        // Transfers are strictly omitted
      }
    }
    return (
      income: Money(minorUnits: income),
      expense: Money(minorUnits: expense),
    );
  });
});

/// Reactive stream of budgets.
final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchBudgets();
});

/// Reactive stream of calculated budgets derived from transactions.
/// Updates automatically whenever transactions or budgets change.
final calculatedBudgetsStreamProvider =
    Provider<AsyncValue<List<CalculatedBudget>>>((ref) {
  final budgetsAsync = ref.watch(budgetsStreamProvider);
  final txnsAsync = ref.watch(transactionsStreamProvider);
  final calculateUseCase = ref.watch(calculateBudgetSpendingUseCaseProvider);

  if (budgetsAsync.hasError) {
    return AsyncValue.error(budgetsAsync.error!, budgetsAsync.stackTrace!);
  }
  if (txnsAsync.hasError) {
    return AsyncValue.error(txnsAsync.error!, txnsAsync.stackTrace!);
  }
  if (budgetsAsync.isLoading || txnsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final budgets = budgetsAsync.value ?? [];
  final txns = txnsAsync.value ?? [];

  final calculated = budgets.map((b) {
    return calculateUseCase.call(budget: b, transactions: txns);
  }).toList();

  return AsyncValue.data(calculated);
});

/// Reactive stream of savings goals.
final goalsStreamProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(goalRepositoryProvider).watchGoals();
});

/// Single goal family provider.
final goalByIdProvider = Provider.family<SavingsGoal?, String>((ref, id) {
  final goalsAsync = ref.watch(goalsStreamProvider);
  return goalsAsync.valueOrNull?.firstWhere(
    (g) => g.id == id,
    orElse: () => null as dynamic,
  );
});

/// Analytics Summary Provider
final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  ref.watch(transactionsStreamProvider);
  final useCase = GetAnalyticsUseCase(ref.watch(transactionRepositoryProvider));
  final res = await useCase.call();
  return res.fold((summary) => summary, (failure) => AnalyticsSummary.empty());
});

