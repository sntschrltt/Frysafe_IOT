import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';

class _Frame extends StatelessWidget {
  final double s;
  final Widget icon;
  final Widget child;
  const _Frame({required this.s, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(60 * s),
          border: Border.all(color: AppColors.border, width: 3 * s),
        ),
        child: Stack(children: [
          Positioned(
            left: 27 * s,
            top: 29 * s,
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
          child,
        ]),
      );
}

class UsageSummaryCard extends StatelessWidget {
  final double s;
  const UsageSummaryCard({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final svc = DeviceService.instance;
    return _Frame(
      s: s,
      icon: Icon(Icons.calendar_month, size: 46 * s, color: const Color(0xFFF5B800)),
      child: Stack(children: [
        Positioned(
          left: 112 * s,
          top: 48 * s,
          child: Text('Daily Oil Usage',
              style: AppText.dmSans(38 * s, weight: FontWeight.w700)),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 123 * s,
          child: ValueListenableBuilder<double>(
            valueListenable: svc.todayLiters,
            builder: (_, v, __) => Center(
              child: Text('${v.toStringAsFixed(1)} L',
                  style: AppText.dmSans(120 * s, weight: FontWeight.w700)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 266 * s,
          child: Center(
              child: Text('Today',
                  style: AppText.dmSans(44 * s,
                      weight: FontWeight.w600, color: AppColors.textGray))),
        ),
      ]),
    );
  }
}

class ReplacementSummaryCard extends StatelessWidget {
  final double s;
  const ReplacementSummaryCard({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final svc = DeviceService.instance;
    return _Frame(
      s: s,
      icon: Icon(Icons.sync, size: 52 * s, color: AppColors.high),
      child: ValueListenableBuilder<List<DateTime>>(
        valueListenable: svc.replacements,
        builder: (_, _, _) {
          final d = svc.avgIntervalDays;
          final last = svc.lastReplaced;
          return Stack(children: [
            Positioned(
              left: 108 * s,
              right: 18 * s,
              top: 25 * s,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Oil Replacement\nFrequency',
                    style: AppText.dmSans(32 * s, weight: FontWeight.w700)
                        .copyWith(height: 1.2)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 138 * s,
              child: Text('Every\n${d ?? '—'} ${d == 1 ? 'DAY' : 'DAYS'}',
                  textAlign: TextAlign.center,
                  style: AppText.dmSans(64 * s, weight: FontWeight.w700)
                      .copyWith(height: 0.97)),
            ),
            Positioned(
              left: 22 * s,
              right: 22 * s,
              top: 284 * s,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                    'Last Replaced: ${last == null ? '—' : relativeDay(last)}',
                    style: AppText.dmSans(26 * s, weight: FontWeight.w700)),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
