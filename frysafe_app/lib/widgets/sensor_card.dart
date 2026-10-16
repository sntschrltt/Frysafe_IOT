import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// One row inside a card: optional color box + number + small gray unit.
class SensorLine {
  final Color? swatch; // little color square before the number
  final String? value; // null = no reading yet (shows the dash)
  final String? unit;
  const SensorLine({this.swatch, required this.value, this.unit});
}

/// Home sensor tile. Shows either one big [value] (+ small [unit] beside it)
/// or several [lines] (e.g. the R / G / B frequencies). Both are centered.
/// A null value (no reading yet) shows a dash with the unit beside it.
class SensorCard extends StatelessWidget {
  final double s;
  final Widget icon;
  final String label;
  final String? value;
  final String? unit;
  final List<SensorLine>? lines;
  const SensorCard({
    super.key,
    required this.s,
    required this.icon,
    required this.label,
    this.value,
    this.unit,
    this.lines,
  });

  Widget _number(String? v, String? u, double size, double unitSize) {
    final unitStyle = AppText.arial(unitSize * s,
        weight: FontWeight.bold, color: AppColors.textGray);
    if (v == null) {
      // No reading yet: black dash + unit. Flutter's baseline alignment does
      // not work for a plain box, so we measure the unit text ourselves:
      // "descent" = space under the letters' baseline. Lifting the dash by
      // exactly that much puts its bottom edge level with the bottom of
      // "Hz" / "mV".
      final tp = TextPainter(
        text: TextSpan(text: u ?? '', style: unitStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final descent =
          tp.height - tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: descent),
            child: Container(
                width: 55 * s, height: 10 * s, color: AppColors.black),
          ),
          if (u != null) ...[
            SizedBox(width: 8 * s),
            Text(u, style: unitStyle),
          ],
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(v, style: AppText.arial(size * s, weight: FontWeight.bold)),
        if (u != null) ...[
          SizedBox(width: 8 * s),
          Text(u, style: unitStyle),
        ],
      ],
    );
  }

  Widget _body() {
    if (lines != null) {
      // the block is centered; boxes stay lined up on the left
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final l in lines!)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5 * s),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (l.swatch != null) ...[
                    Container(
                      width: 34 * s,
                      height: 34 * s,
                      decoration: BoxDecoration(
                        color: l.swatch,
                        borderRadius: BorderRadius.circular(7 * s),
                      ),
                    ),
                    SizedBox(width: 20 * s),
                  ],
                  _number(l.value, l.unit, 38, 28),
                ]),
              ),
          ],
        ),
      );
    }
    return FittedBox(fit: BoxFit.scaleDown, child: _number(value, unit, 95, 40));
  }

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
          // value area: everything under the title row (no progress bar anymore)
          Positioned(
            left: 35 * s,
            right: 35 * s,
            top: 118 * s,
            bottom: 24 * s,
            child: Center(child: _body()),
          ),
        ],
      ),
    );
  }
}
