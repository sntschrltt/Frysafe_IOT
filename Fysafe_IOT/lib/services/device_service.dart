import 'package:flutter/foundation.dart';

enum HomeStatus { notConnected, connected, loading, result }

class Measurement {
  final int odi; // percent
  final double rdr; // color
  final double ntu; // turbidity
  const Measurement({required this.odi, required this.rdr, required this.ntu});
}

/// Current bottom-nav tab: 0 Home, 1 History, 2 Alerts, 3 About
final appTab = ValueNotifier<int>(0);

/// MOCK service. Later, replace the fake parts with the real WiFi/ESP32 calls;
/// the screens only listen to [status] and read [latest].
class DeviceService {
  DeviceService._();
  static final instance = DeviceService._();

  final status = ValueNotifier<HomeStatus>(HomeStatus.notConnected);
  Measurement? latest;

  static const deviceName = 'Frysafe Device';
  static const ipAddress = '192.168.1.108';
  static const networkName = 'FrySafe Probe 0.1';

  /// Liters of oil the user logged today (mock start value).
  final todayLiters = ValueNotifier<double>(2.3);

  /// Oil change dates, newest first (mock: every 2 days, last one yesterday).
  final replacements = ValueNotifier<List<DateTime>>(_seedReplacements());

  static List<DateTime> _seedReplacements() {
    final n = DateTime.now().subtract(const Duration(days: 1));
    final last = DateTime(n.year, n.month, n.day, 14, 10);
    return [for (var i = 0; i < 4; i++) last.subtract(Duration(days: 2 * i))];
  }

  void addUsage(double liters) => todayLiters.value += liters;
  void markReplaced() => replacements.value = [DateTime.now(), ...replacements.value];

  DateTime? get lastReplaced =>
      replacements.value.isEmpty ? null : replacements.value.first;

  /// Average days between oil changes (null if fewer than 2 logged).
  int? get avgIntervalDays {
    final r = replacements.value;
    if (r.length < 2) return null;
    final days = r.first.difference(r.last).inHours / 24 / (r.length - 1);
    return days.round().clamp(1, 999);
  }

  void markPaired() => status.value = HomeStatus.connected;

  /// Demo: pretend the probe was put in the oil (tap the card while "Monitoring Active").
  Future<void> simulateProbeInserted() async {
    if (status.value != HomeStatus.connected) return;
    status.value = HomeStatus.loading;
    await Future.delayed(const Duration(seconds: 2));
    if (status.value != HomeStatus.loading) return;
    latest = const Measurement(odi: 72, rdr: 0.72, ntu: 2.4);
    status.value = HomeStatus.result;
  }

  /// Demo: long-press the "FRYSAFE" title to go back to "not connected".
  void reset() {
    latest = null;
    status.value = HomeStatus.notConnected;
  }
}

const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'];

String relativeDay(DateTime d) {
  final now = DateTime.now();
  final diff = DateTime(now.year, now.month, now.day)
      .difference(DateTime(d.year, d.month, d.day))
      .inDays;
  if (diff <= 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '$diff days ago';
}

String formatDateTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '${_months[d.month - 1]} ${d.day}, ${d.year}, $h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
}
