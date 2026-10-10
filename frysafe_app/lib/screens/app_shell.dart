import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import 'add_device_screen.dart';
import 'alerts_screen.dart';
import 'analytics_screen.dart';
import 'home_screen.dart';
import 'test_history_screen.dart';

/// Holds the bottom nav shared by Home / History / Alerts / About.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false, // keyboard must not push the nav up
        body: ValueListenableBuilder<int>(
          valueListenable: appTab,
          builder: (context, i, _) => Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: i,
                  children: const [
                    HomeScreen(),
                    TestHistoryScreen(),
                    AlertsScreen(),
                    AnalyticsScreen(),
                  ],
                ),
              ),
              AppBottomNav(
                s: s,
                current: i,
                onSelect: (v) => appTab.value = v,
                onAdd: () => openAddDevice(context),
              ),
            ],
          ),
        ),
      );
    });
  }
}
