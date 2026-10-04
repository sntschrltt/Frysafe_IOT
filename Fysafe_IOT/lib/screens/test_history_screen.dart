import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../theme/app_theme.dart';
import '../widgets/reading_card.dart';

class TestHistoryScreen extends StatelessWidget {
  const TestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080; // design is 1080 px wide
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Scrollable list (goes under header and nav)
            Positioned.fill(
              child: ListView(
                padding: EdgeInsets.only(top: 258 * s, bottom: 258 * s + 40 * s),
                children: [
                  for (var i = 0; i < mockHistory.length; i++) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          90 * s, i == 0 ? 50 * s : 62 * s, 90 * s, 26 * s),
                      child: Text(mockHistory[i].title,
                          style: AppText.arial(38 * s, weight: FontWeight.bold)),
                    ),
                    for (final r in mockHistory[i].readings)
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(90 * s, 0, 92 * s, 21 * s),
                        child: ReadingCard(reading: r, s: s),
                      ),
                  ],
                ],
              ),
            ),
            // Gray fade above the bottom nav
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 750 * s,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00B4B4B4), Color(0x80B4B4B4), Color(0x80B4B4B4)],
                      stops: [0, 0.656, 1],
                    ),
                  ),
                ),
              ),
            ),
            _Header(s: s),
          ],
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  final double s;
  const _Header({required this.s});

  @override
  Widget build(BuildContext context) {
    // Container is 3px bigger on the sides/top so the border only shows at the bottom.
    return Positioned(
      top: -3 * s,
      left: -3 * s,
      right: -3 * s,
      height: 261 * s,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(70 * s)),
          border: Border.all(color: AppColors.border, width: 3 * s),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 90 * s,
              top: 70 * s,
              child: Text('TEST HISTORY',
                  style: AppText.dmSans(68 * s,
                      weight: FontWeight.w700, letterSpacing: -0.5)),
            ),
            Positioned(
              left: 96 * s,
              top: 146 * s,
              child: Text('All recorded readings',
                  style: AppText.dmSans(28 * s, color: AppColors.textGray)),
            ),
            Positioned(
              right: 72 * s,
              top: 69 * s,
              child: Icon(Icons.file_download_outlined,
                  size: 90 * s, color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
