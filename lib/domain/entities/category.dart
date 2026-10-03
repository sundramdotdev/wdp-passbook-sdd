import '../enums/personal_enums.dart';

/// Domain entity representing a transaction category.
class Category {
  final String id;
  final String name;
  final CategoryType type;
  final String iconName;
  final String colorHex;
  final bool isDefault;
  final bool isArchived;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorHex,
    this.isDefault = false,
    this.isArchived = false,
  });

  bool get isExpense => type == CategoryType.expense;
  bool get isIncome => type == CategoryType.income;

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? iconName,
    String? colorHex,
    bool? isDefault,
    bool? isArchived,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name, type: $type)';
}
