import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/personal_repository_impls.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/services/isar_service.dart';
import '../../domain/repositories/personal_repositories.dart';
import '../../domain/repositories/transaction_repository.dart';

export 'controller_providers.dart';
export 'reactive_providers.dart';
export 'usecase_providers.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return IsarTransactionRepository(ref.watch(isarServiceProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return IsarAccountRepository(ref.watch(isarServiceProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return IsarCategoryRepository(ref.watch(isarServiceProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return IsarBudgetRepository(ref.watch(isarServiceProvider));
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return IsarGoalRepository(ref.watch(isarServiceProvider));
});

