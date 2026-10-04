import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Use inside a Stack. [s] = screen width / 1080.
class AppBottomNav extends StatelessWidget {
  final double s;
  final int current; // 0 Home, 1 History, 2 Alerts, 3 Analytics
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  const AppBottomNav(
      {super.key,
      required this.s,
      required this.current,
      required this.onSelect,
      required this.onAdd});

  Widget _item(double cx, int index, IconData icon, String label) {
    final color = current == index ? AppColors.black : AppColors.inactive;
    return Positioned(
      left: (cx - 90) * s,
      width: 180 * s,
      top: 60 * s,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(index),
        child: Column(
          children: [
            Icon(icon, size: 120 * s, color: color),
            SizedBox(height: 2 * s),
            Text(label, style: AppText.arial(34 * s, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -3 * s,
      left: -3 * s,
      right: -3 * s,
      height: 261 * s,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(95 * s)),
          border: Border.all(color: AppColors.border, width: 3 * s),
        ),
        child: Stack(
          children: [
            _item(152, 0, Icons.home_outlined, 'Home'),
            _item(336, 1, Icons.schedule, 'History'),
            _item(740, 2, Icons.notifications_none, 'Alerts'),
            _item(922, 3, Icons.bar_chart, 'Analytics'),
            Positioned(
              left: (542 - 66) * s,
              top: 60 * s,
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 132 * s,
                  height: 132 * s,
                  decoration: const BoxDecoration(
                      color: AppColors.fabRing, shape: BoxShape.circle),
                  child: Center(
                    child: Container(
                      width: 108 * s,
                      height: 108 * s,
                      decoration: const BoxDecoration(
                          color: AppColors.brandOrange, shape: BoxShape.circle),
                      child: Icon(Icons.add,
                          size: 80 * s, color: AppColors.textGray),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
