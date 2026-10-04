import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/smooth_route.dart';
import '../widgets/app_buttons.dart';
import '../widgets/header_shell.dart';
import 'device_status_screen.dart';

class ScanResultsScreen extends StatelessWidget {
  const ScanResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      Widget bar(double h) => Container(
          width: 17 * s,
          height: h * s,
          decoration: BoxDecoration(
              color: AppColors.low, borderRadius: BorderRadius.circular(3 * s)));
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned(
              left: 91 * s,
              top: 307 * s,
              child: Text('DEVICES FOUND (1)',
                  style: AppText.arial(39 * s, weight: FontWeight.bold)),
            ),
            Positioned(
              left: 91 * s,
              right: 92 * s,
              top: 412 * s,
              height: 320 * s,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(60 * s),
                  border: Border.all(color: AppColors.border, width: 3 * s),
                ),
                child: Stack(children: [
                  Positioned(
                    left: 62 * s,
                    top: 64 * s,
                    width: 178 * s,
                    height: 178 * s,
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppColors.chipGray,
                          borderRadius: BorderRadius.circular(12 * s)),
                      child: Icon(Icons.memory, size: 140 * s, color: AppColors.black),
                    ),
                  ),
                  Positioned(
                    left: 287 * s,
                    top: 80 * s,
                    child: Text('FrySafe Probe 0.1',
                        style: AppText.dmSans(37 * s, weight: FontWeight.w700)),
                  ),
                  Positioned(
                    left: 287 * s,
                    top: 124 * s,
                    child: Text('Master Buffalo – Sta. Mesa',
                        style: AppText.dmSans(29 * s, color: AppColors.textGray)),
                  ),
                  Positioned(
                    left: 293 * s,
                    top: 170 * s,
                    child: Row(children: [
                      Container(
                          width: 38 * s,
                          height: 38 * s,
                          decoration: const BoxDecoration(
                              color: AppColors.low, shape: BoxShape.circle)),
                      SizedBox(width: 11 * s),
                      Text('Active',
                          style: AppText.dmSans(32 * s,
                              weight: FontWeight.w500, color: AppColors.low)),
                    ]),
                  ),
                  Positioned(
                    right: 39 * s,
                    top: 105 * s,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        bar(16), SizedBox(width: 8 * s),
                        bar(33), SizedBox(width: 8 * s),
                        bar(48), SizedBox(width: 8 * s),
                        bar(63),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 37 * s,
                    top: 177 * s,
                    child: Text('STRONG',
                        style: AppText.arial(28 * s,
                            weight: FontWeight.bold, color: AppColors.low)),
                  ),
                ]),
              ),
            ),
            Positioned(
              left: 91 * s,
              width: 366 * s,
              bottom: 132 * s,
              child: AppOutlineButton(
                  s: s, label: 'Rescan', onTap: () {} /* mock: re-run the scan later */),
            ),
            Positioned(
              left: 503 * s,
              right: 87 * s,
              bottom: 132 * s,
              child: AppBlackButton(
                s: s,
                label: 'Pair Device →',
                onTap: () => Navigator.of(context).push(smoothRoute(const DeviceStatusScreen())),
              ),
            ),
            PageHeader(
                s: s, title: 'SCAN RESULTS', subtitle: 'Devices on your network'),
          ],
        ),
      );
    });
  }
}
