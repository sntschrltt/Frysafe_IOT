import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../theme/app_theme.dart';

/// [s] = screen width / 1080 (your design is 1080 px wide),
/// so every size below is the exact pixel value from the design.
class ReadingCard extends StatelessWidget {
  final Reading reading;
  final double s;
  const ReadingCard({super.key, required this.reading, required this.s});

  @override
  Widget build(BuildContext context) {
    final sev = reading.severity;
    return Container(
      height: 181 * s,
      padding: EdgeInsets.only(left: 40 * s, right: 48 * s),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(48 * s),
        border: Border.all(color: AppColors.border, width: 3 * s),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${reading.time} – ${reading.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.arial(35 * s,
                        weight: FontWeight.bold, color: AppColors.textGray)),
                SizedBox(height: 12 * s),
                Text('ODI: ${reading.odi}%',
                    style: AppText.arial(70 * s,
                        weight: FontWeight.bold, color: sev.color)),
              ],
            ),
          ),
          Container(
            width: 170 * s,
            height: 55 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sev.color,
              borderRadius: BorderRadius.circular(10 * s),
            ),
            child: Text(sev.badge,
                style: AppText.dmSans(25 * s,
                    weight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
