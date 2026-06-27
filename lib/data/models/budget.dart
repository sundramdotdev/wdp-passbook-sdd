import 'package:isar/isar.dart';

part 'budget.g.dart';

@collection
class Budget {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  late double limitAmount;
  late String period; // 'monthly' | 'weekly' | 'custom'

  String? categoryId; // null = overall budget

  @Index()
  late DateTime startDate;
  DateTime? endDate;

  bool isActive = true;
  bool alertAt50 = true;
  bool alertAt80 = true;
  bool alertAt100 = true;

  late DateTime createdAt;
}
