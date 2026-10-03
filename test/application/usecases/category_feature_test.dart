import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/commands/category_commands.dart';
import 'package:wdp_passbook/application/usecases/category_usecases.dart';
import 'package:wdp_passbook/core/errors/failures.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

import '../fakes/fake_repositories.dart';

void main() {
  group('Category Feature & Validation Tests', () {
    late FakeCategoryRepository categoryRepo;
    late CreateCategoryUseCase createCategoryUseCase;
    late UpdateCategoryUseCase updateCategoryUseCase;
    late ArchiveCategoryUseCase archiveCategoryUseCase;
    late GetCategoriesUseCase getCategoriesUseCase;

    setUp(() {
      categoryRepo = FakeCategoryRepository();
      createCategoryUseCase = CreateCategoryUseCase(categoryRepo);
      updateCategoryUseCase = UpdateCategoryUseCase(categoryRepo);
      archiveCategoryUseCase = ArchiveCategoryUseCase(categoryRepo);
      getCategoriesUseCase = GetCategoriesUseCase(categoryRepo);
    });

    test('Creates valid Expense category', () async {
      final res = await createCategoryUseCase(
        const CreateCategoryCommand(
          name: 'Food & Dining',
          type: CategoryType.expense,
          iconName: 'utensils',
          colorHex: '#FF5722',
        ),
      );

      expect(res.isSuccess, isTrue);
      final cat = res.valueOrNull!;
      expect(cat.name, equals('Food & Dining'));
      expect(cat.type, equals(CategoryType.expense));
      expect(cat.iconName, equals('utensils'));
      expect(cat.colorHex, equals('#FF5722'));
      expect(cat.isArchived, isFalse);
    });

    test('Rejects category with empty or whitespace name', () async {
      final res = await createCategoryUseCase(
        const CreateCategoryCommand(
          name: '   ',
          type: CategoryType.expense,
        ),
      );

      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('Rejects duplicate category name within the SAME type (case-insensitive)', () async {
      // 1. Create first category
      final firstRes = await createCategoryUseCase(
        const CreateCategoryCommand(
          name: 'Groceries',
          type: CategoryType.expense,
        ),
      );
      expect(firstRes.isSuccess, isTrue);

      // 2. Attempt duplicate with different casing
      final duplicateRes = await createCategoryUseCase(
        const CreateCategoryCommand(
          name: 'groceries',
          type: CategoryType.expense,
        ),
      );

      expect(duplicateRes.isFailure, isTrue);
      expect(duplicateRes.failureOrNull, isA<DuplicateEntityFailure>());
    });

    test('ALLOWS identical category name across DIFFERENT types (Expense vs Income)', () async {
      // 1. Create 'Other' under Expense
      final expenseRes = await createCategoryUseCase(
        const CreateCategoryCommand(
          name: 'Other',
          type: CategoryType.expense,
        ),
      );
      expect(expenseRes.isSuccess, isTrue);

      // 2. Create 'Other' under Income
      final incomeRes = await createCategoryUseCase(
        const CreateCategoryCommand(
          name: 'Other',
          type: CategoryType.income,
        ),
      );
      expect(incomeRes.isSuccess, isTrue);

      // 3. Verify both exist and are distinct
      final allRes = await getCategoriesUseCase();
      expect(allRes.isSuccess, isTrue);
      final all = allRes.valueOrNull!;
      expect(all.length, equals(2));
      expect(all.where((c) => c.type == CategoryType.expense).length, equals(1));
      expect(all.where((c) => c.type == CategoryType.income).length, equals(1));
    });

    test('Separates Expense and Income categories by type query', () async {
      await createCategoryUseCase(const CreateCategoryCommand(name: 'Food', type: CategoryType.expense));
      await createCategoryUseCase(const CreateCategoryCommand(name: 'Transport', type: CategoryType.expense));
      await createCategoryUseCase(const CreateCategoryCommand(name: 'Salary', type: CategoryType.income));

      final expenseOnly = await getCategoriesUseCase(type: CategoryType.expense);
      expect(expenseOnly.valueOrNull!.length, equals(2));
      expect(expenseOnly.valueOrNull!.every((c) => c.type == CategoryType.expense), isTrue);

      final incomeOnly = await getCategoriesUseCase(type: CategoryType.income);
      expect(incomeOnly.valueOrNull!.length, equals(1));
      expect(incomeOnly.valueOrNull!.first.name, equals('Salary'));
    });

    test('Archives category cleanly without hard deletion', () async {
      final res = await createCategoryUseCase(
        const CreateCategoryCommand(name: 'Subscriptions', type: CategoryType.expense),
      );
      final cat = res.valueOrNull!;

      final archiveRes = await archiveCategoryUseCase(cat.id);
      expect(archiveRes.isSuccess, isTrue);

      // Non-archived query should omit it
      final activeCategories = await getCategoriesUseCase();
      expect(activeCategories.valueOrNull!.isEmpty, isTrue);

      // Archived query should include it
      final allCategories = await getCategoriesUseCase(includeArchived: true);
      expect(allCategories.valueOrNull!.length, equals(1));
      expect(allCategories.valueOrNull!.first.isArchived, isTrue);
    });

    test('Updates existing category successfully', () async {
      final res = await createCategoryUseCase(
        const CreateCategoryCommand(name: 'Food', type: CategoryType.expense),
      );
      final cat = res.valueOrNull!;

      final updateRes = await updateCategoryUseCase(
        UpdateCategoryCommand(
          id: cat.id,
          name: 'Dining Out',
          type: CategoryType.expense,
          iconName: 'utensils',
          colorHex: '#FF5722',
        ),
      );

      expect(updateRes.isSuccess, isTrue);
      final updated = updateRes.valueOrNull!;
      expect(updated.name, equals('Dining Out'));
      expect(updated.iconName, equals('utensils'));
    });
  });
}
