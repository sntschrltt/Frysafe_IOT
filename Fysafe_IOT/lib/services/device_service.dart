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
