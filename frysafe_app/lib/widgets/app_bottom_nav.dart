import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Use inside a Stack. [s] = screen width / 1080.
/// Height comes from [AppLayout.navHeight] (change it there).
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

  static const _iconTop = 34.0;
  static const _iconSize = 96.0;

  Widget _item(double cx, int index, IconData icon, String label) {
    final color = current == index ? AppColors.black : AppColors.inactive;
    return Positioned(
      left: (cx - 90) * s,
      width: 180 * s,
      top: _iconTop * s,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(index),
        child: Column(
          children: [
            Icon(icon, size: _iconSize * s, color: color),
            SizedBox(height: 2 * s),
            Text(label, style: AppText.arial(30 * s, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const ring = 112.0;
    const inner = 92.0;
    // + button: centered in the bar (6 = the 3px border on top and bottom)
    const ringTop = (AppLayout.navHeight - 6 - ring) / 2;
    return Positioned(
      bottom: -3 * s,
      left: -3 * s,
      right: -3 * s,
      height: AppLayout.navHeight * s,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(80 * s)),
          border: Border.all(color: AppColors.border, width: 3 * s),
        ),
        child: Stack(
          children: [
            _item(152, 0, Icons.home_outlined, 'Home'),
            _item(336, 1, Icons.schedule, 'History'),
            _item(744, 2, Icons.notifications_none, 'Alerts'),
            _item(928, 3, Icons.bar_chart, 'Analytics'),
            Positioned(
              left: (540 - ring / 2) * s,
              top: ringTop * s,
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: ring * s,
                  height: ring * s,
                  decoration: const BoxDecoration(
                      color: AppColors.fabRing, shape: BoxShape.circle),
                  child: Center(
                    child: Container(
                      width: inner * s,
                      height: inner * s,
                      decoration: const BoxDecoration(
                          color: AppColors.brandOrange, shape: BoxShape.circle),
                      child: Icon(Icons.add,
                          size: 68 * s, color: AppColors.textGray),
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
