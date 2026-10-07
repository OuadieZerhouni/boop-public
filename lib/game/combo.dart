import 'package:flutter/foundation.dart';

/// A combo milestone worth celebrating (SPEC F2).
enum ComboTier { boopADoop, snootStorm, megaBoop }

@immutable
class ComboStep {
  const ComboStep({required this.count, this.tier, this.sneeze = false});

  /// The combo length including this boop (1 = a fresh boop).
  final int count;

  /// Set only on the boop that reaches a tier.
  final ComboTier? tier;

  /// Every 30th boop of a combo makes the critter sneeze.
  final bool sneeze;
}

/// Chains boops that land less than [window] apart. Pure and clock-injected.
class ComboTracker {
  ComboTracker({this.window = const Duration(milliseconds: 1000)});

  final Duration window;
  static const tiers = {10: ComboTier.boopADoop, 25: ComboTier.snootStorm, 50: ComboTier.megaBoop};
  static const sneezeEvery = 30;

  int _count = 0;
  DateTime? _last;

  int get count => _count;

  /// The live count at [now]: 0 once the window has lapsed.
  int countAt(DateTime now) => (_last != null && now.difference(_last!) <= window) ? _count : 0;

  ComboStep boop(DateTime now) {
    final chained = _last != null && now.difference(_last!) <= window;
    _count = chained ? _count + 1 : 1;
    _last = now;
    return ComboStep(count: _count, tier: tiers[_count], sneeze: _count % sneezeEvery == 0);
  }

  void reset() {
    _count = 0;
    _last = null;
  }
}

/// Squeak pitch step for a critter's [base] pitch at combo [count]: rises one
/// semitone every 3 boops, capped at +7 (the rendered range is 0–13).
int boopPitchIndex(int base, int count) {
  final rise = ((count - 1) ~/ 3).clamp(0, 7);
  return (base + rise).clamp(0, 18);
}
