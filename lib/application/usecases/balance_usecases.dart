import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/money.dart';
import '../../domain/repositories/personal_repositories.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Derives total portfolio balance across all active accounts.
class GetTotalBalanceUseCase {
  final AccountRepository accountRepository;

  const GetTotalBalanceUseCase(this.accountRepository);

  Future<Result<Money>> call({String currencyCode = 'INR'}) async {
    final accountsResult = await accountRepository.getAccounts(includeArchived: false);
    return accountsResult.fold(
      (accounts) {
        int totalMinor = 0;
        for (final acc in accounts) {
          if (acc.currencyCode == currencyCode) {
            totalMinor += acc.balance.minorUnits;
          }
        }
        return Result.success(Money(minorUnits: totalMinor, currencyCode: currencyCode));
      },
      (failure) => Result.failure(failure),
    );
  }
}

/// Derives account balance strictly from transaction ledger history.
class GetAccountBalanceUseCase {
  final TransactionRepository transactionRepository;

  const GetAccountBalanceUseCase(this.transactionRepository);

  Future<Result<Money>> call(String accountId) async {
    if (accountId.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Account ID cannot be empty.'));
    }
    return transactionRepository.calculateAccountBalance(accountId);
  }
}
