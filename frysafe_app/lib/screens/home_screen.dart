import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_buttons.dart';
import '../widgets/frysafe_header.dart';
import '../widgets/replacement_banner.dart';
import '../widgets/rul_card.dart';
import '../widgets/summary_cards.dart';
import '../widgets/sensor_card.dart';
import 'add_device_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = DeviceService.instance;
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      return ListenableBuilder(
        listenable: Listenable.merge([svc.status, svc.bannerVisible]),
        builder: (context, _) {
          final st = svc.status.value;
          final m = st == HomeStatus.result ? svc.latest : null;
          final sev = m == null ? null : severityFromOdi(m.odi);
          // Banner: High / Very High reading, and only for the first 10 seconds
          final showBanner = svc.bannerVisible.value &&
              m != null &&
              (sev == Severity.high || sev == Severity.veryHigh);
          Widget label(double left, String text) => Padding(
                padding: EdgeInsets.only(left: left * s),
                child: Text(text,
                    style: AppText.arial(38 * s, weight: FontWeight.bold)),
              );
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                // Scrollable content (goes under the header and the nav)
                Positioned.fill(
                  child: ListView(
                    padding: EdgeInsets.only(
                        top: 321 * s,
                        // extra room so the banner never hides the last cards
                        bottom: (AppLayout.navClearance + (showBanner ? 160 : 0)) * s),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(96 * s, 0, 92 * s, 0),
                        child: SizedBox(
                          height: 413 * s,
                          child: _HeroCard(s: s, status: st, m: m),
                        ),
                      ),
                      // Remaining useful life (only when there is a reading)
                      if (m != null) ...[
                        SizedBox(height: 28 * s),
                        Padding(
                          padding: EdgeInsets.fromLTRB(96 * s, 0, 92 * s, 0),
                          child: SizedBox(
                            height: 205 * s,
                            child: RulCard(s: s, odi: m.odi, odiPerCycle: svc.odiPerCycle),
                          ),
                        ),
                      ],
                      SizedBox(height: 49 * s),
                      label(91, 'Sensor Readings'),
                      SizedBox(height: 29 * s),
                      Padding(
                        padding: EdgeInsets.fromLTRB(95 * s, 0, 92 * s, 0),
                        child: SizedBox(
                          height: 307 * s,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SensorCard(
                                  s: s,
                                  icon: Container(
                                    width: 40 * s,
                                    height: 40 * s,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: SweepGradient(colors: [
                                        Colors.red, Colors.yellow, Colors.green,
                                        Colors.cyan, Colors.blue, Colors.purple,
                                        Colors.red,
                                      ]),
                                    ),
                                  ),
                                  label: 'Color (RGB)',
                                  lines: m == null
                                      ? null // no reading: one dash + Hz, same as Turbidity
                                      : [
                                    SensorLine(
                                        swatch: const Color(0xFFE53935),
                                        value: '${m.r}',
                                        unit: 'Hz'),
                                    SensorLine(
                                        swatch: const Color(0xFF43A047),
                                        value: '${m.g}',
                                        unit: 'Hz'),
                                    SensorLine(
                                        swatch: const Color(0xFF1E6FE0),
                                        value: '${m.b}',
                                        unit: 'Hz'),
                                  ],
                                  unit: 'Hz',
                                ),
                              ),
                              SizedBox(width: 60 * s),
                              Expanded(
                                child: SensorCard(
                                  s: s,
                                  icon: Icon(Icons.water_drop,
                                      size: 46 * s, color: AppColors.brandOrange),
                                  label: 'Turbidity',
                                  value: m?.mv.toStringAsFixed(1),
                                  unit: 'mV',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 42 * s),
                      label(100, 'Analytics'),
                      SizedBox(height: 37 * s),
                      Padding(
                        padding: EdgeInsets.fromLTRB(100 * s, 0, 92 * s, 0),
                        child: SizedBox(
                          height: 354 * s,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: UsageSummaryCard(s: s)),
                              SizedBox(width: 54 * s),
                              Expanded(child: ReplacementSummaryCard(s: s)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Replacement notice: pops up above the bottom nav, then hides itself
                Positioned(
                  left: 91 * s,
                  right: 91 * s,
                  bottom: (AppLayout.navHeight + 24) * s,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, 0.3), end: Offset.zero)
                            .animate(anim),
                        child: child,
                      ),
                    ),
                    child: showBanner
                        ? ReplacementBanner(
                            key: const ValueKey('replacement-banner'),
                            s: s,
                            severity: sev!,
                            lastReading: m!.time,
                          )
                        : const SizedBox.shrink(key: ValueKey('no-banner')),
                  ),
                ),
                FrySafeHeader(s: s),
              ],
            ),
          );
        },
      );
    });
  }
}

