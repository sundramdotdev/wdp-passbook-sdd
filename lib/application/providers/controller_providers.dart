import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/transaction.dart';
import '../controllers/account_controller.dart';
import '../controllers/budget_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/goal_controller.dart';
import '../controllers/transaction_controller.dart';
import '../state/action_state.dart';
import 'usecase_providers.dart';

final transactionControllerProvider =
    StateNotifierProvider<TransactionController, ActionState<Transaction>>((ref) {
  return TransactionController(
    createExpenseUseCase: ref.watch(createExpenseUseCaseProvider),
    createIncomeUseCase: ref.watch(createIncomeUseCaseProvider),
    createTransferUseCase: ref.watch(createTransferUseCaseProvider),
    updateTransactionUseCase: ref.watch(updateTransactionUseCaseProvider),
    deleteTransactionUseCase: ref.watch(deleteTransactionUseCaseProvider),
  );
});

final accountControllerProvider =
    StateNotifierProvider<AccountController, ActionState<Account>>((ref) {
  return AccountController(
    createAccountUseCase: ref.watch(createAccountUseCaseProvider),
    updateAccountUseCase: ref.watch(updateAccountUseCaseProvider),
    archiveAccountUseCase: ref.watch(archiveAccountUseCaseProvider),
    restoreAccountUseCase: ref.watch(restoreAccountUseCaseProvider),
  );
});

final categoryControllerProvider =
    StateNotifierProvider<CategoryController, ActionState<Category>>((ref) {
  return CategoryController(
    createCategoryUseCase: ref.watch(createCategoryUseCaseProvider),
    updateCategoryUseCase: ref.watch(updateCategoryUseCaseProvider),
    archiveCategoryUseCase: ref.watch(archiveCategoryUseCaseProvider),
  );
});

final goalControllerProvider =
    StateNotifierProvider<GoalController, ActionState<SavingsGoal>>((ref) {
  return GoalController(
    createGoalUseCase: ref.watch(createGoalUseCaseProvider),
    addGoalMoneyUseCase: ref.watch(addGoalMoneyUseCaseProvider),
    removeGoalMoneyUseCase: ref.watch(removeGoalMoneyUseCaseProvider),
    archiveGoalUseCase: ref.watch(archiveGoalUseCaseProvider),
  );
});

final budgetControllerProvider =
    StateNotifierProvider<BudgetController, ActionState<Budget>>((ref) {
  return BudgetController(
    createBudgetUseCase: ref.watch(createBudgetUseCaseProvider),
    deleteBudgetUseCase: ref.watch(deleteBudgetUseCaseProvider),
  );
});
