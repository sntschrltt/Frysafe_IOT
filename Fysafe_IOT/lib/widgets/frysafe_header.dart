import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';
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
        return HeaderShell(
          s: s,
          child: Stack(
            children: [
              Positioned(
                left: 46 * s,
                top: 51 * s,
                child: Image.asset('assets/images/logo.png',
                    width: 150 * s,
                    height: 150 * s,
                    errorBuilder: (_, __, ___) => Icon(Icons.shield,
                        size: 120 * s, color: AppColors.brandOrange)),
              ),
              Positioned(
                left: 200 * s,
                top: 78 * s,
                child: GestureDetector(
                  onLongPress: svc.reset, // demo only
                  child: Text('FRYSAFE',
                      style: AppText.dmSans(64 * s, weight: FontWeight.w700)),
                ),
              ),
              Positioned(
                left: 198 * s,
                top: 150 * s,
                child: Text(
                    connected
                        ? 'Master Buffalo – Sta. Mesa, Manila'
                        : 'No probe detected.',
                    style: AppText.dmSans(26 * s, color: AppColors.textGray)),
              ),
              Positioned(
                right: 79 * s,
                top: 79 * s,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).push(
                      smoothRoute(const AboutScreen())),
                  child: Icon(Icons.info_outline,
                      size: 85 * s, color: AppColors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
