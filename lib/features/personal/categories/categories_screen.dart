import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/controller_providers.dart';
import '../../../application/providers/reactive_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../core/widgets/wdp_badge.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/enums/personal_enums.dart';
import 'add_category_sheet.dart';

/// Full Category Management screen for Expense & Income classifications.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'utensils':
        return Icons.restaurant;
      case 'car':
        return Icons.directions_car;
      case 'shopping-bag':
      case 'cart':
        return Icons.shopping_bag;
      case 'zap':
        return Icons.bolt;
      case 'film':
        return Icons.movie;
      case 'heart-pulse':
        return Icons.favorite;
      case 'book-open':
        return Icons.menu_book;
      case 'plane':
        return Icons.flight;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'laptop':
        return Icons.laptop_mac;
      case 'briefcase':
        return Icons.work;
      case 'gift':
        return Icons.card_giftcard;
      case 'trending-up':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.brandOrange;
    }
  }

  void _openAddCategory(CategoryType type) {
    AddCategorySheet.show(context, initialType: type);
  }

  void _editCategory(Category category) {
    AddCategorySheet.show(
      context,
      initialType: category.type,
      categoryToEdit: category,
    );
  }

  Future<void> _archiveCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Category?'),
        content: Text(
          'Archiving "${category.name}" will hide it from future transactions while preserving existing ledger history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Archive', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref
          .read(categoryControllerProvider.notifier)
          .archiveCategory(category.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category "${category.name}" archived.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseCategoriesAsync = ref.watch(expenseCategoriesStreamProvider);
    final incomeCategoriesAsync = ref.watch(incomeCategoriesStreamProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Categories',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.brandOrange,
          unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          indicatorColor: AppColors.brandOrange,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brandOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          final currentType = _tabController.index == 0 ? CategoryType.expense : CategoryType.income;
          _openAddCategory(currentType);
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(
            asyncCategories: expenseCategoriesAsync,
            type: CategoryType.expense,
            isDark: isDark,
          ),
          _buildCategoryList(
            asyncCategories: incomeCategoriesAsync,
            type: CategoryType.income,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList({
    required AsyncValue<List<Category>> asyncCategories,
    required CategoryType type,
    required bool isDark,
  }) {
    return asyncCategories.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type == CategoryType.expense ? Icons.receipt_long_outlined : Icons.monetization_on_outlined,
                    size: 56,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${type == CategoryType.expense ? "Expense" : "Income"} categories yet',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first custom category to organize your financial records.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandOrange,
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Create Category', style: TextStyle(color: Colors.white)),
                    onPressed: () => _openAddCategory(type),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: 80,
          ),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final color = _parseColor(cat.colorHex);

            return ClayContainer(
              borderRadius: AppRadii.card,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_resolveIcon(cat.iconName), color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                cat.name,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (cat.isDefault) ...[
                              const SizedBox(width: 8),
                              const WdpBadge(
                                text: 'Default',
                                variant: WdpBadgeVariant.neutral,
                              ),
                            ],
                            if (cat.isArchived) ...[
                              const SizedBox(width: 8),
                              const WdpBadge(
                                text: 'Archived',
                                variant: WdpBadgeVariant.warning,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          type == CategoryType.expense ? 'Expense Category' : 'Income Category',
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editCategory(cat);
                      } else if (value == 'archive') {
                        _archiveCategory(cat);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      if (!cat.isArchived)
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 20, color: AppColors.expense),
                              SizedBox(width: 10),
                              Text('Archive', style: TextStyle(color: AppColors.expense)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error loading categories: $e', style: AppTypography.bodyMedium),
      ),
    );
  }
}
