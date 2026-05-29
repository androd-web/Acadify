import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomBottomNavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  CustomBottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class CustomNavigationBar extends StatelessWidget {
  final List<CustomBottomNavItem> items;
  final int currentIndex;

  const CustomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == currentIndex;

            return _buildNavItem(context, item, isActive);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, CustomBottomNavItem item, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isActive 
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10) 
            : const EdgeInsets.all(12),
        decoration: isActive 
            ? BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ) 
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
