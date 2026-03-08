import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A horizontally scrollable row of category filter chips.
///
/// Selecting a chip sets the active category filter; tapping the
/// already-selected chip clears the filter (selects "All").
class CategoryFilter extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
              selectedColor: AppConstants.primaryColor.withOpacity(0.15),
              checkmarkColor: AppConstants.primaryColor,
              labelStyle: TextStyle(
                color: selectedCategory == null
                    ? AppConstants.primaryColor
                    : Colors.grey.shade700,
                fontWeight: selectedCategory == null
                    ? FontWeight.w600
                    : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selectedCategory == null
                      ? AppConstants.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),

          // Category chips
          ...AppConstants.categories.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppConstants.categoryIcon(category),
                      size: 14,
                      color: isSelected
                          ? AppConstants.categoryColor(category)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(category),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  if (isSelected) {
                    onCategorySelected(null);
                  } else {
                    onCategorySelected(category);
                  }
                },
                selectedColor:
                    AppConstants.categoryColor(category).withOpacity(0.12),
                checkmarkColor: AppConstants.categoryColor(category),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppConstants.categoryColor(category)
                      : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppConstants.categoryColor(category)
                        : Colors.grey.shade300,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
            );
          }),
        ],
      ),
    );
  }
}
