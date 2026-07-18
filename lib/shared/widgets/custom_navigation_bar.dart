import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomBottomNavItem {
  final IconData icon;
  final String label;

  CustomBottomNavItem({
    required this.icon,
    required this.label,
  });
}

class CustomNavigationBar extends StatefulWidget {
  final List<CustomBottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(CustomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: NavBarPainter(
              selectedIndex: _animation.value,
              itemCount: widget.items.length,
              color: colorScheme.surfaceContainer,
              borderColor: colorScheme.onSurface.withValues(alpha: 0.1),
              dotColor: AppColors.primary,
            ),
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == widget.currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12), // Space for the "hole"
                          Icon(
                            item.icon,
                            color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  final double selectedIndex;
  final int itemCount;
  final Color color;
  final Color borderColor;
  final Color dotColor;

  NavBarPainter({
    required this.selectedIndex,
    required this.itemCount,
    required this.color,
    required this.borderColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final double itemWidth = size.width / itemCount;
    final double centerX = (selectedIndex * itemWidth) + (itemWidth / 2);

    const double holeWidth = 60;
    const double holeDepth = 12;
    const double borderRadius = 20;

    // Draw the main body with a "hole" (concave curve) at the selected index
    path.moveTo(borderRadius, 0);
    
    // Top edge with the hole
    path.lineTo(centerX - holeWidth / 2, 0);
    
    // Concave curve (The "Hole")
    path.cubicTo(
      centerX - holeWidth / 3, 0,
      centerX - holeWidth / 4, holeDepth,
      centerX, holeDepth,
    );
    path.cubicTo(
      centerX + holeWidth / 4, holeDepth,
      centerX + holeWidth / 3, 0,
      centerX + holeWidth / 2, 0,
    );
    
    path.lineTo(size.width - borderRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);
    path.lineTo(size.width, size.height - borderRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - borderRadius, size.height);
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);

    // Add shadow
    canvas.drawShadow(path.shift(const Offset(0, 4)), Colors.black.withValues(alpha: 0.3), 12, true);
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Draw the indicator dot in the "hole"
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    
    // The dot is placed inside the concave area
    canvas.drawCircle(Offset(centerX, holeDepth / 2), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(NavBarPainter oldDelegate) => 
    oldDelegate.selectedIndex != selectedIndex || oldDelegate.color != color;
}
