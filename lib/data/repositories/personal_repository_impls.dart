import 'package:isar/isar.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/enums/personal_enums.dart';
import '../../domain/repositories/personal_repositories.dart';
import '../datasources/isar_account_datasource.dart';
import '../datasources/isar_category_datasource.dart';
import '../local/isar/isar_budget.dart';
import '../local/isar/isar_goal.dart';
import '../mappers/personal_mappers.dart';
import '../services/isar_service.dart';

class IsarAccountRepository implements AccountRepository {
  final IsarService isarService;
  late final IsarAccountDataSource _dataSource;

  IsarAccountRepository(this.isarService, [IsarAccountDataSource? dataSource]) {
    _dataSource = dataSource ?? IsarAccountDataSource(isarService.db);
  }

  @override
  Future<Result<Account>> createAccount(Account account) async {
    try {
      final isarAcc = AccountMapper.toIsar(account);
      final created = await _dataSource.create(isarAcc);
      return Result.success(AccountMapper.toDomain(created));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create account: $e'));
    }
  }

  @override
  Future<Result<Account>> updateAccount(Account account) async {
    try {
      final isarAcc = AccountMapper.toIsar(account);
      final updated = await _dataSource.update(isarAcc);
      return Result.success(AccountMapper.toDomain(updated));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update account: $e'));
    }
  }

  @override
  Future<Result<Account?>> getAccountById(String id) async {
    try {
      final isarAcc = await _dataSource.getById(id);
      if (isarAcc == null) return Result.success(null);
      return Result.success(AccountMapper.toDomain(isarAcc));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get account: $e'));
    }
  }

  @override
  Future<Result<List<Account>>> getAccounts({bool includeArchived = false}) async {
    try {
      final list = await _dataSource.getAll(includeArchived: includeArchived);
      return Result.success(list.map(AccountMapper.toDomain).toList());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch accounts: $e'));
    }
  }

  @override
  Stream<List<Account>> watchAccounts({bool includeArchived = false}) async* {
    yield* _dataSource
        .watchAll(includeArchived: includeArchived)
        .map((list) => list.map(AccountMapper.toDomain).toList());
  }

