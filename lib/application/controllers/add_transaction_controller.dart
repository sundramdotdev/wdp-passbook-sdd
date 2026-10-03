import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/money.dart';
import '../../domain/enums/personal_enums.dart';
import '../../domain/usecases/personal_usecases.dart';
import '../providers/repository_providers.dart';

sealed class TransactionSubmissionState {
  const TransactionSubmissionState();
}

class TransactionIdleState extends TransactionSubmissionState {
  const TransactionIdleState();
}

class TransactionLoadingState extends TransactionSubmissionState {
  const TransactionLoadingState();
}

class TransactionSuccessState extends TransactionSubmissionState {
  const TransactionSuccessState();
}

class TransactionErrorState extends TransactionSubmissionState {
  final String message;
  const TransactionErrorState(this.message);
}

class AddTransactionController extends StateNotifier<TransactionSubmissionState> {
  final Ref ref;

  AddTransactionController(this.ref) : super(const TransactionIdleState());

  Future<bool> submitExpense({
    required Money amount,
    required String categoryId,
    required String categoryName,
    required String accountId,
    required String accountName,
    required String remark,
    required PaymentMethod paymentMethod,
    required DateTime date,
  }) async {
    state = const TransactionLoadingState();
    final useCase = CreateExpenseUseCase(ref.read(transactionRepositoryProvider));
    final result = await useCase.call(
      amount: amount,
      categoryId: categoryId,
      categoryName: categoryName,
      accountId: accountId,
      accountName: accountName,
      remark: remark,
      paymentMethod: paymentMethod,
      date: date,
    );

    return result.fold(
      (tx) {
        state = const TransactionSuccessState();
        return true;
      },
      (failure) {
        state = TransactionErrorState(failure.message);
        return false;
      },
    );
  }

  Future<bool> submitIncome({
    required Money amount,
    required String categoryId,
    required String categoryName,
    required String accountId,
    required String accountName,
    required String remark,
    required PaymentMethod paymentMethod,
    required DateTime date,
  }) async {
    state = const TransactionLoadingState();
    final useCase = CreateIncomeUseCase(ref.read(transactionRepositoryProvider));
    final result = await useCase.call(
      amount: amount,
      categoryId: categoryId,
      categoryName: categoryName,
      accountId: accountId,
      accountName: accountName,
      remark: remark,
      paymentMethod: paymentMethod,
      date: date,
    );

    return result.fold(
      (tx) {
        state = const TransactionSuccessState();
        return true;
      },
      (failure) {
        state = TransactionErrorState(failure.message);
        return false;
      },
    );
  }

  Future<bool> submitTransfer({
    required Money amount,
    required String sourceAccountId,
    required String sourceAccountName,
    required String targetAccountId,
    required String targetAccountName,
    required String remark,
    required DateTime date,
  }) async {
    state = const TransactionLoadingState();
    final useCase = CreateTransferUseCase(ref.read(transactionRepositoryProvider));
    final result = await useCase.call(
      amount: amount,
      sourceAccountId: sourceAccountId,
      sourceAccountName: sourceAccountName,
      targetAccountId: targetAccountId,
      targetAccountName: targetAccountName,
      remark: remark,
      date: date,
    );

    return result.fold(
      (tx) {
        state = const TransactionSuccessState();
        return true;
      },
      (failure) {
        state = TransactionErrorState(failure.message);
        return false;
      },
    );
  }
}

final addTransactionControllerProvider = StateNotifierProvider<AddTransactionController, TransactionSubmissionState>((ref) {
  return AddTransactionController(ref);
});

