import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../services/device_service.dart';
import 'smooth_route.dart';
import 'header_shell.dart';

/// Home / Analytics header: logo, FRYSAFE, subtitle, and the (i) About button.
class FrySafeHeader extends StatelessWidget {
  final double s;
  const FrySafeHeader({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final svc = DeviceService.instance;
    return ValueListenableBuilder<HomeStatus>(
      valueListenable: svc.status,
      builder: (context, st, _) {
        final connected = st != HomeStatus.notConnected;
        return AppHeader(
          s: s,
          showLogo: true,
          title: 'FRYSAFE',
          subtitle: connected
              ? 'Master Buffalo – Sta. Mesa, Manila'
              : 'No probe detected.',
          actionIcon: Icons.info_outline,
          onAction: () =>
              Navigator.of(context).push(smoothRoute(const AboutScreen())),
          onTitleLongPress: svc.reset, // demo only
        );
      },
    );
  }
}
