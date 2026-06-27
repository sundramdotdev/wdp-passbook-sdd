import 'package:isar/isar.dart';

part 'merchant.g.dart';

@collection
class Merchant {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  String? upiId; // UPI payment address
  String? phone; // Phone number (optional UPI pay)
  late String categoryId;
  String? emoji; // Quick visual identifier
  String? customColor; // Optional card color override

  double totalSpent = 0.0;
  int visitCount = 0;

  @Index()
  DateTime? lastVisited;

  late DateTime createdAt;
}
