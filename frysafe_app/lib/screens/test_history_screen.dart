import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../services/device_service.dart';
import '../theme/app_theme.dart';
import '../widgets/header_shell.dart';
import '../widgets/reading_card.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  int _tab = 0; // 0 List, 1 Trends

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Measurement>>(
      valueListenable: DeviceService.instance.readings,
      builder: (context, readings, _) {
        final groups = _group(readings);
        return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 1080; // design is 1080 px wide
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Scrollable content (goes under header and nav)
            Positioned.fill(
              child: ListView(
                padding: EdgeInsets.only(
                    top: AppLayout.headerHeight * s,
                    bottom: AppLayout.navClearance * s),
                children: [
                  // List | Trends toggle
                  Padding(
                    padding: EdgeInsets.fromLTRB(90 * s, 44 * s, 92 * s, 0),
                    child: _SegToggle(
                      s: s,
                      index: _tab,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                  ),
                  if (_tab == 0) ...[
                    if (groups.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 80 * s),
                        child: Center(
                          child: Text('No readings yet',
                              style: AppText.dmSans(34 * s,
                                  color: AppColors.textGray)),
                        ),
                      ),
                    for (var i = 0; i < groups.length; i++) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            90 * s, i == 0 ? 50 * s : 62 * s, 90 * s, 26 * s),
                        child: Text(groups[i].title,
                            style:
                                AppText.arial(38 * s, weight: FontWeight.bold)),
                      ),
                      for (final r in groups[i].readings)
                        Padding(
                          padding:
                              EdgeInsets.fromLTRB(90 * s, 0, 92 * s, 21 * s),
                          child: ReadingCard(reading: r, s: s),
                        ),
                    ],
                  ] else
                    Padding(
                      padding: EdgeInsets.fromLTRB(90 * s, 44 * s, 92 * s, 0),
                      child: _TrendsView(s: s, readings: readings),
                    ),
                ],
              ),
            ),
            // Gray fade above the bottom nav
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 750 * s,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00B4B4B4),
                        Color(0x80B4B4B4),
                        Color(0x80B4B4B4)
                      ],
                      stops: [0, 0.656, 1],
                    ),
                  ),
                ),
              ),
            ),
            AppHeader(
              s: s,
              title: 'TEST HISTORY',
              subtitle: 'All recorded readings',
              actionIcon: Icons.file_download_outlined,
            ),
          ],
        ),
      );
    });
      },
    );
  }
}

// ───────────────────────── List | Trends toggle ─────────────────────────

class _SegToggle extends StatelessWidget {
  final double s;
  final int index;
  final ValueChanged<int> onChanged;
  const _SegToggle(
      {required this.s, required this.index, required this.onChanged});

  Widget _seg(String label, int i) {
    final selected = index == i;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(34 * s),
            border: Border.all(
                color: selected ? AppColors.border : Colors.transparent,
                width: 3 * s),
          ),
          child: Text(label,
              style: AppText.dmSans(36 * s,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.black : AppColors.textGray)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128 * s,
      padding: EdgeInsets.all(8 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE8DC),
        borderRadius: BorderRadius.circular(42 * s),
        border: Border.all(color: AppColors.border, width: 3 * s),
      ),
      child: Row(children: [_seg('List', 0), _seg('Trends', 1)]),
    );
  }
}

// ───────────────────────────── Trends view ─────────────────────────────

const _mons = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String _fmtDate(DateTime d) => '${_mons[d.month - 1]} ${d.day}';

String _hourLabel(double h) {
  final x = h.round() % 24;
  if (x == 0) return '12AM';
  if (x < 12) return '${x}AM';
  if (x == 12) return '12PM';
  return '${x - 12}PM';
}

class _Pt {
  final double x;
  final double odi;
  final String label; // shown in tooltip (time or date)
  final Severity sev;
  final bool fresh;
  const _Pt(this.x, this.odi, this.label, this.sev, this.fresh);
}

class _Tick {
  final double x;
  final String label;
  const _Tick(this.x, this.label);
}

class _TrendData {
  final List<_Pt> pts;
  final List<_Tick> ticks;
  final double xMin, xMax;
  final String range;
  final bool showFresh;
  const _TrendData(
      this.pts, this.ticks, this.xMin, this.xMax, this.range, this.showFresh);
}

