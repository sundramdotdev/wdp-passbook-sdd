import 'package:isar/isar.dart';
import '../local/isar/isar_account.dart';

/// Data source performing local Isar persistence operations for Accounts.
class IsarAccountDataSource {
  final Future<Isar> _db;

  IsarAccountDataSource(this._db);

  Future<IsarAccount> create(IsarAccount account) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.isarAccounts.put(account);
    });
    return account;
  }

  Future<IsarAccount> update(IsarAccount account) async {
    final isar = await _db;
    final existing = await isar.isarAccounts
        .filter()
        .uuidEqualTo(account.uuid)
        .findFirst();

    if (existing != null) {
      account.id = existing.id;
    }

    await isar.writeTxn(() async {
      await isar.isarAccounts.put(account);
    });
    return account;
  }

  Future<IsarAccount?> getById(String uuid) async {
    final isar = await _db;
    return isar.isarAccounts.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<List<IsarAccount>> getAll({bool includeArchived = false}) async {
    final isar = await _db;
    if (includeArchived) {
      return isar.isarAccounts.where().findAll();
    }
    return isar.isarAccounts.filter().isArchivedEqualTo(false).findAll();
  }

  Stream<List<IsarAccount>> watchAll({bool includeArchived = false}) async* {
    final isar = await _db;
    if (includeArchived) {
      yield* isar.isarAccounts.where().watch(fireImmediately: true);
    } else {
      yield* isar.isarAccounts.filter().isArchivedEqualTo(false).watch(fireImmediately: true);
    }
  }

  Future<bool> archive(String uuid) async {
    final isar = await _db;
    final existing = await isar.isarAccounts
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();

    if (existing != null) {
      existing.isArchived = true;
      existing.updatedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.isarAccounts.put(existing);
      });
      return true;
    }
    return false;
  }

  Future<bool> restore(String uuid) async {
    final isar = await _db;
    final existing = await isar.isarAccounts
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();

    if (existing != null) {
      existing.isArchived = false;
      existing.updatedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.isarAccounts.put(existing);
      });
      return true;
    }
    return false;
  }
}
