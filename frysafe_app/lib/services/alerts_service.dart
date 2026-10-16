import 'package:flutter/foundation.dart';
import '../models/reading.dart' show formatClock;

enum AlertKind { checkOil, offline, lowLife, lifeUpdated }

class AlertItem {
  final int id;
  final AlertKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  const AlertItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  /// 0 = today, 1 = yesterday, 3 = 3 days ago ...
  int get dayOffset {
    final now = DateTime.now();
    final days = (DateTime(now.year, now.month, now.day)
                .difference(DateTime(createdAt.year, createdAt.month, createdAt.day))
                .inHours /
            24)
        .round();
    return days < 0 ? 0 : days;
  }

  /// e.g. "12:00 PM"
  String get time => formatClock(createdAt);

  AlertItem copyWith({bool? read}) => AlertItem(
        id: id,
        kind: kind,
        title: title,
        body: body,
        createdAt: createdAt,
        read: read ?? this.read,
      );
}

/// Alerts are created by [DeviceService] when something really happens
/// (new reading, oil replaced, probe offline). The screen only listens to [alerts].
class AlertsService {
  AlertsService._();
  static final instance = AlertsService._();

  /// Newest first.
  final alerts = ValueNotifier<List<AlertItem>>(const []);
  int _nextId = 1;

  void add({
    required AlertKind kind,
    required String title,
    required String body,
    DateTime? at,
    bool read = false,
  }) {
    final item = AlertItem(
      id: _nextId++,
      kind: kind,
      title: title,
      body: body,
      createdAt: at ?? DateTime.now(),
      read: read,
    );
    final list = [item, ...alerts.value]..sort((a, b) {
        final c = b.createdAt.compareTo(a.createdAt);
        return c != 0 ? c : b.id.compareTo(a.id);
      });
    alerts.value = list;
  }

  int get unread => alerts.value.where((a) => !a.read).length;

  bool hasUnread(AlertKind kind) =>
      alerts.value.any((a) => a.kind == kind && !a.read);

  void markRead(int id) => alerts.value = [
        for (final a in alerts.value) a.id == id ? a.copyWith(read: true) : a
      ];

  void markKindRead(AlertKind kind) => alerts.value = [
        for (final a in alerts.value) a.kind == kind ? a.copyWith(read: true) : a
      ];

  void markAllRead() =>
      alerts.value = [for (final a in alerts.value) a.copyWith(read: true)];
}
