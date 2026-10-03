import '../../core/result/result.dart';
import '../entities/account.dart';
import '../entities/budget.dart';
import '../entities/category.dart';
import '../entities/money.dart';
import '../entities/savings_goal.dart';
import '../enums/personal_enums.dart';

abstract interface class AccountRepository {
  Future<Result<Account>> createAccount(Account account);
  Future<Result<Account>> updateAccount(Account account);
  Future<Result<Account?>> getAccountById(String id);
  Future<Result<List<Account>>> getAccounts({bool includeArchived = false});
  Stream<List<Account>> watchAccounts({bool includeArchived = false});
  Future<Result<void>> archiveAccount(String id);
  Future<Result<void>> restoreAccount(String id);
}

abstract interface class CategoryRepository {
  Future<Result<Category>> createCategory(Category category);
  Future<Result<Category>> updateCategory(Category category);
  Future<Result<Category?>> getCategoryById(String id);
  Future<Result<List<Category>>> getCategories({
    CategoryType? type,
    bool includeArchived = false,
  });
  Stream<List<Category>> watchCategories({
    CategoryType? type,
    bool includeArchived = false,
  });
  Future<Result<void>> archiveCategory(String id);
}

abstract interface class BudgetRepository {
  Future<Result<Budget>> createBudget(Budget budget);
  Future<Result<Budget>> updateBudget(Budget budget);
  Future<Result<void>> deleteBudget(String id);
  Future<Result<List<Budget>>> getBudgets();
  Stream<List<Budget>> watchBudgets();
}

abstract interface class GoalRepository {
  Future<Result<SavingsGoal>> createGoal(SavingsGoal goal);
  Future<Result<SavingsGoal>> updateGoal(SavingsGoal goal);
  Future<Result<SavingsGoal?>> getGoalById(String id);
  Future<Result<SavingsGoal>> addContribution(GoalContribution contribution);
  Future<Result<SavingsGoal>> withdrawMoney({
    required String goalId,
    required Money amount,
    String? note,
  });
  Future<Result<void>> archiveGoal(String id);
  Future<Result<void>> deleteGoal(String id);
  Future<Result<List<SavingsGoal>>> getGoals({bool includeArchived = false});
  Stream<List<SavingsGoal>> watchGoals({bool includeArchived = false});
}
