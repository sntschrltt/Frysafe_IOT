import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../theme/app_theme.dart';
import '../widgets/header_shell.dart';
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
                padding: EdgeInsets.only(
                    top: AppLayout.headerHeight * s,
                    bottom: AppLayout.navClearance * s),
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
            AppHeader(
              s: s,
              title: 'TEST HISTORY',
              subtitle: 'All recorded readings',
              actionIcon: Icons.file_download_outlined,
            ),
          ],
        ),
      );
    });
  }
}
