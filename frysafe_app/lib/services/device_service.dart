import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/reading.dart';
import '../models/rul.dart';
import 'alerts_service.dart';

enum HomeStatus { notConnected, connected, loading, result }

class Measurement {
  final int odi; // percent
  final int r; // color: red channel frequency (Hz)
  final int g; // color: green channel frequency (Hz)
  final int b; // color: blue channel frequency (Hz)
  final double mv; // turbidity (millivolts)
  final DateTime time; // when the reading was taken
  const Measurement({
    required this.odi,
    required this.r,
    required this.g,
    required this.b,
    required this.mv,
    required this.time,
  });
}

/// One finished oil life (Analytics "Oil Replacement Frequency" bar).
class ReplacementStat {
  final DateTime date; // when the oil was replaced
  final int uses; // tests (= frying cycles) logged on that oil
  final double gapDays; // days since the previous replacement
  const ReplacementStat(this.date, this.uses, this.gapDays);
}

/// Current bottom-nav tab: 0 Home, 1 History, 2 Alerts, 3 Analytics
final appTab = ValueNotifier<int>(0);

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// [d] moved by [days] calendar days (negative = back), at midnight.
DateTime shiftDay(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

/// ONE place for all the app's data. Home, History, Trends, Alerts and
/// Analytics all read from here, so they always agree:
///  - [readings]     every test (newest first)  -> History, Trends, RUL
///  - [replacements] oil changes (newest first) -> Analytics, Home, RUL reset
///  - [usage]        liters per day             -> Analytics, Home
///  - Alerts are created from real events (new reading, oil replaced, offline)
///
/// MOCK service. Later, replace the fake parts with the real WiFi/ESP32 calls
/// (call [addReading] with each real measurement); the screens only listen.
class DeviceService {
  DeviceService._() {
    _seed();
  }
  static final instance = DeviceService._();

  final status = ValueNotifier<HomeStatus>(HomeStatus.notConnected);
  Measurement? latest;

  /// Every reading ever taken, newest first.
  final readings = ValueNotifier<List<Measurement>>(const []);

  /// Oil change dates, newest first.
  final replacements = ValueNotifier<List<DateTime>>(const []);

  /// Liters of oil used per day (key = date only).
  final usage = ValueNotifier<Map<DateTime, double>>(const {});

  /// Liters the user logged today.
  final todayLiters = ValueNotifier<double>(0);

  /// How long the Home "Replacement Needed Soon" banner stays on screen.
  static const bannerDuration = Duration(seconds: 10);

  /// true = Home shows the replacement banner (auto-hides after [bannerDuration]).
  final bannerVisible = ValueNotifier<bool>(false);
  Timer? _bannerTimer;

  void _showBannerTemporarily() {
    _bannerTimer?.cancel();
    bannerVisible.value = true;
    _bannerTimer = Timer(bannerDuration, () => bannerVisible.value = false);
  }

  void _hideBanner() {
    _bannerTimer?.cancel();
    bannerVisible.value = false;
  }

  static const deviceName = 'FRYSAFE Device';
  static const ipAddress = '192.168.1.108';
  static const networkName = 'FRYSAFE Probe 0.1';

  // ───────────────────────── mock starting data ─────────────────────────

  /// Fake sensor numbers that follow the ODI (darker / cloudier oil = higher ODI).
  Measurement _measure(int odi, DateTime at) {
    int hz(double v) => (v / 10).round() * 10;
    return Measurement(
      odi: odi,
      r: hz(9000 - odi * 60),
      g: hz(8000 - odi * 45),
      b: hz(2500 - odi * 15),
      mv: double.parse((0.4 + odi * 0.028).toStringAsFixed(1)),
      time: at,
    );
  }

  void _seed() {
    final now = DateTime.now();

    // Oil changes (newest first): last one 20 h ago, older ones 2-3 days apart.
    var t = now.subtract(const Duration(hours: 20));
    final reps = <DateTime>[t];
    for (final gap in const [2, 3, 2, 2, 3]) {
      t = t.subtract(Duration(days: gap));
      reps.add(t);
    }
    replacements.value = reps;

    // Readings. reps[j+1] -> reps[j] is one finished oil life: ODI climbs
    // from fresh to its peak, then the oil gets replaced.
    final all = <Measurement>[];
    const uses = [5, 6, 4, 7, 5];
    const peaks = [74, 81, 66, 79, 70];
    for (var j = 0; j < uses.length; j++) {
      final start = reps[j + 1], end = reps[j];
      final span = end.difference(start).inMinutes;
      for (var k = 0; k < uses[j]; k++) {
        final at = start.add(Duration(minutes: span * (k + 1) ~/ (uses[j] + 1)));
        final odi = (3 + (peaks[j] - 3) * k / (uses[j] - 1)).round();
        all.add(_measure(odi, at));
      }
    }
    // The oil in use now (changed 20 h ago).
    for (final (hoursAgo, odi) in const [(19, 1), (16, 7), (9, 18), (5, 31), (2, 43)]) {
      all.add(_measure(odi, now.subtract(Duration(hours: hoursAgo))));
    }
    all.sort((a, b) => b.time.compareTo(a.time));
    readings.value = all;

    // Liters per day (previous 29 days) + today so far.
    const pattern = [10.0, 11.0, 5.0, 7.0, 14.0, 10.5, 14.5];
    final today = dayOnly(now);
    final u = <DateTime, double>{};
    for (var d = 29; d >= 1; d--) {
      u[shiftDay(today, -d)] = pattern[d % 7] + ((d ~/ 7) % 3 - 1) * 0.5;
    }
    u[today] = 2.3;
    usage.value = u;
    todayLiters.value = 2.3;

    // Alerts from the same data.
    final life = all.where((m) => m.time.isAfter(reps.first)).toList()
      ..sort((a, b) => a.time.compareTo(b.time)); // oldest -> newest
    for (var i = life.length - 2; i < life.length; i++) {
      _lifeAlert(life.sublist(0, i + 1), at: life[i].time, read: true);
    }
    final lastCheck = all.first;
    final alerts = AlertsService.instance;
    alerts.add(
      kind: AlertKind.offline,
      title: 'Probe is offline',
      body: 'FRYSAFE lost Wi-Fi. Readings will not sync until it reconnects.',
    );
    alerts.add(
      kind: AlertKind.checkOil,
      title: "How's your oil today?",
      body:
          'Your last check was ${relativeTime(lastCheck.time)} (ODI ${lastCheck.odi}%). Dip the probe and push DETECT to see how it is now.',
    );
  }

  // ───────────────────────── remaining useful life ─────────────────────────

  /// Readings since the last oil change, oldest first.
  List<Measurement> get currentLife {
    final since = lastReplaced;
    final list = readings.value
        .where((m) => since == null || m.time.isAfter(since))
        .toList();
    return list.reversed.toList();
  }

  /// ODI rise per frying cycle on the oil in use (each test = one cycle).
  /// null until there are 2+ readings since the last change (then RUL uses
  /// its default slope).
  double? get odiPerCycle => _slope(currentLife);

  double? _slope(List<Measurement> life) {
    if (life.length < 2) return null;
    final rise = (life.last.odi - life.first.odi) / (life.length - 1);
    return rise > 0 ? rise : null;
  }

  /// Creates the "remaining life" alert for the newest reading in [life]
  /// (oldest -> newest).
  void _lifeAlert(List<Measurement> life, {DateTime? at, bool read = false}) {
    final m = life.last;
    final sev = severityFromOdi(m.odi);
    final est = estimateRul(m.odi, odiPerCycle: _slope(life));
    final alerts = AlertsService.instance;
    if (est.replaceNow) {
      alerts.add(
        kind: AlertKind.lowLife,
        title: 'Replace oil now',
        body: 'ODI ${m.odi}% (${sev.title}). Oil is unsafe. Replace it immediately.',
        at: at,
        read: read,
      );
      return;
    }
    final left =
        'About ${est.cycles} frying ${est.cycles == 1 ? 'cycle' : 'cycles'} left';
    if (est.cycles <= 2) {
      alerts.add(
        kind: AlertKind.lowLife,
        title: 'Oil is running out of life',
        body: 'ODI ${m.odi}% (${sev.title}). $left before the $kOdiReplaceLimit limit.',
        at: at,
        read: read,
      );
    } else {
      alerts.add(
        kind: AlertKind.lifeUpdated,
        title: 'Remaining life updated',
        body: 'ODI ${m.odi}% (${sev.title}). $left.',
        at: at,
        read: read,
      );
    }
  }

  // ───────────────────────── oil usage / replacements ─────────────────────────

  void addUsage(double liters) {
    final today = dayOnly(DateTime.now());
    final u = Map<DateTime, double>.from(usage.value);
    u[today] = (u[today] ?? 0) + liters;
    usage.value = u;
    todayLiters.value = u[today]!;
  }

  /// Liters per day for the last [n] days, oldest first (last item = today).
  List<double> usageLastDays(int n) {
    final today = dayOnly(DateTime.now());
    return [
      for (var i = n - 1; i >= 0; i--) usage.value[shiftDay(today, -i)] ?? 0.0
    ];
  }

  /// Logs a new oil change and restarts the remaining-life estimate.
  void markReplaced() {
    replacements.value = [DateTime.now(), ...replacements.value];
    _hideBanner();
    if (status.value == HomeStatus.result) {
      latest = null; // new oil: no reading yet, so no RUL yet
      status.value = HomeStatus.connected;
    }
    AlertsService.instance.add(
      kind: AlertKind.lifeUpdated,
      title: 'Oil change logged',
      body: 'Remaining life restarted. Test the new oil to start tracking it.',
    );
  }

  DateTime? get lastReplaced =>
      replacements.value.isEmpty ? null : replacements.value.first;

  /// Average days between oil changes (null if fewer than 2 logged).
  int? get avgIntervalDays {
    final r = replacements.value;
    if (r.length < 2) return null;
    final days = r.first.difference(r.last).inHours / 24 / (r.length - 1);
    return days.round().clamp(1, 999);
  }

  /// One entry per finished oil life, newest first.
  List<ReplacementStat> get replacementStats {
    final r = replacements.value;
    final reads = readings.value;
    return [
      for (var i = 0; i < r.length - 1; i++)
        ReplacementStat(
          r[i],
          reads
              .where((m) => m.time.isAfter(r[i + 1]) && !m.time.isAfter(r[i]))
              .length,
          r[i].difference(r[i + 1]).inMinutes / 1440,
        ),
    ];
  }

  // ───────────────────────── connection / monitoring ─────────────────────────

  void markPaired() {
    status.value = HomeStatus.connected;
    AlertsService.instance.markKindRead(AlertKind.offline);
  }

  /// Saves a new measurement everywhere: History, Trends, RUL and Alerts.
  /// The real ESP32 code should call this with each result.
  void addReading(Measurement m) {
    final life = currentLife; // before adding m
    latest = m;
    readings.value = [m, ...readings.value];
    _lifeAlert([...life, m]);
  }

  /// Demo: pretend the probe was put in the oil (tap the card while "Monitoring Active").
  Future<void> simulateProbeInserted() async {
    if (status.value != HomeStatus.connected) return;
    status.value = HomeStatus.loading;
    await Future.delayed(const Duration(seconds: 2));
    if (status.value != HomeStatus.loading) return;
    // Each test = one more frying cycle: ODI goes up from the last test on
    // this oil, or starts low if the oil is new.
    final life = currentLife;
    final rnd = math.Random();
    final odi = life.isEmpty
        ? 1 + rnd.nextInt(6)
        : math.min(100, life.last.odi + 6 + rnd.nextInt(7));
    final m = _measure(odi, DateTime.now());
    addReading(m);
    status.value = HomeStatus.result;
    final sev = severityFromOdi(m.odi);
    if (sev == Severity.high || sev == Severity.veryHigh) {
      _showBannerTemporarily();
    }
  }

  /// Demo: long-press the "FRYSAFE" title to go back to "not connected".
  void reset() {
    _hideBanner();
    latest = null;
    status.value = HomeStatus.notConnected;
    final alerts = AlertsService.instance;
    if (!alerts.hasUnread(AlertKind.offline)) {
      alerts.add(
        kind: AlertKind.offline,
        title: 'Probe is offline',
        body: 'FRYSAFE lost Wi-Fi. Readings will not sync until it reconnects.',
      );
    }
  }
}

const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'];

/// "Sept 18"
String shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String relativeDay(DateTime d) {
  final now = DateTime.now();
  final diff = DateTime(now.year, now.month, now.day)
      .difference(DateTime(d.year, d.month, d.day))
      .inDays;
  if (diff <= 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '$diff days ago';
}

/// "Just now", "3 min ago", "2 hr ago", then falls back to [relativeDay].
String relativeTime(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return relativeDay(d);
}

String formatDateTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '${_months[d.month - 1]} ${d.day}, ${d.year}, $h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
}
