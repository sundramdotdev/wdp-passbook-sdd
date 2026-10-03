import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../local/isar/isar_transaction.dart';
import '../local/isar/isar_account.dart';
import '../local/isar/isar_category.dart';
import '../local/isar/isar_budget.dart';
import '../local/isar/isar_goal.dart';
import '../local/isar/isar_goal_contribution.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      final isar = await Isar.open(
        [
          IsarTransactionSchema,
          IsarAccountSchema,
          IsarCategorySchema,
          IsarBudgetSchema,
          IsarGoalSchema,
          IsarGoalContributionSchema,
        ],
        directory: dir.path,
      );

      await _seedDefaultData(isar);
      return isar;
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> _seedDefaultData(Isar isar) async {
    // Seed default categories if empty
    final categoryCount = await isar.isarCategorys.count();
    if (categoryCount == 0) {
      final defaultCategories = [
        // Expense Categories
        IsarCategory()
          ..uuid = 'cat_food'
          ..name = 'Food'
          ..type = 'expense'
          ..iconName = 'utensils'
          ..colorHex = '#F97316'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_transport'
          ..name = 'Transport'
          ..type = 'expense'
          ..iconName = 'car'
          ..colorHex = '#3B82F6'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_shopping'
          ..name = 'Shopping'
          ..type = 'expense'
          ..iconName = 'shopping-bag'
          ..colorHex = '#FBBF24'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_bills'
          ..name = 'Bills'
          ..type = 'expense'
          ..iconName = 'zap'
          ..colorHex = '#EF4444'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_entertainment'
          ..name = 'Entertainment'
          ..type = 'expense'
          ..iconName = 'film'
          ..colorHex = '#8B5CF6'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_health'
          ..name = 'Health'
          ..type = 'expense'
          ..iconName = 'heart-pulse'
          ..colorHex = '#EC4899'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_education'
          ..name = 'Education'
          ..type = 'expense'
          ..iconName = 'book-open'
          ..colorHex = '#10B981'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_travel'
          ..name = 'Travel'
          ..type = 'expense'
          ..iconName = 'plane'
          ..colorHex = '#06B6D4'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_other_expense'
          ..name = 'Other'
          ..type = 'expense'
          ..iconName = 'grid'
          ..colorHex = '#98A2B3'
          ..isDefault = true,

        // Income Categories
        IsarCategory()
          ..uuid = 'cat_salary'
          ..name = 'Salary'
          ..type = 'income'
          ..iconName = 'wallet'
          ..colorHex = '#16A34A'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_freelance'
          ..name = 'Freelance'
          ..type = 'income'
          ..iconName = 'laptop'
          ..colorHex = '#059669'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_business'
          ..name = 'Business'
          ..type = 'income'
          ..iconName = 'briefcase'
          ..colorHex = '#0D9488'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_gift'
          ..name = 'Gift'
          ..type = 'income'
          ..iconName = 'gift'
          ..colorHex = '#D97706'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_interest'
          ..name = 'Interest'
          ..type = 'income'
          ..iconName = 'trending-up'
          ..colorHex = '#2563EB'
          ..isDefault = true,
        IsarCategory()
          ..uuid = 'cat_other_income'
          ..name = 'Other'
          ..type = 'income'
          ..iconName = 'grid'
          ..colorHex = '#64748B'
          ..isDefault = true,
      ];
      await isar.writeTxn(() async {
        await isar.isarCategorys.putAll(defaultCategories);
      });
    }

    // Seed default accounts if empty
    final accountCount = await isar.isarAccounts.count();
    if (accountCount == 0) {
      final defaultAccounts = [
        IsarAccount()
          ..uuid = 'acc_cash'
          ..name = 'Cash in Hand'
          ..type = 'cash'
          ..balanceMinorUnits = 250000 // ₹2,500.00
          ..currencyCode = 'INR'
          ..iconName = 'coins'
          ..colorHex = '#F97316',
        IsarAccount()
          ..uuid = 'acc_bank'
          ..name = 'Primary Bank'
          ..type = 'bank'
          ..balanceMinorUnits = 4850000 // ₹48,500.00
          ..currencyCode = 'INR'
          ..iconName = 'landmark'
          ..colorHex = '#3B82F6',
      ];
      await isar.writeTxn(() async {
        await isar.isarAccounts.putAll(defaultAccounts);
      });
    }
  }
}
