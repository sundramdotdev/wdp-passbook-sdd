import '../../domain/enums/personal_enums.dart';

/// Command to create a new transaction category.
class CreateCategoryCommand {
  final String name;
  final CategoryType type;
  final String iconName;
  final String colorHex;
  final bool isDefault;

  const CreateCategoryCommand({
    required this.name,
    required this.type,
    this.iconName = 'category',
    this.colorHex = '#10B981',
    this.isDefault = false,
  });
}

/// Command to update an existing category.
class UpdateCategoryCommand {
  final String id;
  final String name;
  final CategoryType type;
  final String iconName;
  final String colorHex;

  const UpdateCategoryCommand({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorHex,
  });
}
