import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class FilterChipsWidget extends StatelessWidget {
  final String? selectedCategory;
  final int? selectedPriority;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<int?> onPriorityChanged;

  const FilterChipsWidget({
    super.key,
    this.selectedCategory,
    this.selectedPriority,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All filter
          _Chip(
            label: 'Semua',
            isSelected: selectedCategory == null && selectedPriority == null,
            color: AppColors.violetLight,
            onTap: () {
              HapticFeedback.lightImpact();
              onCategoryChanged(null);
              onPriorityChanged(null);
            },
          ),
          const SizedBox(width: 8),
          // Category filters
          ...AppConstants.defaultCategories.map((cat) {
            final isSelected = selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: cat,
                isSelected: isSelected,
                color: AppColors.cyanLight,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCategoryChanged(isSelected ? null : cat);
                  onPriorityChanged(null);
                },
              ),
            );
          }),
          // Priority filters
          ...List.generate(4, (i) {
            final isSelected = selectedPriority == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: AppConstants.priorityLabels[i],
                isSelected: isSelected,
                color: AppColors.forPriority(i),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onPriorityChanged(isSelected ? null : i);
                  onCategoryChanged(null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.glassBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorderSm,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
