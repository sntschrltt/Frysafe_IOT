import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_buttons.dart';
import '../widgets/header_shell.dart';

class DeviceStatusScreen extends StatelessWidget {
  const DeviceStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      Widget row(double top, String label, Widget value) => Positioned(
            left: 91 * s,
            right: 91 * s,
            top: top * s,
            height: 116 * s,
            child: Container(
              padding: EdgeInsets.only(left: 32 * s, right: 30 * s),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(30 * s),
                border: Border.all(color: AppColors.border, width: 3 * s),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppText.arial(38 * s)),
                  value,
                ],
              ),
            ),
          );
      Widget mono(String t) => Text(t, style: AppText.mono(30 * s));
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned(
              left: 91 * s,
              right: 91 * s,
              top: 309 * s,
              height: 196 * s,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(55 * s),
                  border: Border.all(color: AppColors.low, width: 3 * s),
                ),
                child: Stack(children: [
                  Positioned(
                    left: 49 * s,
                    top: 56 * s,
                    child: Icon(Icons.check_circle_outline,
                        size: 76 * s, color: AppColors.low),
                  ),
                  Positioned(
                    left: 156 * s,
                    top: 53 * s,
                    child: Text('Successfully connected!',
                        style: AppText.dmSans(40 * s,
                            weight: FontWeight.w700, color: AppColors.low)),
                  ),
                  Positioned(
                    left: 156 * s,
                    top: 102 * s,
                    child: Text('FrySafe is online and transmitting.',
                        style: AppText.dmSans(28 * s, color: AppColors.low)),
                  ),
                ]),
              ),
            ),
            Positioned(
              left: 91 * s,
              top: 557 * s,
              child: Text('CONNECTION INFO',
                  style: AppText.arial(39 * s, weight: FontWeight.bold)),
            ),
            row(625, 'Device Name', mono(DeviceService.deviceName)),
            row(779, 'IP Address', mono(DeviceService.ipAddress)),
            row(934, 'Network Name', mono(DeviceService.networkName)),
            row(
              1075,
              'Status',
              Row(children: [
                Container(
                    width: 27 * s,
                    height: 27 * s,
                    decoration: const BoxDecoration(
                        color: AppColors.low, shape: BoxShape.circle)),
                SizedBox(width: 14 * s),
                Text('Active', style: AppText.mono(30 * s, color: AppColors.low)),
              ]),
            ),
            Positioned(
              left: 95 * s,
              right: 87 * s,
              bottom: 132 * s,
              child: AppBlackButton(
                s: s,
                label: 'Go to Dashboard →',
                onTap: () {
                  DeviceService.instance.markPaired();
                  appTab.value = 0;
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
            ),
            PageHeader(s: s, title: 'DEVICE STATUS', subtitle: 'FrySafe • Paired'),
          ],
        ),
      );
    });
  }
}
