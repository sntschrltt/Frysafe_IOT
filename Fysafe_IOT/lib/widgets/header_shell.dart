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
      height: AppLayout.headerHeight * s,
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

/// The icon at the top-right of EVERY header (X, info, download):
/// same size, same position everywhere. Use inside a Stack.
class HeaderIconButton extends StatelessWidget {
  final double s;
  final IconData icon;
  final VoidCallback? onTap;
  const HeaderIconButton(
      {super.key, required this.s, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 79 * s,
      top: 79 * s,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Icon(icon, size: 85 * s, color: AppColors.black),
      ),
    );
  }
}

/// ONE header for the whole app, so fonts and spacing are identical:
///  - title    DM Sans 68 bold   (top 70)
///  - subtitle DM Sans 28 gray   (top 146)
///  - [showLogo] adds the logo and moves the text right (Home, Analytics)
///  - [actionIcon] is the top-right icon (X / info / download)
class AppHeader extends StatelessWidget {
  final double s;
  final String title;
  final String subtitle;
  final bool showLogo;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final VoidCallback? onTitleLongPress; // demo reset on Home
  const AppHeader({
    super.key,
    required this.s,
    required this.title,
    required this.subtitle,
    this.showLogo = false,
    this.actionIcon,
    this.onAction,
    this.onTitleLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final left = (showLogo ? 200.0 : 96.0) * s;
    return HeaderShell(
      s: s,
      child: Stack(
        children: [
          if (showLogo)
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
            left: left,
            top: 70 * s,
            child: GestureDetector(
              onLongPress: onTitleLongPress,
              child: Text(title,
                  style: AppText.dmSans(68 * s,
                      weight: FontWeight.w700, letterSpacing: -0.5)),
            ),
          ),
          Positioned(
            left: left,
            top: 146 * s,
            child: Text(subtitle,
                style: AppText.dmSans(28 * s, color: AppColors.textGray)),
          ),
          if (actionIcon != null)
            HeaderIconButton(s: s, icon: actionIcon!, onTap: onAction),
        ],
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
    return AppHeader(
      s: s,
      title: title,
      subtitle: subtitle,
      actionIcon: Icons.close,
      onAction: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
  }
}