const _fullMonths = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'
];
const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];

/// "Today, June 14" / "Yesterday, June 13" / "Monday, June 10"
String _dayTitle(DateTime d) {
  final today = dayOnly(DateTime.now());
  final date = '${_fullMonths[d.month - 1]} ${d.day}';
  if (d == today) return 'Today, $date';
  if (d == shiftDay(today, -1)) return 'Yesterday, $date';
  return '${_weekdayNames[d.weekday - 1]}, $date';
}

/// Groups the shared readings (newest first) by day for the List tab.
List<ReadingGroup> _group(List<Measurement> list) {
  final groups = <ReadingGroup>[];
  DateTime? day;
  var bucket = <Reading>[];
  for (final m in list) {
    final d = dayOnly(m.time);
    if (day == null || d != day) {
      if (day != null) groups.add(ReadingGroup(_dayTitle(day), bucket));
      day = d;
      bucket = [];
    }
    bucket.add(Reading(
        formatClock(m.time), labelFromOdi(m.odi), m.odi, severityFromOdi(m.odi)));
  }
  if (day != null) groups.add(ReadingGroup(_dayTitle(day), bucket));
  return groups;
}

/// Builds the chart data from the shared readings (newest first).
/// Week = daily average for the last 7 days. Day = every reading from
/// yesterday and today.
_TrendData _buildData(List<Measurement> all, bool week) {
  if (all.isEmpty) return const _TrendData([], [], 0, 1, '', false);
  final today = dayOnly(DateTime.now());

  if (week) {
    final pts = <_Pt>[];
    for (var slot = 0; slot < 7; slot++) {
      final d = shiftDay(today, slot - 6);
      final list = all.where((m) => dayOnly(m.time) == d).toList();
      if (list.isEmpty) continue;
      var sum = 0.0;
      for (final m in list) {
        sum += m.odi.toDouble();
      }
      final avg = sum / list.length;
      pts.add(_Pt(slot.toDouble(), avg, _fmtDate(d),
          severityFromOdi(avg.round()), false));
    }
    final ticks = [
      for (var k = 0; k < 7; k++) _Tick(k.toDouble(), _fmtDate(shiftDay(today, k - 6)))
    ];
    return _TrendData(pts, ticks, 0, 6,
        '${_fmtDate(shiftDay(today, -6))} – ${_fmtDate(today)}', false);
  }

  final yesterday = shiftDay(today, -1);
  final pts = <_Pt>[];
  for (final m in all.reversed) {
    final d = dayOnly(m.time);
    if (d != today && d != yesterday) continue;
    final h = m.time.hour + m.time.minute / 60;
    pts.add(_Pt((d == today ? 24 : 0) + h, m.odi.toDouble(), formatClock(m.time),
        severityFromOdi(m.odi), isFreshOdi(m.odi)));
  }
  if (pts.isEmpty) return const _TrendData([], [], 0, 1, '', false);
  final firstDay = pts.first.x >= 24 ? today : yesterday;
  final lastDay = pts.last.x >= 24 ? today : yesterday;
  final range = firstDay == lastDay
      ? _fmtDate(lastDay)
      : '${_fmtDate(firstDay)} – ${_fmtDate(lastDay)}';

  final xMin = pts.first.x, xMax = pts.last.x;
  final ticks = <_Tick>[_Tick(xMin, pts.first.label.replaceAll(' ', ''))];
  for (var t = (xMin / 6).ceil() * 6.0; t <= xMax; t += 6) {
    if ((t - xMin).abs() < 3) continue;
    ticks.add(_Tick(t, _hourLabel(t % 24)));
  }
  return _TrendData(pts, ticks, xMin, xMax, range, pts.first.fresh);
}

class _TrendsView extends StatefulWidget {
  final double s;
  final List<Measurement> readings;
  const _TrendsView({required this.s, required this.readings});

  @override
  State<_TrendsView> createState() => _TrendsViewState();
}

class _TrendsViewState extends State<_TrendsView> {
  bool _week = false;
  int? _sel; // null = latest point

