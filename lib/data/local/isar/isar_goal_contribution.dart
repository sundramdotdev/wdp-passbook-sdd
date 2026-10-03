import 'package:isar/isar.dart';

part 'isar_goal_contribution.g.dart';

@collection
class IsarGoalContribution {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String goalUuid;

  late int amountMinorUnits;
  late DateTime date;
  late String note;
}

