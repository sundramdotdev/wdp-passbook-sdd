import 'package:isar/isar.dart';
import '../local/isar/isar_transaction.dart';

/// Data source performing local Isar persistence operations for Transactions.
class IsarTransactionDataSource {
  final Future<Isar> _db;

  IsarTransactionDataSource(this._db);

  Future<IsarTransaction> create(IsarTransaction transaction) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.isarTransactions.put(transaction);
    });
    return transaction;
  }

  Future<IsarTransaction> update(IsarTransaction transaction) async {
    final isar = await _db;
    final existing = await isar.isarTransactions
        .filter()
        .uuidEqualTo(transaction.uuid)
        .findFirst();

    if (existing != null) {
      transaction.id = existing.id;
    }

    await isar.writeTxn(() async {
      await isar.isarTransactions.put(transaction);
    });
    return transaction;
  }

  Future<bool> delete(String uuid) async {
    final isar = await _db;
    final existing = await isar.isarTransactions
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();

    if (existing != null) {
      await isar.writeTxn(() async {
        await isar.isarTransactions.delete(existing.id);
      });
      return true;
    }
    return false;
  }

  Future<IsarTransaction?> getById(String uuid) async {
    final isar = await _db;
    return isar.isarTransactions.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<List<IsarTransaction>> query({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
    String? type,
    String? searchQuery,
  }) async {
    final isar = await _db;
    QueryBuilder<IsarTransaction, IsarTransaction, QAfterFilterCondition>? query;

    QueryBuilder<IsarTransaction, IsarTransaction, QAfterFilterCondition> add(
      QueryBuilder<IsarTransaction, IsarTransaction, QAfterFilterCondition> Function(
        QueryBuilder<IsarTransaction, IsarTransaction, QFilterCondition> q,
      ) filter,
    ) {
      final current = query;
      if (current == null) {
        return query = filter(isar.isarTransactions.filter());
      } else {
        return query = filter(current);
      }
    }

    if (startDate != null) {
      add((q) => q.dateGreaterThan(startDate, include: true));
    }
    if (endDate != null) {
      add((q) => q.dateLessThan(endDate, include: true));
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      add((q) => q.categoryIdEqualTo(categoryId));
    }
    if (accountId != null && accountId.isNotEmpty) {
      add((q) => q.group((g) => g
          .accountIdEqualTo(accountId)
          .or()
          .targetAccountIdEqualTo(accountId)));
    }
    if (type != null && type.isNotEmpty) {
      add((q) => q.typeEqualTo(type));
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      add((q) => q.remarkContains(searchQuery.trim(), caseSensitive: false));
    }

    if (query != null) {
      return query!.sortByDateDesc().findAll();
    } else {
      return isar.isarTransactions.where().sortByDateDesc().findAll();
    }
  }

  Stream<List<IsarTransaction>> watchAll({
    String? accountId,
    String? type,
  }) async* {
    final isar = await _db;
    QueryBuilder<IsarTransaction, IsarTransaction, QAfterFilterCondition>? query;

    QueryBuilder<IsarTransaction, IsarTransaction, QAfterFilterCondition> add(
      QueryBuilder<IsarTransaction, IsarTransaction, QAfterFilterCondition> Function(
        QueryBuilder<IsarTransaction, IsarTransaction, QFilterCondition> q,
      ) filter,
    ) {
      final current = query;
      if (current == null) {
        return query = filter(isar.isarTransactions.filter());
      } else {
        return query = filter(current);
      }
    }

    if (accountId != null && accountId.isNotEmpty) {
      add((q) => q.group((g) => g
          .accountIdEqualTo(accountId)
          .or()
          .targetAccountIdEqualTo(accountId)));
    }
    if (type != null && type.isNotEmpty) {
      add((q) => q.typeEqualTo(type));
    }

    if (query != null) {
      yield* query!.sortByDateDesc().watch(fireImmediately: true);
    } else {
      yield* isar.isarTransactions.where().sortByDateDesc().watch(fireImmediately: true);
    }
  }

  /// Calculates the balance of an account strictly from transaction history.
  /// Transfers:
  /// - Deducted if this account was the source.
  /// - Credited if this account was the destination.
  Future<int> calculateAccountBalanceMinor(String accountId) async {
    final isar = await _db;
    final allForAccount = await isar.isarTransactions
        .filter()
        .group((g) => g
            .accountIdEqualTo(accountId)
            .or()
            .targetAccountIdEqualTo(accountId))
        .findAll();

    int totalMinor = 0;
    for (final tx in allForAccount) {
      if (tx.type == 'income' && tx.accountId == accountId) {
        totalMinor += tx.minorUnits;
      } else if (tx.type == 'expense' && tx.accountId == accountId) {
        totalMinor -= tx.minorUnits;
      } else if (tx.type == 'transfer') {
        if (tx.accountId == accountId) {
          totalMinor -= tx.minorUnits; // Money transferred out
        }
        if (tx.targetAccountId == accountId) {
          totalMinor += tx.minorUnits; // Money transferred in
        }
      }
    }

    return totalMinor;
  }

  /// Calculates income and expense totals for a date range.
  /// Invariant: Transfers MUST NOT count as income or expense!
  Future<({int incomeMinor, int expenseMinor})> calculateIncomeAndExpense({
    required DateTime startDate,
    required DateTime endDate,
    String? accountId,
  }) async {
    final isar = await _db;
    var q = isar.isarTransactions
        .filter()
        .dateGreaterThan(startDate, include: true)
        .and()
        .dateLessThan(endDate, include: true);

    if (accountId != null && accountId.isNotEmpty) {
      q = q.and().accountIdEqualTo(accountId);
    }

    final txList = await q.findAll();

    int totalIncome = 0;
    int totalExpense = 0;

    for (final tx in txList) {
      if (tx.type == 'income') {
        totalIncome += tx.minorUnits;
      } else if (tx.type == 'expense') {
        totalExpense += tx.minorUnits;
      }
      // Note: Transfers are strictly ignored here as per domain invariants!
    }

    return (incomeMinor: totalIncome, expenseMinor: totalExpense);
  }
}