  @override
  Future<Result<void>> archiveAccount(String id) async {
    try {
      final success = await _dataSource.archive(id);
      if (!success) {
        return Result.failure(NotFoundFailure('Account with ID "$id" not found.'));
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to archive account: $e'));
    }
  }

  @override
  Future<Result<void>> restoreAccount(String id) async {
    try {
      final success = await _dataSource.restore(id);
      if (!success) {
        return Result.failure(NotFoundFailure('Account with ID "$id" not found.'));
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to restore account: $e'));
    }
  }
}

class IsarCategoryRepository implements CategoryRepository {
  final IsarService isarService;
  late final IsarCategoryDataSource _dataSource;

  IsarCategoryRepository(this.isarService, [IsarCategoryDataSource? dataSource]) {
    _dataSource = dataSource ?? IsarCategoryDataSource(isarService.db);
  }

  @override
  Future<Result<Category>> createCategory(Category category) async {
    try {
      final isarCat = CategoryMapper.toIsar(category);
      final created = await _dataSource.create(isarCat);
      return Result.success(CategoryMapper.toDomain(created));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create category: $e'));
    }
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    try {
      final isarCat = CategoryMapper.toIsar(category);
      final updated = await _dataSource.update(isarCat);
      return Result.success(CategoryMapper.toDomain(updated));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update category: $e'));
    }
  }

  @override
  Future<Result<Category?>> getCategoryById(String id) async {
    try {
      final isarCat = await _dataSource.getById(id);
      if (isarCat == null) return Result.success(null);
      return Result.success(CategoryMapper.toDomain(isarCat));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get category: $e'));
    }
  }

  @override
  Future<Result<List<Category>>> getCategories({
    CategoryType? type,
    bool includeArchived = false,
  }) async {
    try {
      final list = await _dataSource.getAll(
        type: type?.name,
        includeArchived: includeArchived,
      );
      return Result.success(list.map(CategoryMapper.toDomain).toList());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch categories: $e'));
    }
  }

  @override
  Stream<List<Category>> watchCategories({
    CategoryType? type,
    bool includeArchived = false,
  }) async* {
    yield* _dataSource
        .watchAll(type: type?.name, includeArchived: includeArchived)
        .map((list) => list.map(CategoryMapper.toDomain).toList());
  }

  @override
  Future<Result<void>> archiveCategory(String id) async {
    try {
      final success = await _dataSource.archive(id);
      if (!success) {
        return Result.failure(NotFoundFailure('Category with ID "$id" not found.'));
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to archive category: $e'));
    }
  }
}

class IsarBudgetRepository implements BudgetRepository {
  final IsarService isarService;
  IsarBudgetRepository(this.isarService);

  @override
  Future<Result<Budget>> createBudget(Budget budget) async {
    try {
      final isar = await isarService.db;
      final isarBudget = BudgetMapper.toIsar(budget);
      await isar.writeTxn(() async {
        await isar.isarBudgets.put(isarBudget);
      });
      return Result.success(budget);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create budget: $e'));
    }
  }

  @override
  Future<Result<Budget>> updateBudget(Budget budget) async {
    try {
      final isar = await isarService.db;
      final existing = await isar.isarBudgets.where().uuidEqualTo(budget.id).findFirst();
      final isarBudget = BudgetMapper.toIsar(budget, existing);
      await isar.writeTxn(() async {
        await isar.isarBudgets.put(isarBudget);
      });
      return Result.success(budget);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update budget: $e'));
    }
  }

  @override
  Future<Result<void>> deleteBudget(String id) async {
    try {
      final isar = await isarService.db;
      final existing = await isar.isarBudgets.where().uuidEqualTo(id).findFirst();
      if (existing != null) {
        await isar.writeTxn(() async {
          await isar.isarBudgets.delete(existing.id);
        });
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete budget: $e'));
    }
  }

  @override
  Future<Result<List<Budget>>> getBudgets() async {
    try {
      final isar = await isarService.db;
      final list = await isar.isarBudgets.where().findAll();
      return Result.success(list.map(BudgetMapper.toDomain).toList());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch budgets: $e'));
    }
  }

  @override
  Stream<List<Budget>> watchBudgets() async* {
    final isar = await isarService.db;
    yield* isar.isarBudgets.where().watch(fireImmediately: true).map(
          (list) => list.map(BudgetMapper.toDomain).toList(),
        );
  }
}

class IsarGoalRepository implements GoalRepository {
  final IsarService isarService;
  IsarGoalRepository(this.isarService);

  @override
  Future<Result<SavingsGoal>> createGoal(SavingsGoal goal) async {
    try {
      final isar = await isarService.db;
      final isarGoal = GoalMapper.toIsar(goal);
      await isar.writeTxn(() async {
        await isar.isarGoals.put(isarGoal);
      });
      return Result.success(goal);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create goal: $e'));
    }
  }

  @override
  Future<Result<SavingsGoal>> updateGoal(SavingsGoal goal) async {
    try {
      final isar = await isarService.db;
      final existing = await isar.isarGoals.filter().uuidEqualTo(goal.id).findFirst();
      if (existing == null) {
        return Result.failure(const NotFoundFailure('Goal not found to update'));
      }
      final isarGoal = GoalMapper.toIsar(goal, existing);
      await isar.writeTxn(() async {
        await isar.isarGoals.put(isarGoal);
      });
      return Result.success(goal);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update goal: $e'));
    }
  }

  @override
  Future<Result<SavingsGoal?>> getGoalById(String id) async {
    try {
      final isar = await isarService.db;
      final existing = await isar.isarGoals.filter().uuidEqualTo(id).findFirst();
      if (existing == null) return Result.success(null);
      return Result.success(GoalMapper.toDomain(existing));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get goal: $e'));
    }
  }

  @override
  Future<Result<SavingsGoal>> addContribution(GoalContribution contribution) async {
    try {
      final isar = await isarService.db;
      final goal = await isar.isarGoals.filter().uuidEqualTo(contribution.goalId).findFirst();
      if (goal == null) {
        return Result.failure(const NotFoundFailure('Goal not found to add contribution'));
      }

      await isar.writeTxn(() async {
        goal.savedMinorUnits += contribution.amount.minorUnits;
        if (goal.savedMinorUnits >= goal.targetMinorUnits && goal.status != 'archived') {
          goal.status = GoalStatus.completed.name;
        }
        await isar.isarGoals.put(goal);
      });

      return Result.success(GoalMapper.toDomain(goal));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to add contribution: $e'));
    }
  }

  @override
  Future<Result<SavingsGoal>> withdrawMoney({
    required String goalId,
    required Money amount,
    String? note,
  }) async {
    try {
      final isar = await isarService.db;
      final goal = await isar.isarGoals.filter().uuidEqualTo(goalId).findFirst();
      if (goal == null) {
        return Result.failure(const NotFoundFailure('Goal not found to withdraw money'));
      }
      if (goal.savedMinorUnits < amount.minorUnits) {
        return Result.failure(const ValidationFailure('Cannot withdraw more than current saved amount.'));
      }

      await isar.writeTxn(() async {
        goal.savedMinorUnits -= amount.minorUnits;
        if (goal.savedMinorUnits < goal.targetMinorUnits &&
            (goal.status == GoalStatus.completed.name || goal.status == GoalStatus.achieved.name)) {
          goal.status = GoalStatus.active.name;
        }
        await isar.isarGoals.put(goal);
      });

      return Result.success(GoalMapper.toDomain(goal));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to withdraw money from goal: $e'));
    }
  }

  @override
  Future<Result<void>> archiveGoal(String id) async {
    try {
      final isar = await isarService.db;
      final goal = await isar.isarGoals.filter().uuidEqualTo(id).findFirst();
      if (goal == null) {
        return Result.failure(const NotFoundFailure('Goal not found to archive'));
      }
      await isar.writeTxn(() async {
        goal.status = GoalStatus.archived.name;
        await isar.isarGoals.put(goal);
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to archive goal: $e'));
    }
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    try {
      final isar = await isarService.db;
      final existing = await isar.isarGoals.filter().uuidEqualTo(id).findFirst();
      if (existing != null) {
        await isar.writeTxn(() async {
          await isar.isarGoals.delete(existing.id);
        });
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete goal: $e'));
    }
  }

  @override
  Future<Result<List<SavingsGoal>>> getGoals({bool includeArchived = false}) async {
    try {
      final isar = await isarService.db;
      final list = await isar.isarGoals.where().findAll();
      final filtered = includeArchived
          ? list
          : list.where((g) => g.status != GoalStatus.archived.name).toList();
      return Result.success(filtered.map(GoalMapper.toDomain).toList());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch goals: $e'));
    }
  }

  @override
  Stream<List<SavingsGoal>> watchGoals({bool includeArchived = false}) async* {
    final isar = await isarService.db;
    yield* isar.isarGoals.where().watch(fireImmediately: true).map(
          (list) => (includeArchived
                  ? list
                  : list.where((g) => g.status != GoalStatus.archived.name))
              .map(GoalMapper.toDomain)
              .toList(),
        );
  }
}
