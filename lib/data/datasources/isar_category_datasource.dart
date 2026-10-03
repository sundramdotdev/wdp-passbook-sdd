import 'package:isar/isar.dart';
import '../local/isar/isar_category.dart';

/// Data source performing local Isar persistence operations for Categories.
class IsarCategoryDataSource {
  final Future<Isar> _db;

  IsarCategoryDataSource(this._db);

  Future<IsarCategory> create(IsarCategory category) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.isarCategorys.put(category);
    });
    return category;
  }

  Future<IsarCategory> update(IsarCategory category) async {
    final isar = await _db;
    final existing = await isar.isarCategorys
        .filter()
        .uuidEqualTo(category.uuid)
        .findFirst();

    if (existing != null) {
      category.id = existing.id;
    }

    await isar.writeTxn(() async {
      await isar.isarCategorys.put(category);
    });
    return category;
  }

  Future<IsarCategory?> getById(String uuid) async {
    final isar = await _db;
    return isar.isarCategorys.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<List<IsarCategory>> getAll({
    String? type,
    bool includeArchived = false,
  }) async {
    final isar = await _db;
    QueryBuilder<IsarCategory, IsarCategory, QAfterFilterCondition>? query;

    QueryBuilder<IsarCategory, IsarCategory, QAfterFilterCondition> add(
      QueryBuilder<IsarCategory, IsarCategory, QAfterFilterCondition> Function(
        QueryBuilder<IsarCategory, IsarCategory, QFilterCondition> q,
      ) filter,
    ) {
      final current = query;
      if (current == null) {
        return query = filter(isar.isarCategorys.filter());
      } else {
        return query = filter(current);
      }
    }

    if (!includeArchived) {
      add((q) => q.isArchivedEqualTo(false));
    }
    if (type != null && type.isNotEmpty) {
      add((q) => q.typeEqualTo(type));
    }

    if (query != null) {
      return query!.findAll();
    } else {
      return isar.isarCategorys.where().findAll();
    }
  }

  Stream<List<IsarCategory>> watchAll({
    String? type,
    bool includeArchived = false,
  }) async* {
    final isar = await _db;
    QueryBuilder<IsarCategory, IsarCategory, QAfterFilterCondition>? query;

    QueryBuilder<IsarCategory, IsarCategory, QAfterFilterCondition> add(
      QueryBuilder<IsarCategory, IsarCategory, QAfterFilterCondition> Function(
        QueryBuilder<IsarCategory, IsarCategory, QFilterCondition> q,
      ) filter,
    ) {
      final current = query;
      if (current == null) {
        return query = filter(isar.isarCategorys.filter());
      } else {
        return query = filter(current);
      }
    }

    if (!includeArchived) {
      add((q) => q.isArchivedEqualTo(false));
    }
    if (type != null && type.isNotEmpty) {
      add((q) => q.typeEqualTo(type));
    }

    if (query != null) {
      yield* query!.watch(fireImmediately: true);
    } else {
      yield* isar.isarCategorys.where().watch(fireImmediately: true);
    }
  }

  Future<bool> archive(String uuid) async {
    final isar = await _db;
    final existing = await isar.isarCategorys
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();

    if (existing != null) {
      existing.isArchived = true;
      await isar.writeTxn(() async {
        await isar.isarCategorys.put(existing);
      });
      return true;
    }
    return false;
  }
}
