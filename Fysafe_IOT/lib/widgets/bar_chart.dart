import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Simple bar chart (no package). Sizes are design px, scaled by [s].
class SimpleBarChart extends StatelessWidget {
  final double s;
  final List<String> labels;
  final List<double> values;
  final String Function(double) valueText;
  final bool highlightMax; // true: only the tallest bar is orange
  final double plotHeight;
  const SimpleBarChart({
    super.key,
    required this.s,
    required this.labels,
    required this.values,
    required this.valueText,
    required this.plotHeight,
    this.highlightMax = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxV = values.reduce(math.max);
    final maxBar = plotHeight - 45;
    final hiIndex = values.indexOf(maxV);
    Widget over(Widget w, double h) => SizedBox(
        height: h * s,
        child: OverflowBox(maxWidth: 240 * s, maxHeight: h * s, child: w));
    return Column(children: [
      SizedBox(
        height: plotHeight * s,
        child: Stack(children: [
          for (var i = 1; i <= 3; i++)
            Positioned(
              left: 0,
              right: 0,
              bottom: maxBar * s * i / 3,
              height: 2 * s,
              child: const ColoredBox(color: Color(0xFFEAE8DC)),
            ),
          Positioned.fill(
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8 * s),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      over(
                          Text(valueText(values[i]),
                              softWrap: false,
                              style: AppText.dmSans(28 * s,
                                  weight: FontWeight.w700,
                                  color: AppColors.textGray)),
                          36),
                      SizedBox(height: 9 * s),
                      Container(
                        height: values[i] / maxV * maxBar * s,
                        decoration: BoxDecoration(
                          color: (!highlightMax || i == hiIndex)
                              ? AppColors.brandOrange
                              : const Color(0xFFE3E1CB),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12 * s)),
                        ),
                      ),
                    ]),
                  ),
                ),
            ]),
          ),
        ]),
      ),
      SizedBox(height: 8 * s),
      Row(children: [
        for (final l in labels)
          Expanded(
            child: over(
                Text(l,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: AppText.arial(24 * s)),
                30),
          ),
      ]),
    ]);
  }
}
