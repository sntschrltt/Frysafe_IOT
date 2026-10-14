import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../models/rul.dart';
import '../theme/app_theme.dart';

/// "Remaining Useful Life" card shown on Home under the ODI hero card.
/// [s] = screen width / 1080. Give it a height of about 205 * s.
class RulCard extends StatelessWidget {
  final double s;
  final int odi;

  /// Optional: ODI rise per frying cycle from real history (see rul.dart).
  final double? odiPerCycle;
  const RulCard({super.key, required this.s, required this.odi, this.odiPerCycle});

  @override
  Widget build(BuildContext context) {
    final est = estimateRul(odi, odiPerCycle: odiPerCycle);
    final color = severityFromOdi(odi).color;
    final progress = (odi / kOdiReplaceLimit).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(50 * s),
        border: Border.all(color: color, width: 3 * s),
      ),
      child: Stack(children: [
        // icon
        Positioned(
          left: 40 * s,
          top: 26 * s,
          width: 70 * s,
          height: 70 * s,
          child: Container(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(Icons.hourglass_bottom, size: 40 * s, color: Colors.white),
          ),
        ),
        // title + headline
        Positioned(
          left: 128 * s,
          top: 28 * s,
          child: Text('REMAINING USEFUL LIFE',
              style: AppText.dmSans(26 * s,
                  weight: FontWeight.w700, color: AppColors.textGray)),
        ),
        Positioned(
          left: 128 * s,
          top: 64 * s,
          child: Text(est.headline,
              style: AppText.dmSans(44 * s, weight: FontWeight.w700, color: color)),
        ),
        // ESTIMATED tag
        Positioned(
          right: 40 * s,
          top: 24 * s,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 9 * s),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(30 * s),
              border: Border.all(color: AppColors.border, width: 2 * s),
            ),
            child: Text('ESTIMATED',
                style: AppText.dmSans(18 * s,
                    weight: FontWeight.w700, color: AppColors.textGray)),
          ),
        ),
        // progress toward the replace limit
        Positioned(
          left: 48 * s,
          right: 48 * s,
          top: 130 * s,
          height: 18 * s,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9 * s),
            child: Stack(children: [
              const Positioned.fill(child: ColoredBox(color: AppColors.border)),
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: ColoredBox(color: color),
                ),
              ),
            ]),
          ),
        ),
        // footer line
        Positioned(
          left: 48 * s,
          right: 48 * s,
          top: 160 * s,
          child: Row(children: [
            Expanded(
              child: Text(
                  est.replaceNow
                      ? 'ODI is at or above the $kOdiReplaceLimit limit'
                      : 'Replace before ODI hits $kOdiReplaceLimit% (VERY HIGH)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.dmSans(21 * s, color: AppColors.textGray)),
            ),
            SizedBox(width: 12 * s),
            Text('ODI $odi / $kOdiReplaceLimit',
                style: AppText.dmSans(21 * s, weight: FontWeight.w700, color: color)),
          ]),
        ),
      ]),
    );
  }
}
