import 'package:isar/isar.dart';
import '../models/udhar_entry.dart';

class UdharRepository {
  final Isar isar;

  UdharRepository(this.isar);

  Future<void> addUdhar(UdharEntry entry) async {
    await isar.writeTxn(() async {
      await isar.udharEntrys.put(entry);
    });
  }

  Future<void> updateUdhar(UdharEntry entry) async {
    await isar.writeTxn(() async {
      await isar.udharEntrys.put(entry);
    });
  }

  Future<void> deleteUdhar(int id) async {
    await isar.writeTxn(() async {
      await isar.udharEntrys.delete(id);
    });
  }

  Stream<List<UdharEntry>> watchUdharEntries() {
    return isar.udharEntrys.where().sortByDateDesc().watch(fireImmediately: true);
  }
}