class _HeroCard extends StatelessWidget {
  final double s;
  final HomeStatus status;
  final Measurement? m;
  const _HeroCard({required this.s, required this.status, required this.m});

  @override
  Widget build(BuildContext context) {
    final meas = m;
    final sev = meas == null ? null : severityFromOdi(meas.odi);
    final Widget content;
    switch (status) {
      case HomeStatus.notConnected:
        content = Column(mainAxisSize: MainAxisSize.min, children: [
          Text('FRYSAFE is not connected',
              style: AppText.dmSans(52 * s,
                  weight: FontWeight.w500, color: AppColors.textGray)),
          SizedBox(height: 43 * s),
          Text('No probe detected. Add a device\nto start monitoring oil degradation.',
              textAlign: TextAlign.center,
              style: AppText.dmSans(40 * s,
                      weight: FontWeight.w700, color: AppColors.high)
                  .copyWith(fontStyle: FontStyle.italic, height: 0.93)),
          SizedBox(height: 42 * s),
          AppButton(
            s: s,
            label: '+  PAIR THE PROBE',
            kind: AppButtonKind.orange,
            size: AppButtonSize.small,
            width: 399 * s,
            onTap: () => openAddDevice(context),
          ),
        ]);
      case HomeStatus.connected:
        content = Column(mainAxisSize: MainAxisSize.min, children: [
          Text('FRYSAFE is now\nconnected!',
              textAlign: TextAlign.center,
              style: AppText.dmSans(72 * s,
                      weight: FontWeight.w700, color: AppColors.brandOrange)
                  .copyWith(height: 0.98)),
          SizedBox(height: 20 * s),
          Text('Insert the FRYSAFE probe into the cooking oil for testing.',
              textAlign: TextAlign.center,
              style: AppText.dmSans(25 * s,
                      weight: FontWeight.w700, color: AppColors.high)
                  .copyWith(fontStyle: FontStyle.italic)),
          SizedBox(height: 34 * s),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 54 * s,
                height: 54 * s,
                decoration: const BoxDecoration(
                    color: AppColors.low, shape: BoxShape.circle)),
            SizedBox(width: 18 * s),
            Text('MONITORING ACTIVE',
                style: AppText.dmSans(45 * s,
                    weight: FontWeight.w500, color: AppColors.low)),
          ]),
        ]);
      case HomeStatus.loading:
        content = Column(mainAxisSize: MainAxisSize.min, children: [
          CupertinoActivityIndicator(
              radius: 88 * s, color: AppColors.brandOrange),
          SizedBox(height: 52 * s),
          Text('FETCHING THE LATEST RESULTS…',
              style: AppText.dmSans(42 * s,
                  weight: FontWeight.w700, color: AppColors.brandOrange)),
        ]);
      case HomeStatus.result:
        if (meas == null || sev == null) {
          content = const SizedBox();
          break;
        }
        content = Column(mainAxisSize: MainAxisSize.min, children: [
          Text('OIL DEGRADATION INDEX',
              style: AppText.dmSans(52 * s,
                  weight: FontWeight.w600, color: AppColors.textGray)),
          SizedBox(height: 4 * s),
          Text('${meas.odi}%',
              style: AppText.dmSans(190 * s,
                  weight: FontWeight.w700, color: sev.color)),
          SizedBox(height: 14 * s),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.warning_amber_outlined, size: 56 * s, color: sev.color),
            SizedBox(width: 14 * s),
            Text(sev.headline,
                style: AppText.dmSans(48 * s,
                    weight: FontWeight.w700, color: sev.color)),
          ]),
        ]);
    }
    return GestureDetector(
      // demo: tap while "Monitoring Active" = probe inserted
      onTap: status == HomeStatus.connected
          ? DeviceService.instance.simulateProbeInserted
          : null,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(75 * s),
          border: Border.all(color: sev?.color ?? AppColors.border, width: 3 * s),
        ),
        child: content,
      ),
    );
  }
}
