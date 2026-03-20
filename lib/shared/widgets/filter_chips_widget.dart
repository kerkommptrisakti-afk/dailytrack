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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label kategori
        const Text(
          'KATEGORI',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        // Baris 1 — Kategori pakai Wrap
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
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
            ...AppConstants.defaultCategories.map((cat) {
              final isSelected = selectedCategory == cat;
              return _Chip(
                label: cat,
                isSelected: isSelected,
                color: AppColors.cyanLight,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCategoryChanged(isSelected ? null : cat);
                  onPriorityChanged(null);
                },
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        // Label prioritas
        const Text(
          'PRIORITAS',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        // Baris 2 — Prioritas rata penuh
        Row(
          children: List.generate(4, (i) {
            final isSelected = selectedPriority == i;
            final color = AppColors.forPriority(i);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onPriorityChanged(isSelected ? null : i);
                  onCategoryChanged(null);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : AppColors.glassBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : AppColors.glassBorderSm,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    AppConstants.priorityLabels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? color : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
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
