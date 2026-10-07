import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'critters.dart';

/// `yyyy-mm-dd` of a *local* calendar day.
String dayKey(DateTime t) {
  final l = t.isUtc ? t.toLocal() : t;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${l.year.toString().padLeft(4, '0')}-${two(l.month)}-${two(l.day)}';
}

/// The day before [key] (calendar arithmetic, DST-safe: noon anchor).
String previousDayKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return dayKey(DateTime(p[0], p[1], p[2], 12).subtract(const Duration(days: 1)));
}

/// What one batch of boops changed — the UI turns this into celebrations.
@immutable
class BoopOutcome {
  const BoopOutcome({this.newUnlocks = const [], this.goalJustMet = false});
  final List<CritterSpecies> newUnlocks;
  final bool goalJustMet;
}

/// Everything the player has earned. Immutable value; [ProgressStore] owns it.
@immutable
class Progress {
  const Progress({
    this.lifetimeBoops = 0,
    this.perCritter = const {},
    this.selectedId = 'mochi',
    this.celebrated = const {'mochi'},
    this.bestCombo = 0,
    this.bestRush = 0,
    this.todayKey = '',
    this.todayBoops = 0,
    this.lastGoalDay = '',
    this.streak = 0,
    this.onboardingDone = false,
    this.reviewAsked = false,
    this.dismissedAnnouncements = const {},
  });

  final int lifetimeBoops;
  final Map<String, int> perCritter;
  final String selectedId;

  /// Critters whose unlock celebration has been shown (Mochi is a given).
  final Set<String> celebrated;
  final int bestCombo;
  final int bestRush;

  /// The local day [todayBoops] belongs to.
  final String todayKey;
  final int todayBoops;

  /// The last local day the daily goal was met, and the streak ending there.
  final String lastGoalDay;
  final int streak;

  final bool onboardingDone;
  final bool reviewAsked;
  final Set<String> dismissedAnnouncements;

  bool isUnlocked(CritterSpecies c) => c.unlockAt <= lifetimeBoops;
  int get unlockedCount => kCritters.where(isUnlocked).length;
  int boopsFor(String id) => perCritter[id] ?? 0;

  /// The selected critter, falling back to Mochi if the saved one is somehow
  /// locked (e.g. a hand-edited store).
  CritterSpecies get selected {
    final c = critterById(selectedId);
    return isUnlocked(c) ? c : kCritters.first;
  }

  /// Unlocked critters still waiting for their celebration, in unlock order.
  List<CritterSpecies> get pendingCelebrations =>
      [for (final c in kCritters) if (isUnlocked(c) && !celebrated.contains(c.id)) c];

  /// Today's boops as seen at [now] (0 once the stored day is over).
  int todayAt(DateTime now) => todayKey == dayKey(now) ? todayBoops : 0;

  /// The streak as seen at [now]: alive only if the goal was met today or
  /// yesterday; a whole unmet day breaks it.
  int streakAt(DateTime now) {
    if (lastGoalDay.isEmpty) return 0;
    final today = dayKey(now);
    return (lastGoalDay == today || lastGoalDay == previousDayKey(today)) ? streak : 0;
  }

  bool goalMetAt(DateTime now) => lastGoalDay == dayKey(now);

  Progress copyWith({
    int? lifetimeBoops,
    Map<String, int>? perCritter,
    String? selectedId,
    Set<String>? celebrated,
    int? bestCombo,
    int? bestRush,
    String? todayKey,
    int? todayBoops,
    String? lastGoalDay,
    int? streak,
    bool? onboardingDone,
    bool? reviewAsked,
    Set<String>? dismissedAnnouncements,
  }) => Progress(
    lifetimeBoops: lifetimeBoops ?? this.lifetimeBoops,
    perCritter: perCritter ?? this.perCritter,
    selectedId: selectedId ?? this.selectedId,
    celebrated: celebrated ?? this.celebrated,
    bestCombo: bestCombo ?? this.bestCombo,
    bestRush: bestRush ?? this.bestRush,
    todayKey: todayKey ?? this.todayKey,
    todayBoops: todayBoops ?? this.todayBoops,
    lastGoalDay: lastGoalDay ?? this.lastGoalDay,
    streak: streak ?? this.streak,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    reviewAsked: reviewAsked ?? this.reviewAsked,
    dismissedAnnouncements: dismissedAnnouncements ?? this.dismissedAnnouncements,
  );

