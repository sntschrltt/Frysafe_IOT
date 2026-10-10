import 'package:flutter/foundation.dart';

enum AlertKind { checkOil, offline, lowLife, lifeUpdated }

class AlertItem {
  final int id;
  final AlertKind kind;
  final String title;
  final String body;
  final String time; // e.g. "12:00 PM"
  final int dayOffset; // 0 = today, 1 = yesterday, 3 = 3 days ago ...
  final bool read;
  const AlertItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
    required this.dayOffset,
    this.read = false,
  });

  AlertItem copyWith({bool? read}) => AlertItem(
        id: id,
        kind: kind,
        title: title,
        body: body,
        time: time,
        dayOffset: dayOffset,
        read: read ?? this.read,
      );
}

/// MOCK alerts. Later, create them from real events (device offline,
/// ODI reached a level, no test in X days...). The screen only listens to [alerts].
class AlertsService {
  AlertsService._();
  static final instance = AlertsService._();

  final alerts = ValueNotifier<List<AlertItem>>(const [
    AlertItem(
      id: 1,
      kind: AlertKind.checkOil,
      title: "How's your oil today?",
      body:
          'Your last check was 3 days ago (ODI 71%). Dip the probe and push DETECT to see how it is now.',
      time: '12:00 PM',
      dayOffset: 0,
    ),
    AlertItem(
      id: 2,
      kind: AlertKind.offline,
      title: 'Probe is offline',
      body: 'FRYSAFE lost Wi-Fi. Readings will not sync until it reconnects.',
      time: '12:00 PM',
      dayOffset: 0,
    ),
    AlertItem(
      id: 3,
      kind: AlertKind.checkOil,
      title: "How's your oil today?",
      body:
          'Your last check was 2 days ago (ODI 71%). Dip the probe and push DETECT to see how it is now.',
      time: '12:00 PM',
      dayOffset: 1,
      read: true,
    ),
    AlertItem(
      id: 4,
      kind: AlertKind.lowLife,
      title: 'Oil is running out of life',
      body: 'ODI 71% (High). About 1 frying cycle left before the 75 limit.',
      time: '3:12 PM',
      dayOffset: 3,
      read: true,
    ),
    AlertItem(
      id: 5,
      kind: AlertKind.lifeUpdated,
      title: 'Remaining life updated',
      body: 'ODI 43% (Moderate). About 4 frying cycles left.',
      time: '10:30 AM',
      dayOffset: 3,
      read: true,
    ),
  ]);

  int get unread => alerts.value.where((a) => !a.read).length;

  void markRead(int id) => alerts.value = [
        for (final a in alerts.value) a.id == id ? a.copyWith(read: true) : a
      ];

  void markAllRead() =>
      alerts.value = [for (final a in alerts.value) a.copyWith(read: true)];
}
