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

/// MOCK DATA. Later, replace this with data from your device/backend
/// (e.g. a ReadingService) and the UI stays the same.
const mockHistory = [
  ReadingGroup('Today, June 14', [
    Reading('3:12 PM', 'Very High Degraded', 88, Severity.veryHigh),
    Reading('2:31 PM', 'High Degraded', 71, Severity.high),
    Reading('10:30 AM', 'Moderate Degraded', 43, Severity.moderate),
    Reading('9:30 AM', 'Low Degraded', 18, Severity.low),
  ]),
  ReadingGroup('Yesterday, June 13', [
    Reading('9:30 PM', 'Fresh Oil', 7, Severity.low),
    Reading('7:30 PM', 'Fresh Oil', 1, Severity.low),
  ]),
];

/// ASSUMED thresholds (matches your Test History samples). Change if your group uses others.
Severity severityFromOdi(int odi) {
  if (odi >= 80) return Severity.veryHigh;
  if (odi >= 60) return Severity.high;
  if (odi >= 30) return Severity.moderate;
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
