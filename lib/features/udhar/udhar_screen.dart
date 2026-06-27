import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/udhar_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/providers/repositories_provider.dart';
import '../../data/models/transaction.dart';
import '../../core/widgets/clay_container.dart';
import 'package:uuid/uuid.dart';

class UdharScreen extends ConsumerWidget {
  const UdharScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Udhar Ledger', style: AppTypography.titleLarge),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'I Gave'),
              Tab(text: 'I Took'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUdharList(ref, true),
            _buildUdharList(ref, false),
          ],
        ),
      ),
    );
  }

  Widget _buildUdharList(WidgetRef ref, bool isGave) {
    final entriesAsync = ref.watch(udharEntriesProvider);

    return entriesAsync.when(
      data: (allEntries) {
        final entries = allEntries.where((e) => e.iGave == isGave).toList();
        if (entries.isEmpty) {
          return const Center(child: Text('No udhar entries here'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClayContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClayContainer(
                      width: 56,
                      height: 56,
                      borderRadius: 16,
                      child: Center(
                        child: Text(isGave ? '📤' : '📥', style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.personName, style: AppTypography.titleMedium),
                          const SizedBox(height: 4),
                          Text(entry.reason, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(entry.amount),
                          style: AppTypography.amountMedium.copyWith(color: AppColors.udhar),
                        ),
                        const SizedBox(height: 12),
                        if (!entry.isSettled)
                          GestureDetector(
                            onTap: () async {
                              final repo = ref.read(udharRepositoryProvider);
                              final txnRepo = ref.read(transactionRepositoryProvider);
                              if (repo != null && txnRepo != null) {
                                entry.isSettled = true;
                                await repo.updateUdhar(entry);
                                
                                final settleTxn = Transaction()
                                  ..uuid = const Uuid().v4()
                                  ..amount = entry.amount
                                  ..isCredit = entry.iGave // if iGave udhar (debit), settling means they pay back (credit)
                                  ..type = 'udhar_settlement'
                                  ..categoryId = 'udhar'
                                  ..merchantId = entry.personName
                                  ..remark = 'Settled Udhar with ${entry.personName}'
                                  ..date = DateTime.now()
                                  ..incomeSource = entry.iGave ? 'friend_return' : ''
                                  ..createdAt = DateTime.now();
                                
                                await txnRepo.addTransaction(settleTxn);
                              }
                            },
                            child: ClayContainer(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              borderRadius: 18,
                              customBackgroundColor: AppColors.primary,
                              child: const Center(
                                child: Text('Settle', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          )
                        else
                          Text('Settled ✓', style: AppTypography.bodySmall.copyWith(color: AppColors.income, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
    );
  }
}
