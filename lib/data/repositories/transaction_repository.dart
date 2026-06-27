import 'package:isar/isar.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final Isar isar;

  TransactionRepository(this.isar);

  Future<void> addTransaction(Transaction txn) async {
    await isar.writeTxn(() async {
      await isar.transactions.put(txn);
    });
  }

  Future<void> updateTransaction(Transaction txn) async {
    await isar.writeTxn(() async {
      await isar.transactions.put(txn);
    });
  }

  Future<void> deleteTransaction(int id) async {
    await isar.writeTxn(() async {
      await isar.transactions.delete(id);
    });
  }

  Future<List<Transaction>> getAllTransactions() async {
    return await isar.transactions.where().sortByDateDesc().findAll();
  }

  Stream<List<Transaction>> watchTransactions() {
    return isar.transactions.where().sortByDateDesc().watch(fireImmediately: true);
  }
}