  @override
  void didUpdateWidget(covariant _TrendsView old) {
    super.didUpdateWidget(old);
    // a new reading arrived: jump back to the latest point
    if (!identical(old.readings, widget.readings)) _sel = null;
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    final s = widget.s;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 80 * s,
        padding: EdgeInsets.symmetric(horizontal: 46 * s),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A1A1A) : AppColors.surface,
          borderRadius: BorderRadius.circular(40 * s),
          border: Border.all(
              color: active ? const Color(0xFF1A1A1A) : AppColors.border,
              width: 3 * s),
        ),
        child: Text(label,
            style: AppText.dmSans(30 * s,
                weight: FontWeight.w600,
                color: active ? Colors.white : AppColors.textGray)),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    final s = widget.s;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 24 * s,
          height: 24 * s,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      SizedBox(width: 10 * s),
      Text(label, style: AppText.arial(26 * s, color: AppColors.textGray)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final data = _buildData(widget.readings, _week);
    final sel = (_sel != null && _sel! < data.pts.length)
        ? _sel!
        : data.pts.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _chip('Day', !_week, () => setState(() {
                _week = false;
                _sel = null;
              })),
          SizedBox(width: 18 * s),
          _chip('Week', _week, () => setState(() {
                _week = true;
                _sel = null;
              })),
        ]),
        SizedBox(height: 32 * s),
        Container(
          padding: EdgeInsets.fromLTRB(36 * s, 36 * s, 36 * s, 34 * s),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(48 * s),
            border: Border.all(color: AppColors.border, width: 3 * s),
          ),
          child: Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('ODI over time',
                    style: AppText.dmSans(38 * s, weight: FontWeight.w700)),
                const Spacer(),
                Text(data.range,
                    style: AppText.arial(27 * s, color: AppColors.textGray)),
              ],
            ),
            SizedBox(height: 28 * s),
            if (data.pts.isEmpty)
              SizedBox(
                height: 400 * s,
                child: Center(
                  child: Text('No readings yet',
                      style:
                          AppText.dmSans(34 * s, color: AppColors.textGray)),
                ),
              )
            else
              LayoutBuilder(builder: (context, c) {
                final size = Size(c.maxWidth, 600 * s);
                final geom = _Geom(size, s, data.xMin, data.xMax);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) {
                    var best = 0;
                    var bestDist = double.infinity;
                    for (var i = 0; i < data.pts.length; i++) {
                      final dist =
                          (geom.xOf(data.pts[i].x) - d.localPosition.dx).abs();
                      if (dist < bestDist) {
                        bestDist = dist;
                        best = i;
                      }
                    }
                    setState(() => _sel = best);
                  },
                  child: CustomPaint(
                    size: size,
                    painter: _TrendPainter(
                        s: s, data: data, geom: geom, selected: sel),
                  ),
                );
              }),
            SizedBox(height: 26 * s),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 36 * s,
              runSpacing: 12 * s,
              children: [
                _legendItem('Low', AppColors.low),
                _legendItem('Moderate', const Color(0xFFE0A800)),
                _legendItem('High', AppColors.high),
                _legendItem('Very High', AppColors.veryHigh),
              ],
            ),
          ]),
        ),
      ],
    );
  }
}

// ───────────────────────────── Chart painter ─────────────────────────────

class _Geom {
  final Size size;
  final double s;
  final double xMin, xMax;
  const _Geom(this.size, this.s, this.xMin, this.xMax);

  Rect get plot =>
      Rect.fromLTRB(70 * s, 16 * s, size.width, size.height - 56 * s);

  double xOf(double x) {
    final l = plot.left + 24 * s;
    final r = plot.right - 30 * s;
    final span = xMax - xMin;
    if (span <= 0) return (l + r) / 2;
    return l + (x - xMin) / span * (r - l);
  }

  double yOf(double odi) =>
      plot.bottom - odi.clamp(0.0, 100.0) / 100 * plot.height;
}

class _TrendPainter extends CustomPainter {
  final double s;
  final _TrendData data;
  final _Geom geom;
  final int selected;
  const _TrendPainter(
      {required this.s,
      required this.data,
      required this.geom,
      required this.selected});

  static const _moderate = Color(0xFFE0A800);

