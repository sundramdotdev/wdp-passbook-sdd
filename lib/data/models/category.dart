import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  late String emoji;
  late String colorHex;

  bool isDefault = true;

  List<String> keywords = [];

  late DateTime createdAt;
}
