import 'package:isar/isar.dart';

part 'isar_goal.g.dart';

@collection
class IsarGoal {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String title;
  late int targetMinorUnits;
  late int savedMinorUnits;
  DateTime? targetDate;
  late String status; // 'active' | 'achieved' | 'paused' | 'cancelled'
  late String iconName;
}
