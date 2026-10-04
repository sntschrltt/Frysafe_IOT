import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';
import '../widgets/frysafe_header.dart';
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
      return ValueListenableBuilder<HomeStatus>(
        valueListenable: svc.status,
        builder: (context, st, _) {
          final m = st == HomeStatus.result ? svc.latest : null;
          final sev = m == null ? null : severityFromOdi(m.odi);
          final fill = sev?.color ?? AppColors.high;
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
                    padding: EdgeInsets.only(top: 321 * s, bottom: 298 * s),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(96 * s, 0, 92 * s, 0),
                        child: SizedBox(
                          height: 413 * s,
                          child: _HeroCard(s: s, status: st, m: m),
                        ),
                      ),
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
                                  label: 'Color (RDR)',
                                  value: m?.rdr.toStringAsFixed(2),
                                  progress: m == null ? 0 : m.rdr / 1.2, // placeholder scale
                                  color: fill,
                                ),
                              ),
                              SizedBox(width: 60 * s),
                              Expanded(
                                child: SensorCard(
                                  s: s,
                                  icon: Icon(Icons.water_drop,
                                      size: 46 * s, color: AppColors.brandOrange),
                                  label: 'Turbidity',
                                  value: m?.ntu.toStringAsFixed(1),
                                  unit: 'NTU',
                                  progress: m == null ? 0 : m.ntu / 4.0, // placeholder scale
                                  color: fill,
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
          Text('FrySafe is not connected',
              style: AppText.dmSans(52 * s,
                  weight: FontWeight.w500, color: AppColors.textGray)),
          SizedBox(height: 43 * s),
          Text('No probe detected. Add a device\nto start monitoring oil degradation.',
              textAlign: TextAlign.center,
              style: AppText.dmSans(40 * s,
                      weight: FontWeight.w700, color: AppColors.high)
                  .copyWith(fontStyle: FontStyle.italic, height: 0.93)),
          SizedBox(height: 42 * s),
          GestureDetector(
            onTap: () => openAddDevice(context),
            child: Container(
              width: 399 * s,
              height: 80 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.brandOrange,
                  borderRadius: BorderRadius.circular(16 * s)),
              child: Text('+  PAIR THE PROBE',
                  style: AppText.dmSans(38 * s,
                      weight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ]);
      case HomeStatus.connected:
        content = Column(mainAxisSize: MainAxisSize.min, children: [
          Text('FrySafe is now\nconnected!',
              textAlign: TextAlign.center,
              style: AppText.dmSans(72 * s,
                      weight: FontWeight.w700, color: AppColors.brandOrange)
                  .copyWith(height: 0.98)),
          SizedBox(height: 20 * s),
          Text('Insert the FrySafe probe into the cooking oil for testing.',
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
