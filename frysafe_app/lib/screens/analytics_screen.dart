import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_buttons.dart';
import '../widgets/bar_chart.dart';
import '../widgets/frysafe_header.dart';

const _wd3 = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _num(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final svc = DeviceService.instance;
  double entry = 2.5; // liters to add
  bool week = true;

  late final TextEditingController _ctrl =
      TextEditingController(text: entry.toStringAsFixed(1));
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus) {
        // select everything so the user can type a new number right away
        _ctrl.selection =
            TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
      } else {
        setState(() => _ctrl.text = entry.toStringAsFixed(1));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _setEntry(double v) => setState(() {
        entry = v.clamp(0.0, 99.9);
        _ctrl.text = entry.toStringAsFixed(1);
      });

  double _fieldWidth(double s) {
    final text = _ctrl.text.isEmpty ? '0' : _ctrl.text;
    final w = text.split('').fold<double>(0, (a, c) => a + (c == '.' ? 30 : 62));
    return (w + 12) * s;
  }

  BoxDecoration _card(double s, double r, {Color? border}) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(r * s),
        border: Border.all(color: border ?? AppColors.border, width: 3 * s),
      );

  Widget _stepBtn(double s, IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 106 * s,
          height: 106 * s,
          decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 3 * s)),
          child: Icon(icon, size: 56 * s, color: AppColors.black),
        ),
      );

  Widget _logCard(double s) => Container(
        height: 331 * s,
        decoration: _card(s, 60),
        child: Stack(children: [
          Positioned(
            left: 49 * s,
            top: 33 * s,
            child: Text('Log oil usage',
                style: AppText.dmSans(44 * s, weight: FontWeight.w600)),
          ),
          Positioned(
              left: 60 * s,
              top: 107 * s,
              child: _stepBtn(s, Icons.remove,
                  () => _setEntry(entry - 0.5))),
          Positioned(
            left: 181 * s,
            top: 92 * s,
            width: 350 * s,
            height: 136 * s,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40 * s),
                border: Border.all(color: AppColors.high, width: 3 * s),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _focus.requestFocus,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: _fieldWidth(s),
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.done,
                          cursorColor: AppColors.high,
                          inputFormatters: [
                            TextInputFormatter.withFunction((o, n) =>
                                RegExp(r'^\d{0,2}\.?\d{0,1}$').hasMatch(n.text)
                                    ? n
                                    : o),
                          ],
                          onChanged: (v) =>
                              setState(() => entry = double.tryParse(v) ?? 0),
                          onSubmitted: (_) => _focus.unfocus(),
                          decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero),
                          style: AppText.dmSans(100 * s, weight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Padding(
                        padding: EdgeInsets.only(bottom: 18 * s),
                        child: Text('L',
                            style: AppText.dmSans(40 * s,
                                weight: FontWeight.w500,
                                color: AppColors.textGray)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              left: 546 * s,
              top: 103 * s,
              child: _stepBtn(s, Icons.add,
                  () => _setEntry(entry + 0.5))),
          Positioned(
            left: 698 * s,
            top: 102 * s,
            width: 126 * s,
            height: 80 * s,
            child: AppButton(
              s: s,
              label: 'Add',
              kind: AppButtonKind.orange,
              size: AppButtonSize.small,
              onTap: () {
                _focus.unfocus();
                if (entry > 0) svc.addUsage(entry);
              },
            ),
          ),
          Positioned(
            left: 56 * s,
            top: 259 * s,
            child: ValueListenableBuilder<double>(
              valueListenable: svc.todayLiters,
              builder: (_, v, __) => Text(
                  'Today as of now: ${v.toStringAsFixed(1)} L · liters used',
                  style: AppText.dmSans(30 * s,
                      weight: FontWeight.w500, color: AppColors.textGray)),
            ),
          ),
        ]),
      );

  Widget _lastChangeCard(double s) => Container(
        height: 290 * s,
        decoration: _card(s, 60),
        child: ValueListenableBuilder<List<DateTime>>(
          valueListenable: svc.replacements,
          builder: (_, __, ___) {
            final last = svc.lastReplaced;
            return Stack(children: [
              Positioned(
                left: 59 * s,
                top: 51 * s,
                child: Text('Last oil change',
                    style: AppText.dmSans(40 * s, weight: FontWeight.w600)),
              ),
              Positioned(
                left: 57 * s,
                top: 110 * s,
                child: Text(last == null ? '—' : relativeDay(last),
                    style: AppText.dmSans(72 * s, weight: FontWeight.w700)),
              ),
              Positioned(
                left: 59 * s,
                top: 197 * s,
                child: Text(last == null ? '' : formatDateTime(last),
                    style: AppText.dmSans(30 * s,
                        weight: FontWeight.w500, color: AppColors.textGray)),
              ),
              Positioned(
                right: 62 * s,
                top: 82 * s,
                width: 352 * s,
                height: 120 * s,
                child: AppButton(
                  s: s,
                  label: 'Oil replaced',
                  icon: Icons.sync,
                  kind: AppButtonKind.orange,
                  size: AppButtonSize.medium,
                  onTap: () => _confirmReplace(context),
                ),
              ),
            ]);
          },
        ),
      );

  Widget _toggle(double s) {
    Widget opt(String label, bool selected, bool isWeek) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() => week = isWeek),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(24 * s),
              ),
              child: Text(label,
                  style: AppText.dmSans(44 * s, weight: FontWeight.w600)),
            ),
          ),
        );
    return Container(
      height: 105 * s,
      padding: EdgeInsets.all(15 * s),
      decoration: BoxDecoration(
          color: const Color(0xFFE3E1CB),
          borderRadius: BorderRadius.circular(32 * s)),
      child: Row(children: [opt('7 days', week, true), opt('30 days', !week, false)]),
    );
  }

  Widget _chip(double s, String text) => Container(
        height: 79 * s,
        padding: EdgeInsets.symmetric(horizontal: 22 * s),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30 * s),
          border: Border.all(color: AppColors.high, width: 3 * s),
        ),
        child: Text(text,
            style: AppText.dmSans(32 * s, weight: FontWeight.w700, color: AppColors.high)),
      );

  Widget _usageCard(double s) {
    final today = dayOnly(DateTime.now());
    final List<String> labels;
    final List<double> values;
    if (week) {
      // last 7 days, today on the right
      labels = [
        for (var i = 6; i >= 0; i--) _wd3[shiftDay(today, -i).weekday - 1]
      ];
      values = svc.usageLastDays(7);
    } else {
      // last 28 days as 4 weeks: average liters per day
      labels = const ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'];
      final d = svc.usageLastDays(28);
      values = [
        for (var w = 0; w < 4; w++)
          d.sublist(w * 7, w * 7 + 7).reduce((a, b) => a + b) / 7
      ];
    }
    final hasData = values.any((v) => v > 0);
    final avg = values.reduce((a, b) => a + b) / values.length;
    final peak = values.indexOf(values.reduce((a, b) => a > b ? a : b));
    return Container(
      height: 614 * s,
      decoration: _card(s, 55),
      child: Stack(children: [
        Positioned(
          left: 59 * s,
          top: 46 * s,
          child: Text('Daily Oil Usage',
              style: AppText.dmSans(44 * s, weight: FontWeight.w600)),
        ),
        if (hasData)
          Positioned(
              right: 61 * s,
              top: 44 * s,
              child: _chip(s, 'Peak: ${labels[peak]} ${_num(values[peak])} L')),
        Positioned(
          left: 59 * s,
          top: 113 * s,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(avg.toStringAsFixed(1),
                  style: AppText.dmSans(80 * s, weight: FontWeight.w700)),
              SizedBox(width: 10 * s),
              Text('L/day',
                  style: AppText.dmSans(46 * s,
                      weight: FontWeight.w600, color: AppColors.textGray)),
            ],
          ),
        ),
        Positioned(
          left: 70 * s,
          right: 66 * s,
          top: 222 * s, // below the big number (ends ~193) + room for the bar value labels
          child: hasData
              ? SimpleBarChart(
                  s: s,
                  labels: labels,
                  values: values,
                  valueText: _num,
                  plotHeight: 330,
                  highlightMax: true,
                )
              : SizedBox(
                  height: 330 * s,
                  child: Center(
                    child: Text('No usage logged yet',
                        style: AppText.dmSans(34 * s, color: AppColors.textGray)),
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _replacementCard(double s) {
    final today = dayOnly(DateTime.now());
    final from = shiftDay(today, week ? -6 : -29);
    // finished oil lives whose change happened inside the chosen window (newest first)
    final inWindow =
        svc.replacementStats.where((r) => !r.date.isBefore(from)).toList();
    // bars: the latest 6, oldest on the left
    final shown = inWindow.take(6).toList().reversed.toList();
    final labels = [for (final r in shown) shortDate(r.date)];
    final values = [for (final r in shown) r.uses.toDouble()];
    final hasData = values.any((v) => v > 0);
    final avgGap = inWindow.isEmpty
        ? null
        : inWindow.fold<double>(0, (a, r) => a + r.gapDays) / inWindow.length;
    final n = inWindow.length;
    return Container(
      height: 696 * s,
      decoration: _card(s, 55),
      child: Stack(children: [
        Positioned(
          left: 41 * s,
          top: 38 * s,
          child: Text('Oil Replacement\nFrequency',
              style: AppText.dmSans(44 * s, weight: FontWeight.w600)
                  .copyWith(height: 1.3)),
        ),
        Positioned(
            right: 40 * s,
            top: 38 * s,
            child: _chip(
                s, '$n ${n == 1 ? 'Change' : 'Changes'} · ${week ? 7 : 30} days')),
        Positioned(
          left: 56 * s,
          top: 166 * s, // a bit lower so it clears the 2-line title
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(avgGap == null ? '—' : avgGap.toStringAsFixed(1),
                  style: AppText.dmSans(80 * s, weight: FontWeight.w700)),
              SizedBox(width: 10 * s),
              Text('days',
                  style: AppText.dmSans(46 * s,
                      weight: FontWeight.w600, color: AppColors.textGray)),
            ],
          ),
        ),
        Positioned(
          left: 56 * s,
          right: 80 * s,
          top: 270 * s, // below the big number (ends ~246) + room for the bar value labels
          child: hasData
              ? SimpleBarChart(
                  s: s,
                  labels: labels,
                  values: values,
                  valueText: (v) => '${_num(v)} times',
                  plotHeight: 360,
                )
              : SizedBox(
                  height: 360 * s,
                  child: Center(
                    child: Text('No oil changes yet',
                        style: AppText.dmSans(34 * s, color: AppColors.textGray)),
                  ),
                ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([svc.usage, svc.replacements, svc.readings]),
      builder: (context, _) => LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      Widget pad(double l, double r, double bottom, Widget w) =>
          Padding(padding: EdgeInsets.fromLTRB(l * s, 0, r * s, bottom * s), child: w);
      return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Positioned.fill(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(top: 316 * s, bottom: AppLayout.navClearance * s),
              children: [
                pad(96, 92, 22, _logCard(s)),
                pad(94, 93, 23, _lastChangeCard(s)),
                pad(113, 105, 31, _toggle(s)),
                pad(114, 119, 22, _usageCard(s)),
                pad(114, 119, 0, _replacementCard(s)),
              ],
            ),
          ),
          FrySafeHeader(s: s),
        ]),
      );
    }),
    );
  }

  void _confirmReplace(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x59000000),
      builder: (_) => const _ReplaceSheet(),
    );
  }
}