  TextPainter _tp(String t, TextStyle st) => TextPainter(
        text: TextSpan(text: t, style: st),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final plot = geom.plot;

    // Severity bands (0-25 low, 25-50 moderate, 50-75 high, 75-100 very high)
    final bands = <(double, double, Color)>[
      (0, 25, AppColors.low),
      (25, 50, _moderate),
      (50, 75, AppColors.high),
      (75, 100, AppColors.veryHigh),
    ];
    for (final b in bands) {
      canvas.drawRect(
        Rect.fromLTRB(plot.left, geom.yOf(b.$2), plot.right, geom.yOf(b.$1)),
        Paint()..color = b.$3.withValues(alpha: 0.2),
      );
    }

    // Axes
    final axis = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2 * s;
    canvas.drawLine(plot.topLeft, plot.bottomLeft, axis);
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, axis);

    // Y labels
    for (final v in [0, 25, 50, 75, 100]) {
      final tp = _tp('$v', AppText.arial(23 * s, color: AppColors.textGray));
      tp.paint(canvas,
          Offset(plot.left - 12 * s - tp.width, geom.yOf(v.toDouble()) - tp.height / 2));
    }

    // X labels
    for (final t in data.ticks) {
      final tp = _tp(t.label, AppText.arial(23 * s, color: AppColors.textGray));
      var dx = geom.xOf(t.x) - tp.width / 2;
      dx = dx.clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(dx, plot.bottom + 16 * s));
    }

    final pts = data.pts;

    // "Fresh oil" dashed marker on the first point
    if (data.showFresh && pts.isNotEmpty) {
      final x = geom.xOf(pts.first.x);
      final p = Paint()
        ..color = AppColors.black
        ..strokeWidth = 3 * s;
      var y = plot.top;
      while (y < plot.bottom) {
        canvas.drawLine(Offset(x, y),
            Offset(x, (y + 8 * s).clamp(plot.top, plot.bottom)), p);
        y += 14 * s;
      }
      final tp = _tp('Fresh oil',
          AppText.arial(20 * s, weight: FontWeight.bold, color: AppColors.low));
      tp.paint(canvas, Offset(x + 8 * s, plot.top + 8 * s));
    }

    // Line
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final o = Offset(geom.xOf(pts[i].x), geom.yOf(pts[i].odi));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 * s
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Dots
    for (var i = 0; i < pts.length; i++) {
      final o = Offset(geom.xOf(pts[i].x), geom.yOf(pts[i].odi));
      final big = i == selected;
      final dotColor =
          pts[i].sev == Severity.moderate ? _moderate : pts[i].sev.color;
      canvas.drawCircle(o, (big ? 19 : 12) * s, Paint()..color = dotColor);
      if (!big) {
        canvas.drawCircle(
            o,
            12 * s,
            Paint()
              ..color = AppColors.surface
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2 * s);
      }
    }

    // Tooltip for the selected point
    if (pts.isNotEmpty) {
      final p = pts[selected];
      final o = Offset(geom.xOf(p.x), geom.yOf(p.odi));
      final top = _tp(p.label,
          AppText.arial(22 * s, color: const Color(0xCCFFFFFF)));
      final bottom = _tp('ODI ${p.odi.round()}%',
          AppText.dmSans(32 * s, weight: FontWeight.w700, color: Colors.white));
      final padX = 22 * s, padY = 16 * s;
      final w = (top.width > bottom.width ? top.width : bottom.width) + padX * 2;
      final h = top.height + 6 * s + bottom.height + padY * 2;

      var bx = o.dx - w - 24 * s;
      if (bx < plot.left + 4 * s) bx = o.dx + 24 * s;
      bx = bx.clamp(plot.left + 4 * s, size.width - w - 4 * s);
      var by = o.dy - h / 2 - 6 * s;
      by = by.clamp(plot.top + 4 * s, plot.bottom - h - 4 * s);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(bx, by, w, h), Radius.circular(18 * s)),
        Paint()..color = const Color(0xFF1A1A1A),
      );
      top.paint(canvas, Offset(bx + padX, by + padY));
      bottom.paint(canvas, Offset(bx + padX, by + padY + top.height + 6 * s));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => true;
}
