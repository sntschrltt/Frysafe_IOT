import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rounded header with bottom border. Use inside a Stack.
class HeaderShell extends StatelessWidget {
  final double s;
  final Widget child;
  const HeaderShell({super.key, required this.s, required this.child});

  @override
  Widget build(BuildContext context) {
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
        child: child,
      ),
    );
  }
}

/// Header with title, subtitle and an X button (Add Device, Scan Results, Device Status).
class PageHeader extends StatelessWidget {
  final double s;
  final String title;
  final String subtitle;
  const PageHeader(
      {super.key, required this.s, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return HeaderShell(
      s: s,
      child: Stack(
        children: [
          Positioned(
            left: 92 * s,
            top: 70 * s,
            child: Text(title,
                style: AppText.dmSans(68 * s,
                    weight: FontWeight.w700, letterSpacing: -0.5)),
          ),
          Positioned(
            left: 96 * s,
            top: 146 * s,
            child: Text(subtitle,
                style: AppText.dmSans(28 * s, color: AppColors.textGray)),
          ),
          Positioned(
            right: 90 * s,
            top: 71 * s,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Icon(Icons.close, size: 85 * s, color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
