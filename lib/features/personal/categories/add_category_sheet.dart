import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/commands/category_commands.dart';
import '../../../application/providers/controller_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/enums/personal_enums.dart';

/// Modal bottom sheet for creating a validated custom category.
class AddCategorySheet extends ConsumerStatefulWidget {
  final CategoryType initialType;

  const AddCategorySheet({
    super.key,
    this.initialType = CategoryType.expense,
  });

  static Future<Category?> show(BuildContext context, {CategoryType initialType = CategoryType.expense}) {
    return showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddCategorySheet(initialType: initialType),
    );
  }

  @override
  ConsumerState<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<AddCategorySheet> {
  final _nameController = TextEditingController();
  late CategoryType _type;
  String _selectedIcon = 'utensils';
  String _selectedColorHex = '#F97316';
  String? _errorMessage;

  static const List<({String iconName, IconData iconData})> _availableIcons = [
    (iconName: 'utensils', iconData: Icons.restaurant),
    (iconName: 'car', iconData: Icons.directions_car),
    (iconName: 'shopping-bag', iconData: Icons.shopping_bag),
    (iconName: 'zap', iconData: Icons.bolt),
    (iconName: 'film', iconData: Icons.movie),
    (iconName: 'heart-pulse', iconData: Icons.favorite),
    (iconName: 'book-open', iconData: Icons.menu_book),
    (iconName: 'plane', iconData: Icons.flight),
    (iconName: 'wallet', iconData: Icons.account_balance_wallet),
    (iconName: 'laptop', iconData: Icons.laptop_mac),
    (iconName: 'briefcase', iconData: Icons.work),
    (iconName: 'gift', iconData: Icons.card_giftcard),
    (iconName: 'trending-up', iconData: Icons.trending_up),
    (iconName: 'grid', iconData: Icons.category),
  ];

  static const List<String> _colorPresets = [
    '#F97316', // Orange
    '#3B82F6', // Blue
    '#10B981', // Emerald
    '#8B5CF6', // Purple
    '#FBBF24', // Amber
    '#EF4444', // Red
    '#06B6D4', // Cyan
    '#EC4899', // Pink
    '#64748B', // Slate
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Category name cannot be empty.');
      return;
    }

    setState(() => _errorMessage = null);

    final command = CreateCategoryCommand(
      name: name,
      type: _type,
      iconName: _selectedIcon,
      colorHex: _selectedColorHex,
    );

    final controller = ref.read(categoryControllerProvider.notifier);
    await controller.createCategory(command);

    if (mounted) {
      final state = ref.read(categoryControllerProvider);
      state.when(
        idle: () {},
        loading: () {},
        success: (category) {
          Navigator.pop(context, category);
        },
        error: (message, _) {
          setState(() => _errorMessage = message);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(categoryControllerProvider);
    final isLoading = state.isLoading;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'New Custom Category',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 16),

              // Category Type Selector
              Row(
                children: [
                  Expanded(
                    child: _buildTypeOption(
                      title: 'Expense',
                      selected: _type == CategoryType.expense,
                      onTap: () => setState(() => _type = CategoryType.expense),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeOption(
                      title: 'Income',
                      selected: _type == CategoryType.income,
                      onTap: () => setState(() => _type = CategoryType.income),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Name Field
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Category Name (e.g. Coffee, Freelance)',
                  border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: AppTypography.caption.copyWith(color: AppColors.semanticError),
                ),
              ],
              const SizedBox(height: 16),

              // Icon Selector
              Text('Icon', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final item = _availableIcons[i];
                    final isSelected = item.iconName == _selectedIcon;
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = item.iconName),
                      borderRadius: AppRadii.controlRadius,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandOrange.withValues(alpha: 0.15)
                              : (isDark ? AppColors.navyElevated : AppColors.lightBg),
                          borderRadius: AppRadii.controlRadius,
                          border: Border.all(
                            color: isSelected ? AppColors.brandOrange : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          item.iconData,
                          size: 22,
                          color: isSelected
                              ? AppColors.brandOrange
                              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Color Preset Selector
              Text('Accent Color', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorPresets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final hex = _colorPresets[i];
                    final isSelected = hex == _selectedColorHex;
                    final color = _parseColor(hex);
                    return InkWell(
                      onTap: () => setState(() => _selectedColorHex = hex),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandOrange,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                  ),
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Save Category',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.controlRadius,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? (title == 'Expense' ? AppColors.brandOrange : AppColors.brandGreen)
              : (isDark ? AppColors.navyElevated : AppColors.lightBg),
          borderRadius: AppRadii.controlRadius,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
