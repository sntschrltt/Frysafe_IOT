import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';

/// Shared styles so both Home analytics cards always match.
/// Change a number here and BOTH cards follow.
TextStyle _labelStyle(double s, double size) =>
    AppText.dmSans(size * s, weight: FontWeight.w700).copyWith(height: 1.2);

/// Big-number sizes (design px). The right card has two lines, so its number
/// is smaller than the one-line number on the left; change them here.
const _usageValueSize = 88.0; // "2.3 L"
const _frequencyValueSize = 58.0; // "Every / 2 DAYS"

TextStyle _valueStyle(double s, double size) =>
    AppText.dmSans(size * s, weight: FontWeight.w700);

/// Two-line card title. Default size 32 (Oil Replacement Frequency);
/// Daily Oil Usage passes its own bigger size.
Widget _label(double s, String text, {double size = 32}) => Positioned(
      left: 108 * s,
      right: 18 * s,
      top: 25 * s,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(text, style: _labelStyle(s, size)),
      ),
    );

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
        _label(s, 'Daily Oil\nUsage', size: 36), // only this title is bigger
        // one line, centered where the two-line value on the other card sits
        Positioned(
          left: 20 * s,
          right: 20 * s,
          top: 147 * s,
          child: ValueListenableBuilder<double>(
            valueListenable: svc.todayLiters,
            builder: (_, v, _) => FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(v.toStringAsFixed(1),
                      style: _valueStyle(s, _usageValueSize)),
                  SizedBox(width: 8 * s),
                  Text('L',
                      style: AppText.dmSans(40 * s,
                          weight: FontWeight.w700, color: AppColors.textGray)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 273 * s,
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
            _label(s, 'Oil Replacement\nFrequency'),
            Positioned(
              left: 0,
              right: 0,
              top: 135 * s,
              child: Text('Every\n${d ?? '—'} ${d == 1 ? 'DAY' : 'DAYS'}',
                  textAlign: TextAlign.center,
                  style: _valueStyle(s, _frequencyValueSize).copyWith(height: 0.97)),
            ),
            Positioned(
              left: 22 * s,
              right: 22 * s,
              top: 282 * s,
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
