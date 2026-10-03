import 'package:isar/isar.dart';

part 'isar_budget.g.dart';

@collection
class IsarBudget {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String categoryId;
  late String categoryName;
  late int limitMinorUnits;
  late int spentMinorUnits;
  late String period; // 'monthly' | 'weekly' | 'yearly'
  late DateTime startDate;
  late DateTime endDate;
}

