import '../../domain/entities/account.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/enums/personal_enums.dart';
import '../local/isar/isar_account.dart';
import '../local/isar/isar_budget.dart';
import '../local/isar/isar_category.dart';
import '../local/isar/isar_goal.dart';
import '../local/isar/isar_goal_contribution.dart';

class AccountMapper {
  static Account toDomain(IsarAccount isar) {
    return Account(
      id: isar.uuid,
      name: isar.name,
      type: AccountType.values.firstWhere(
        (e) => e.name == isar.type,
        orElse: () => AccountType.bank,
      ),
      currencyCode: isar.currencyCode,
      balance: Money(
        minorUnits: isar.balanceMinorUnits,
        currencyCode: isar.currencyCode,
      ),
      iconName: isar.iconName,
      colorHex: isar.colorHex,
      isArchived: isar.isArchived,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
    );
  }

  static IsarAccount toIsar(Account domain, [IsarAccount? existing]) {
    final isar = existing ?? IsarAccount();
    isar.uuid = domain.id;
    isar.name = domain.name;
    isar.type = domain.type.name;
    isar.balanceMinorUnits = domain.balance.minorUnits;
    isar.currencyCode = domain.currencyCode;
    isar.iconName = domain.iconName;
    isar.colorHex = domain.colorHex;
    isar.isArchived = domain.isArchived;
    isar.createdAt = domain.createdAt;
    isar.updatedAt = domain.updatedAt;
    return isar;
  }
}

class CategoryMapper {
  static Category toDomain(IsarCategory isar) {
    return Category(
      id: isar.uuid,
      name: isar.name,
      type: CategoryType.values.firstWhere(
        (e) => e.name == isar.type,
        orElse: () => CategoryType.expense,
      ),
      iconName: isar.iconName,
      colorHex: isar.colorHex,
      isDefault: isar.isDefault,
      isArchived: isar.isArchived,
    );
  }

  static IsarCategory toIsar(Category domain, [IsarCategory? existing]) {
    final isar = existing ?? IsarCategory();
    isar.uuid = domain.id;
    isar.name = domain.name;
    isar.type = domain.type.name;
    isar.iconName = domain.iconName;
    isar.colorHex = domain.colorHex;
    isar.isDefault = domain.isDefault;
    isar.isArchived = domain.isArchived;
    return isar;
  }
}

class BudgetMapper {
  static Budget toDomain(IsarBudget isar) {
    return Budget(
      id: isar.uuid,
      categoryId: isar.categoryId,
      categoryName: isar.categoryName,
      limitAmount: Money(minorUnits: isar.limitMinorUnits),
      spentAmount: Money(minorUnits: isar.spentMinorUnits),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == isar.period,
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: isar.startDate,
      endDate: isar.endDate,
    );
  }

  static IsarBudget toIsar(Budget domain, [IsarBudget? existing]) {
    final isar = existing ?? IsarBudget();
    isar.uuid = domain.id;
    isar.categoryId = domain.categoryId;
    isar.categoryName = domain.categoryName;
    isar.limitMinorUnits = domain.limitAmount.minorUnits;
    isar.spentMinorUnits = domain.spentAmount.minorUnits;
    isar.period = domain.period.name;
    isar.startDate = domain.startDate;
    isar.endDate = domain.endDate;
    return isar;
  }
}

class GoalMapper {
  static SavingsGoal toDomain(IsarGoal isar) {
    return SavingsGoal(
      id: isar.uuid,
      title: isar.title,
      targetAmount: Money(minorUnits: isar.targetMinorUnits),
      savedAmount: Money(minorUnits: isar.savedMinorUnits),
      targetDate: isar.targetDate,
      iconName: isar.iconName,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == isar.status,
        orElse: () => GoalStatus.active,
      ),
    );
  }

  static IsarGoal toIsar(SavingsGoal domain, [IsarGoal? existing]) {
    final isar = existing ?? IsarGoal();
    isar.uuid = domain.id;
    isar.title = domain.title;
    isar.targetMinorUnits = domain.targetAmount.minorUnits;
    isar.savedMinorUnits = domain.savedAmount.minorUnits;
    isar.targetDate = domain.targetDate;
    isar.iconName = domain.iconName;
    isar.status = domain.status.name;
    return isar;
  }
}
