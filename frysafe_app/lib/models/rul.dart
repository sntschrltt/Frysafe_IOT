import 'dart:math' as math;

/// ODI level where the About screen says "Oil is unsafe. Replace immediately."
const kOdiReplaceLimit = 75;

/// Fallback rise in ODI per frying cycle, used until real reading history
/// exists. 8 matches the mock alerts ("ODI 43% -> about 4 cycles left").
/// Replace with a slope computed from the readings since the last oil change.
const kDefaultOdiPerCycle = 8.0;

class RulEstimate {
  /// Estimated frying cycles left. 0 when [replaceNow].
  final int cycles;
  final bool replaceNow;
  const RulEstimate({required this.cycles, required this.replaceNow});

  String get headline {
    if (replaceNow) return 'Replace now';
    return '~$cycles frying ${cycles == 1 ? 'cycle' : 'cycles'} left';
  }
}

/// RUL (cycles) = (limit - ODI now) / ODI rise per cycle, rounded up, min 1.
/// Pass [odiPerCycle] once you can compute it from history; if it is null or
/// not positive, [kDefaultOdiPerCycle] is used.
RulEstimate estimateRul(int odi, {double? odiPerCycle}) {
  if (odi >= kOdiReplaceLimit) {
    return const RulEstimate(cycles: 0, replaceNow: true);
  }
  final slope = (odiPerCycle != null && odiPerCycle > 0)
      ? odiPerCycle
      : kDefaultOdiPerCycle;
  final cycles = math.max(1, ((kOdiReplaceLimit - odi) / slope).ceil());
  return RulEstimate(cycles: cycles, replaceNow: false);
}
