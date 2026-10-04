import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';
import '../widgets/smooth_route.dart';
import '../widgets/app_buttons.dart';
import '../widgets/header_shell.dart';
import 'scan_results_screen.dart';

void openAddDevice(BuildContext context) => Navigator.of(context)
    .push(smoothRoute(const AddDeviceScreen()));

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({super.key});

  Widget _step(double s, double circleTop, double textTop, String n,
      List<InlineSpan> spans) {
    return Stack(children: [
      Positioned(
        left: 117 * s,
        top: circleTop * s,
        width: 78 * s,
        height: 78 * s,
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: AppColors.chipGray, shape: BoxShape.circle),
          child: Text(n, style: AppText.dmSans(54 * s, weight: FontWeight.w600)),
        ),
      ),
      Positioned(
        left: 229 * s,
        width: 720 * s,
        top: textTop * s,
        child: Text.rich(TextSpan(children: spans),
            style: AppText.arial(34 * s).copyWith(height: 1.4)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      TextSpan bold(String t) => TextSpan(
          text: t, style: AppText.dmSans(34 * s, weight: FontWeight.w700));
      Widget field(String label, String value, {bool pwd = false}) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 36 * s),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppText.arial(36 * s, color: AppColors.textGray)),
                  SizedBox(height: 16 * s),
                  Text(value,
                      style: pwd
                          ? AppText.arial(38 * s, weight: FontWeight.bold)
                          : AppText.dmSans(38 * s, weight: FontWeight.w700)),
                ],
              ),
            ),
          );
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: math.max(1920 * s, c.maxHeight),
                  child: Stack(
                    children: [
            Positioned(
              left: 367 * s,
              top: 367 * s,
              width: 346 * s,
              height: 346 * s,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.black, width: 2 * s)),
                child: Center(
                  child: Container(
                    width: 246 * s,
                    height: 246 * s,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0x33545454),
                            blurRadius: 40 * s,
                            spreadRadius: 4 * s),
                      ],
                    ),
                    child: Icon(Icons.wifi, size: 140 * s, color: AppColors.black),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 785 * s,
              child: Text('Connect to FrySafe Wi-Fi',
                  textAlign: TextAlign.center,
                  style: AppText.dmSans(46 * s, weight: FontWeight.w700)),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 847 * s,
              child: Text(
                  'Before scanning, connect your phone to\nthe FrySafe’s hotspot first.',
                  textAlign: TextAlign.center,
                  style: AppText.arial(36 * s).copyWith(height: 1.17)),
            ),
            Positioned(
              left: 91 * s,
              right: 91 * s,
              top: 982 * s,
              height: 330 * s,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(55 * s),
                  border: Border.all(color: AppColors.border, width: 3 * s),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  field('NETWORK NAME', DeviceService.networkName),
                  Container(height: 3 * s, color: AppColors.border),
                  field('DEFAULT PASSWORD', '••••••••', pwd: true),
                ]),
              ),
            ),
            Positioned.fill(
              child: _step(s, 1372, 1365, '1', [
                const TextSpan(text: 'Go to Phone '),
                bold('Wi-Fi settings'),
                const TextSpan(text: ' and connect to\n'),
                bold('FrySafe Probe 0.1'),
              ]),
            ),
            Positioned.fill(
              child: _step(s, 1468, 1483, '2', [
                const TextSpan(text: 'Return to this '),
                bold('app'),
                const TextSpan(text: ' and tap '),
                bold('Scan for Device'),
              ]),
            ),
            Positioned(
              left: 95 * s,
              right: 87 * s,
              bottom: 132 * s,
              child: AppBlackButton(
                s: s,
                label: 'Scan for Device →',
                onTap: () => Navigator.of(context).push(smoothRoute(const ScanResultsScreen())),
              ),
            ),
                    ],
                  ),
                ),
              ),
            ),
            PageHeader(s: s, title: 'ADD DEVICE', subtitle: 'Connect FrySafe'),
          ],
        ),
      );
    });
  }
}
