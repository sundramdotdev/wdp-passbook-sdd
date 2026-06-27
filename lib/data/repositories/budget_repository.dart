import 'package:isar/isar.dart';
import '../models/budget.dart';

class BudgetRepository {
  final Isar isar;

  BudgetRepository(this.isar);

  Future<void> addOrUpdateBudget(Budget budget) async {
    await isar.writeTxn(() async {
      await isar.budgets.put(budget);
    });
  }

  Future<void> deleteBudget(int id) async {
    await isar.writeTxn(() async {
      await isar.budgets.delete(id);
    });
  }

  Stream<List<Budget>> watchBudgets() {
    return isar.budgets.where().watch(fireImmediately: true);
  }

  Future<List<Budget>> getAllBudgets() async {
    return isar.budgets.where().findAll();
  }
}
