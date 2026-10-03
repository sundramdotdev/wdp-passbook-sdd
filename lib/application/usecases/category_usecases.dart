import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/enums/personal_enums.dart';
import '../../domain/repositories/personal_repositories.dart';
import '../commands/category_commands.dart';

/// Orchestrates creation of a transaction category.
class CreateCategoryUseCase {
  final CategoryRepository repository;

  const CreateCategoryUseCase(this.repository);

  Future<Result<Category>> call(CreateCategoryCommand command) async {
    final trimmedName = command.name.trim();
    if (trimmedName.isEmpty) {
      return Result.failure(const ValidationFailure('Category name cannot be empty.'));
    }

    // Check for duplicate category name within the same type
    final existingRes = await repository.getCategories(type: command.type, includeArchived: true);
    if (existingRes.isSuccess) {
      final duplicates = existingRes.valueOrNull!.where(
        (c) => c.name.trim().toLowerCase() == trimmedName.toLowerCase(),
      );
      if (duplicates.isNotEmpty) {
        return Result.failure(DuplicateEntityFailure(
          'A category named "$trimmedName" already exists for ${command.type == CategoryType.expense ? "Expense" : "Income"}.',
        ));
      }
    }

    final category = Category(
      id: const Uuid().v4(),
      name: trimmedName,
      type: command.type,
      iconName: command.iconName,
      colorHex: command.colorHex,
      isDefault: command.isDefault,
      isArchived: false,
    );

    return repository.createCategory(category);
  }
}

/// Orchestrates updating an existing category's metadata.
class UpdateCategoryUseCase {
  final CategoryRepository repository;

  const UpdateCategoryUseCase(this.repository);

  Future<Result<Category>> call(UpdateCategoryCommand command) async {
    final trimmedName = command.name.trim();
    if (command.id.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Category ID cannot be empty.'));
    }
    if (trimmedName.isEmpty) {
      return Result.failure(const ValidationFailure('Category name cannot be empty.'));
    }

    final existingRes = await repository.getCategoryById(command.id);
    if (existingRes.isFailure) return Result.failure(existingRes.failureOrNull!);
    final existing = existingRes.valueOrNull;
    if (existing == null) {
      return Result.failure(NotFoundFailure('Category with ID ${command.id} not found.'));
    }

    // Check for duplicate category name within the same type (excluding this category)
    final allOfTypeRes = await repository.getCategories(type: command.type, includeArchived: true);
    if (allOfTypeRes.isSuccess) {
      final duplicates = allOfTypeRes.valueOrNull!.where(
        (c) => c.id != command.id && c.name.trim().toLowerCase() == trimmedName.toLowerCase(),
      );
      if (duplicates.isNotEmpty) {
        return Result.failure(DuplicateEntityFailure(
          'A category named "$trimmedName" already exists for ${command.type == CategoryType.expense ? "Expense" : "Income"}.',
        ));
      }
    }

    final updated = existing.copyWith(
      name: trimmedName,
      type: command.type,
      iconName: command.iconName,
      colorHex: command.colorHex,
    );

    return repository.updateCategory(updated);
  }
}

/// Archives a category, hiding it from default selection lists.
class ArchiveCategoryUseCase {
  final CategoryRepository repository;

  const ArchiveCategoryUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Category ID cannot be empty.'));
    }
    return repository.archiveCategory(id);
  }
}

/// Retrieves categories filtered by type and archive status.
class GetCategoriesUseCase {
  final CategoryRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<Result<List<Category>>> call({
    CategoryType? type,
    bool includeArchived = false,
  }) {
    return repository.getCategories(
      type: type,
      includeArchived: includeArchived,
    );
  }
}
