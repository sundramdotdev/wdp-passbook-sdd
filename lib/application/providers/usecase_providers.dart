import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecases/account_usecases.dart';
import '../usecases/balance_usecases.dart';
import '../usecases/budget_usecases.dart';
import '../usecases/category_usecases.dart';
import '../usecases/goal_usecases.dart';
import '../usecases/transaction_usecases.dart';
import 'repository_providers.dart';

// --- Transaction Use Cases ---
final createExpenseUseCaseProvider = Provider<CreateExpenseUseCase>((ref) {
  return CreateExpenseUseCase(
    transactionRepository: ref.watch(transactionRepositoryProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});

final createIncomeUseCaseProvider = Provider<CreateIncomeUseCase>((ref) {
  return CreateIncomeUseCase(
    transactionRepository: ref.watch(transactionRepositoryProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});

final createTransferUseCaseProvider = Provider<CreateTransferUseCase>((ref) {
  return CreateTransferUseCase(
    transactionRepository: ref.watch(transactionRepositoryProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
  );
});

final updateTransactionUseCaseProvider = Provider<UpdateTransactionUseCase>((ref) {
  return UpdateTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((ref) {
  return DeleteTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final getTransactionUseCaseProvider = Provider<GetTransactionUseCase>((ref) {
  return GetTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(ref.watch(transactionRepositoryProvider));
});

final searchTransactionsUseCaseProvider = Provider<SearchTransactionsUseCase>((ref) {
  return SearchTransactionsUseCase(ref.watch(transactionRepositoryProvider));
});

// --- Account Use Cases ---
final createAccountUseCaseProvider = Provider<CreateAccountUseCase>((ref) {
  return CreateAccountUseCase(ref.watch(accountRepositoryProvider));
});

final updateAccountUseCaseProvider = Provider<UpdateAccountUseCase>((ref) {
  return UpdateAccountUseCase(ref.watch(accountRepositoryProvider));
});

final archiveAccountUseCaseProvider = Provider<ArchiveAccountUseCase>((ref) {
  return ArchiveAccountUseCase(ref.watch(accountRepositoryProvider));
});

final restoreAccountUseCaseProvider = Provider<RestoreAccountUseCase>((ref) {
  return RestoreAccountUseCase(ref.watch(accountRepositoryProvider));
});

final getAccountUseCaseProvider = Provider<GetAccountUseCase>((ref) {
  return GetAccountUseCase(ref.watch(accountRepositoryProvider));
});

final getAccountsUseCaseProvider = Provider<GetAccountsUseCase>((ref) {
  return GetAccountsUseCase(ref.watch(accountRepositoryProvider));
});

// --- Category Use Cases ---
final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  return CreateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final archiveCategoryUseCaseProvider = Provider<ArchiveCategoryUseCase>((ref) {
  return ArchiveCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

// --- Balance Use Cases ---
final getTotalBalanceUseCaseProvider = Provider<GetTotalBalanceUseCase>((ref) {
  return GetTotalBalanceUseCase(ref.watch(accountRepositoryProvider));
});

final getAccountBalanceUseCaseProvider = Provider<GetAccountBalanceUseCase>((ref) {
  return GetAccountBalanceUseCase(ref.watch(transactionRepositoryProvider));
});

// --- Goal Use Cases ---
final createGoalUseCaseProvider = Provider<CreateGoalUseCase>((ref) {
  return CreateGoalUseCase(ref.watch(goalRepositoryProvider));
});

final addGoalMoneyUseCaseProvider = Provider<AddGoalMoneyUseCase>((ref) {
  return AddGoalMoneyUseCase(ref.watch(goalRepositoryProvider));
});

final removeGoalMoneyUseCaseProvider = Provider<RemoveGoalMoneyUseCase>((ref) {
  return RemoveGoalMoneyUseCase(ref.watch(goalRepositoryProvider));
});

final archiveGoalUseCaseProvider = Provider<ArchiveGoalUseCase>((ref) {
  return ArchiveGoalUseCase(ref.watch(goalRepositoryProvider));
});

final getGoalsUseCaseProvider = Provider<GetGoalsUseCase>((ref) {
  return GetGoalsUseCase(ref.watch(goalRepositoryProvider));
});

// --- Budget Use Cases ---
final createBudgetUseCaseProvider = Provider<CreateBudgetUseCase>((ref) {
  return CreateBudgetUseCase(
    budgetRepository: ref.watch(budgetRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  return DeleteBudgetUseCase(ref.watch(budgetRepositoryProvider));
});

final calculateBudgetSpendingUseCaseProvider = Provider<CalculateBudgetSpendingUseCase>((ref) {
  return const CalculateBudgetSpendingUseCase();
});