  /// Adds [n] boops for critter [id] at [now] against a daily [goal].
  /// Pure: returns the new state and what changed.
  (Progress, BoopOutcome) addBoops({required String id, required int n, required DateTime now, required int goal}) {
    if (n <= 0) return (this, const BoopOutcome());
    final before = {for (final c in kCritters) if (isUnlocked(c)) c.id};
    final today = dayKey(now);
    final todayCount = (todayKey == today ? todayBoops : 0) + n;
    var nextStreak = streak;
    var nextGoalDay = lastGoalDay;
    var goalJustMet = false;
    if (todayCount >= goal && lastGoalDay != today) {
      nextStreak = lastGoalDay == previousDayKey(today) ? streak + 1 : 1;
      nextGoalDay = today;
      goalJustMet = true;
    }
    final next = copyWith(
      lifetimeBoops: lifetimeBoops + n,
      perCritter: {...perCritter, id: boopsFor(id) + n},
      todayKey: today,
      todayBoops: todayCount,
      lastGoalDay: nextGoalDay,
      streak: nextStreak,
    );
    final unlocked = [for (final c in kCritters) if (next.isUnlocked(c) && !before.contains(c.id)) c];
    return (next, BoopOutcome(newUnlocks: unlocked, goalJustMet: goalJustMet));
  }

  Map<String, dynamic> toJson() => {
    'v': 1,
    'lifetime': lifetimeBoops,
    'per': perCritter,
    'sel': selectedId,
    'cel': celebrated.toList(),
    'bestCombo': bestCombo,
    'bestRush': bestRush,
    'todayKey': todayKey,
    'today': todayBoops,
    'goalDay': lastGoalDay,
    'streak': streak,
    'onb': onboardingDone,
    'rev': reviewAsked,
    'ann': dismissedAnnouncements.toList(),
  };

  /// Defensive: any malformed field falls back to its default rather than
  /// throwing, so a corrupt store can never brick the app.
  factory Progress.fromJson(Map<String, dynamic> j) {
    int i(Object? v) => v is num && v >= 0 ? v.round() : 0;
    String s(Object? v, String d) => v is String ? v : d;
    Set<String> set(Object? v) => v is List ? v.whereType<String>().toSet() : <String>{};
    final per = <String, int>{};
    final p = j['per'];
    if (p is Map) {
      p.forEach((k, v) {
        if (k is String && v is num && v >= 0) per[k] = v.round();
      });
    }
    return Progress(
      lifetimeBoops: i(j['lifetime']),
      perCritter: per,
      selectedId: s(j['sel'], 'mochi'),
      celebrated: {'mochi', ...set(j['cel'])},
      bestCombo: i(j['bestCombo']),
      bestRush: i(j['bestRush']),
      todayKey: s(j['todayKey'], ''),
      todayBoops: i(j['today']),
      lastGoalDay: s(j['goalDay'], ''),
      streak: i(j['streak']),
      onboardingDone: j['onb'] == true,
      reviewAsked: j['rev'] == true,
      dismissedAnnouncements: set(j['ann']),
    );
  }
}

/// Owns and persists [Progress]. Everything lives under ONE key, which is what
/// makes "reset progress" provably complete (see SPEC F6).
class ProgressStore extends ChangeNotifier {
  ProgressStore({DateTime Function()? clock}) : clock = clock ?? DateTime.now;

  static const storageKey = 'progress.v1';
  static const allKeys = [storageKey];

  final DateTime Function() clock;
  Progress _value = const Progress();
  Progress get value => _value;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(storageKey);
      if (raw != null) {
        final j = jsonDecode(raw);
        if (j is Map<String, dynamic>) _value = Progress.fromJson(j);
      }
    } catch (e) {
      debugPrint('progress load failed, starting fresh: $e');
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(storageKey, jsonEncode(_value.toJson()));
    } catch (e) {
      debugPrint('progress save failed: $e');
    }
  }

  void _set(Progress v) {
    _value = v;
    notifyListeners();
    _save();
  }

  BoopOutcome addBoops(String id, int n, {required int goal}) {
    final (next, outcome) = _value.addBoops(id: id, n: n, now: clock(), goal: goal);
    if (!identical(next, _value)) _set(next);
    return outcome;
  }

  void select(String id) {
    final c = critterById(id);
    if (!_value.isUnlocked(c) || _value.selectedId == id) return;
    _set(_value.copyWith(selectedId: id));
  }

  void markCelebrated(String id) {
    if (_value.celebrated.contains(id)) return;
    _set(_value.copyWith(celebrated: {..._value.celebrated, id}));
  }

  /// Returns true when [combo] is a new best.
  bool recordCombo(int combo) {
    if (combo <= _value.bestCombo) return false;
    _set(_value.copyWith(bestCombo: combo));
    return true;
  }

  /// Returns true when [score] is a new best.
  bool recordRush(int score) {
    if (score <= _value.bestRush) return false;
    _set(_value.copyWith(bestRush: score));
    return true;
  }

  void completeOnboarding() {
    if (_value.onboardingDone) return;
    _set(_value.copyWith(onboardingDone: true));
  }

  void markReviewAsked() => _set(_value.copyWith(reviewAsked: true));

  void dismissAnnouncement(String id) =>
      _set(_value.copyWith(dismissedAnnouncements: {..._value.dismissedAnnouncements, id}));

  /// Back to the first-launch state. Removes the key rather than writing a
  /// blank value, so nothing stale can survive.
  Future<void> reset() async {
    _value = const Progress();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    for (final k in allKeys) {
      await p.remove(k);
    }
  }
}
