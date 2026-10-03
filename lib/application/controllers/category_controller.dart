import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../commands/category_commands.dart';
import '../state/action_state.dart';
import '../state/error_mapper.dart';
import '../usecases/category_usecases.dart';

/// Presentation-safe controller managing category lifecycle.
class CategoryController extends StateNotifier<ActionState<Category>> {
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final ArchiveCategoryUseCase _archiveCategoryUseCase;

  CategoryController({
    required CreateCategoryUseCase createCategoryUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required ArchiveCategoryUseCase archiveCategoryUseCase,
  })  : _createCategoryUseCase = createCategoryUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _archiveCategoryUseCase = archiveCategoryUseCase,
        super(const ActionState.idle());

  void reset() => state = const ActionState.idle();

  Future<bool> createCategory(CreateCategoryCommand command) async {
    state = const ActionState.loading();
    final result = await _createCategoryUseCase(command);
    return result.fold(
      (category) {
        state = ActionState.success(category);
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }

  Future<bool> updateCategory(UpdateCategoryCommand command) async {
    state = const ActionState.loading();
    final result = await _updateCategoryUseCase(command);
    return result.fold(
      (category) {
        state = ActionState.success(category);
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }

  Future<bool> archiveCategory(String id) async {
    state = const ActionState.loading();
    final result = await _archiveCategoryUseCase(id);
    return result.fold(
      (_) {
        state = const ActionState.idle();
        return true;
      },
      (failure) {
        final message = ErrorMapper.mapFailureToMessage(failure);
        state = ActionState.error(message, failure: failure);
        return false;
      },
    );
  }
}
