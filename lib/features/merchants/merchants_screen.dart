import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/merchant.dart';
import '../../data/providers/db_provider.dart';
import '../../core/widgets/clay_container.dart';
import 'add_merchant_sheet.dart';

final merchantsProvider = FutureProvider<List<Merchant>>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return await isar.merchants.where().sortByLastVisitedDesc().findAll();
});

class MerchantsScreen extends ConsumerWidget {
  const MerchantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantsAsync = ref.watch(merchantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Merchants', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (_) => const AddMerchantSheet(),
              );
            },
          ),
        ],
      ),
      body: merchantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (merchants) {
          if (merchants.isEmpty) {
            return Center(child: Text('No merchants found', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
          }

          final recentMerchants = merchants.take(5).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding, vertical: 8),
                child: ClayContainer(
                  borderRadius: 24,
                  isPressed: true,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search merchants...',
                      hintStyle: AppTypography.bodySmall,
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Text('Recently Used', style: AppTypography.titleMedium),
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                  itemCount: recentMerchants.length,
                  itemBuilder: (context, index) {
                    final merchant = recentMerchants[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: _buildMerchantCard(context, merchant),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Text('All Merchants', style: AppTypography.titleMedium),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: merchants.length,
                  itemBuilder: (context, index) {
                    return _buildMerchantCard(context, merchants[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMerchantCard(BuildContext context, Merchant merchant) {
    return GestureDetector(
      onTap: () {
        context.push('/upi_payment', extra: {
          'upiId': merchant.upiId ?? '',
          'merchantName': merchant.name,
        });
      },
      child: ClayContainer(
        width: 110,
        borderRadius: 24,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClayContainer(
              width: 48,
              height: 48,
              borderRadius: 16,
              child: Center(
                child: Icon(Icons.storefront_outlined, color: AppColors.primary, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              merchant.name, 
              style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(merchant.totalSpent), 
              style: AppTypography.amountSmall.copyWith(color: AppColors.expense, fontSize: 11)
            ),
          ],
        ),
      ),
    );
  }
}