class _ReplaceSheet extends StatelessWidget {
  const _ReplaceSheet();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080;
      return Container(
        height: 877 * s,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(90 * s)),
        ),
        child: Stack(children: [
          Positioned(
            top: 47 * s,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 141 * s,
                height: 18 * s,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(9 * s)),
              ),
            ),
          ),
          Positioned(
            top: 91 * s,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 135 * s,
                height: 135 * s,
                decoration: const BoxDecoration(
                    color: AppColors.high, shape: BoxShape.circle),
                child: Icon(Icons.sync, size: 90 * s, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 275 * s,
            left: 0,
            right: 0,
            child: Text('Mark oil as replaced?',
                textAlign: TextAlign.center,
                style: AppText.dmSans(62 * s, weight: FontWeight.w700)),
          ),
          Positioned(
            top: 366 * s,
            left: 100 * s,
            right: 100 * s,
            child: Text(
                'This logs a new oil change now and restarts the oil life estimate.',
                textAlign: TextAlign.center,
                style: AppText.arial(38 * s, color: AppColors.textGray)
                    .copyWith(height: 1.37)),
          ),
          Positioned(
            left: 116 * s,
            right: 116 * s,
            top: 500 * s,
            height: 120 * s,
            child: AppButton(
              s: s,
              label: 'Yes, oil replaced',
              kind: AppButtonKind.orange,
              size: AppButtonSize.medium,
              onTap: () {
                DeviceService.instance.markReplaced();
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            left: 116 * s,
            right: 116 * s,
            top: 642 * s,
            height: 120 * s,
            child: AppButton(
              s: s,
              label: 'Cancel',
              kind: AppButtonKind.outline,
              size: AppButtonSize.medium,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ]),
      );
    });
  }
}
