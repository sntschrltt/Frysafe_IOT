import 'package:flutter/material.dart';
import '../services/alerts_service.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_buttons.dart';
import '../widgets/header_shell.dart';
import '../widgets/smooth_route.dart';
import 'about_screen.dart';
import 'add_device_screen.dart';

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'
];
const _weekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];

String _dayLabel(int offset) {
  final d = DateTime.now().subtract(Duration(days: offset));
  final date = '${_months[d.month - 1]} ${d.day}';
  if (offset == 0) return 'Today, $date';
  if (offset == 1) return 'Yesterday, $date';
  return '${_weekdays[d.weekday - 1]}, $date';
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  /// What happens when an alert is tapped (also marks it as read).
  void _open(BuildContext context, AlertItem a) {
    AlertsService.instance.markRead(a.id);
    switch (a.kind) {
      case AlertKind.checkOil:
        appTab.value = 0; // Home: dip the probe
      case AlertKind.offline:
        openAddDevice(context); // reconnect / pair again
      case AlertKind.lowLife:
      case AlertKind.lifeUpdated:
        appTab.value = 3; // Analytics
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = AlertsService.instance;
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      return ValueListenableBuilder<List<AlertItem>>(
        valueListenable: svc.alerts,
        builder: (context, alerts, _) {
          final groups = <int, List<AlertItem>>{};
          for (final a in alerts) {
            groups.putIfAbsent(a.dayOffset, () => []).add(a);
          }
          final hasUnread = alerts.any((a) => !a.read);
          var first = true;
          final children = <Widget>[];
          groups.forEach((offset, items) {
            children.add(Padding(
              padding: EdgeInsets.fromLTRB(
                  91 * s, first ? 53 * s : 50 * s, 84 * s, 22 * s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_dayLabel(offset),
                      style: AppText.arial(38 * s, weight: FontWeight.bold)),
                  if (first)
                    GestureDetector(
                      onTap: hasUnread ? svc.markAllRead : null,
                      child: Text('Mark all as read',
                          style: AppText.dmSans(36 * s,
                                  weight: FontWeight.w700,
                                  color: hasUnread
                                      ? AppColors.brandOrange
                                      : AppColors.inactive)
                              .copyWith(decoration: TextDecoration.underline)),
                    ),
                ],
              ),
            ));
            first = false;
            for (final a in items) {
              children.add(Padding(
                padding: EdgeInsets.fromLTRB(91 * s, 0, 92 * s, 32 * s),
                child: _AlertCard(
                  s: s,
                  a: a,
                  onTap: () => _open(context, a),
                  onAction: () => _open(context, a),
                ),
              ));
            }
          });
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(children: [
              Positioned.fill(
                child: ListView(
                  padding: EdgeInsets.only(
                      top: AppLayout.headerHeight * s,
                      bottom: AppLayout.navClearance * s),
                  children: children,
                ),
              ),
              AppHeader(
                s: s,
                title: 'ALERTS',
                subtitle: 'Remaining useful life & replacement reminders',
                actionIcon: Icons.info_outline,
                onAction: () => Navigator.of(context)
                    .push(smoothRoute(const AboutScreen())),
              ),
            ]),
          );
        },
      );
    });
  }
}

class _AlertCard extends StatelessWidget {
  final double s;
  final AlertItem a;
  final VoidCallback onTap;
  final VoidCallback onAction;
  const _AlertCard(
      {required this.s, required this.a, required this.onTap, required this.onAction});

  Color get _iconBg => switch (a.kind) {
        AlertKind.checkOil => AppColors.high,
        AlertKind.offline => AppColors.textGray,
        AlertKind.lowLife => AppColors.high,
        AlertKind.lifeUpdated => AppColors.moderate,
      };

  IconData get _icon => switch (a.kind) {
        AlertKind.checkOil => Icons.schedule,
        AlertKind.offline => Icons.wifi,
        AlertKind.lowLife => Icons.warning_amber_outlined,
        AlertKind.lifeUpdated => Icons.water_drop_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final read = a.read;
    final showButton = a.kind == AlertKind.checkOil && !read;
    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(23 * s, 24 * s, 36 * s, (showButton ? 24 : 40) * s),
          decoration: BoxDecoration(
            color: read ? const Color(0xFFF1EFE1) : AppColors.surface,
            borderRadius: BorderRadius.circular(55 * s),
            border: Border.all(
                color: read ? const Color(0xFFE6E4D8) : AppColors.border,
                width: 3 * s),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: read ? 0.55 : 1,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(top: 10 * s),
                child: Container(
                  width: 107 * s,
                  height: 107 * s,
                  decoration: BoxDecoration(color: _iconBg, shape: BoxShape.circle),
                  child: Icon(_icon, size: 62 * s, color: Colors.white),
                ),
              ),
              SizedBox(width: 22 * s),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: EdgeInsets.only(right: 44 * s),
                    child: Row(children: [
                      Expanded(
                        child: Text(a.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.dmSans(35 * s, weight: FontWeight.w700)),
                      ),
                      Text(a.time,
                          style: AppText.dmSans(27 * s,
                              weight: FontWeight.w700, color: AppColors.textGray)),
                    ]),
                  ),
                  SizedBox(height: 7 * s),
                  Padding(
                    padding: EdgeInsets.only(right: 28 * s),
                    child: Text(a.body,
                        style: AppText.dmSans(26 * s).copyWith(height: 1.3)),
                  ),
                  if (showButton) ...[
                    SizedBox(height: 11 * s),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        s: s,
                        label: 'CHECK YOUR OIL NOW',
                        kind: AppButtonKind.orange,
                        size: AppButtonSize.compact,
                        color: AppColors.high, // matches the alert icon
                        width: 291 * s,
                        onTap: onAction,
                      ),
                    ),
                  ],
                ]),
              ),
            ]),
          ),
        ),
        if (!read)
          Positioned(
            top: 17 * s,
            right: 32 * s,
            child: Container(
              width: 24 * s,
              height: 24 * s,
              decoration:
                  const BoxDecoration(color: AppColors.high, shape: BoxShape.circle),
            ),
          ),
      ]),
    );
  }
}
