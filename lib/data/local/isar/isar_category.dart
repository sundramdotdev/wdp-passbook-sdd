import 'package:isar/isar.dart';

part 'isar_category.g.dart';

@collection
class IsarCategory {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  late String type; // 'expense' | 'income'
  late String iconName;
  late String colorHex;
  bool isDefault = false;
  bool isArchived = false;
}
