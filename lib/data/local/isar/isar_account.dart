import 'package:isar/isar.dart';

part 'isar_account.g.dart';

@collection
class IsarAccount {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  late String type; // 'cash' | 'bank' | 'wallet' | 'card' | 'other'
  late int balanceMinorUnits;
  String currencyCode = 'INR';
  late String iconName;
  late String colorHex;
  bool isArchived = false;
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
}
