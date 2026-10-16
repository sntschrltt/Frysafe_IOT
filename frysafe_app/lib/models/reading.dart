import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum Severity { veryHigh, high, moderate, low }

extension SeverityStyle on Severity {
  Color get color => switch (this) {
        Severity.veryHigh => AppColors.veryHigh,
        Severity.high => AppColors.high,
        Severity.moderate => AppColors.moderate,
        Severity.low => AppColors.low,
      };

  String get badge => switch (this) {
        Severity.veryHigh => 'VERY HIGH',
        Severity.high => 'HIGH',
        Severity.moderate => 'MODERATE',
        Severity.low => 'LOW',
      };
}

class Reading {
  final String time; // e.g. "3:12 PM"
  final String label; // e.g. "Very High Degraded", "Fresh Oil"
  final int odi; // percent
  final Severity severity;
  const Reading(this.time, this.label, this.odi, this.severity);
}

class ReadingGroup {
  final String title; // e.g. "Today, June 14"
  final List<Reading> readings;
  const ReadingGroup(this.title, this.readings);
}

/// ODI levels (same as the About screen): 0-24 Low, 25-49 Moderate, 50-74 High, 75-100 Very High.
Severity severityFromOdi(int odi) {
  if (odi >= 75) return Severity.veryHigh;
  if (odi >= 50) return Severity.high;
  if (odi >= 25) return Severity.moderate;
  return Severity.low;
}

extension SeverityHeadline on Severity {
  String get headline => switch (this) {
        Severity.veryHigh => 'DANGER – Replace Now',
        Severity.high => 'WARNING – Replace Soon',
        Severity.moderate => 'CAUTION – Monitor Oil',
        Severity.low => 'GOOD – Oil Is Fine',
      };
}

extension SeverityName on Severity {
  /// "Very High", "High", "Moderate", "Low" (for sentences, not badges).
  String get title => switch (this) {
        Severity.veryHigh => 'Very High',
        Severity.high => 'High',
        Severity.moderate => 'Moderate',
        Severity.low => 'Low',
      };
}

/// ODI under 10 counts as brand-new oil.
bool isFreshOdi(int odi) => odi < 10;

/// Label shown on every History card.
String labelFromOdi(int odi) {
  if (isFreshOdi(odi)) return 'Fresh Oil';
  return switch (severityFromOdi(odi)) {
    Severity.veryHigh => 'Very High Degraded',
    Severity.high => 'High Degraded',
    Severity.moderate => 'Moderate Degraded',
    Severity.low => 'Low Degraded',
  };
}

/// "3:12 PM"
String formatClock(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
}
