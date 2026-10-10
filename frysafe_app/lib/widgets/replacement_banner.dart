import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';

/// Floating notice on Home when the latest reading is High or Very High.
/// [s] = screen width / 1080.
class ReplacementBanner extends StatelessWidget {
  final double s;
  final Severity severity;
  final DateTime lastReading;
  const ReplacementBanner({
    super.key,
    required this.s,
    required this.severity,
    required this.lastReading,
  });

  @override
  Widget build(BuildContext context) {
    final color = severity.color;
    final title = severity == Severity.veryHigh
        ? 'Replace Oil Now'
        : 'Replacement Needed Soon';
    const iconSize = 44.0;
    const gap = 18.0;
    return Container(
      height: 130 * s,
      padding: EdgeInsets.symmetric(horizontal: 36 * s),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(36 * s),
        border: Border.all(color: color, width: 3 * s),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_outlined,
                  size: iconSize * s, color: color),
              SizedBox(width: gap * s),
              Text(title,
                  style: AppText.dmSans(34 * s,
                      weight: FontWeight.w700, color: color)),
            ],
          ),
          SizedBox(height: 10 * s),
          Padding(
            padding: EdgeInsets.only(left: (iconSize + gap) * s),
            child: Text('Last reading: ${relativeTime(lastReading)}',
                style: AppText.dmSans(28 * s, color: AppColors.textGray)),
          ),
        ],
      ),
    );
  }
}
