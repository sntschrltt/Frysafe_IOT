import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SensorCard extends StatelessWidget {
  final double s;
  final Widget icon;
  final String label;
  final String? value; // null = "—" (no reading yet)
  final String? unit;
  final double progress; // 0..1
  final Color color;
  const SensorCard({
    super.key,
    required this.s,
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.progress = 0,
    this.color = AppColors.high,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(60 * s),
        border: Border.all(color: AppColors.border, width: 3 * s),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 35 * s,
            top: 33 * s,
            width: 68 * s,
            height: 68 * s,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10 * s),
                border: Border.all(color: AppColors.border, width: 1.5 * s),
              ),
              child: icon,
            ),
          ),
          Positioned(
            left: 121 * s,
            top: 44 * s,
            child: Text(label,
                style: AppText.dmSans(40 * s, weight: FontWeight.w700)),
          ),
          if (value != null)
            Positioned(
              left: 35 * s,
              top: 116 * s,
              child: Text(value!,
                  style: AppText.arial(95 * s, weight: FontWeight.bold)),
            )
          else
            Positioned(
              left: 35 * s,
              top: 169 * s,
              width: 55 * s,
              height: 10 * s,
              child: const ColoredBox(color: AppColors.black),
            ),
          if (unit != null)
            Positioned(
              right: 35 * s,
              top: 170 * s,
              child: Text(unit!,
                  style: AppText.arial(34 * s, weight: FontWeight.bold)),
            ),
          Positioned(
            left: 34 * s,
            right: 34 * s,
            top: 232 * s,
            height: 23 * s,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12 * s),
              child: Stack(
                children: [
                  const Positioned.fill(
                      child: ColoredBox(color: AppColors.border)),
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: ColoredBox(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
