import 'dart:math';

import 'package:flutter/foundation.dart';

/// What pops out of a bush (SPEC F5).
enum PopKind { awake, sleepy, golden }

@immutable
class Popup {
  const Popup({required this.critterId, required this.kind, required this.bornAt, required this.lifetime, required this.serial});
  final String critterId;
  final PopKind kind;
  final Duration bornAt;
  final Duration lifetime;

  /// Unique per spawn, so the UI can key an animation to one appearance.
  final int serial;

  Duration get diesAt => bornAt + lifetime;
}

enum TapKind { miss, hit, golden, sleepy, ignored }

@immutable
class TapResult {
  const TapResult(this.kind, {this.points = 0, this.streak = 0});
  final TapKind kind;

  /// Signed score change this tap caused.
  final int points;
  final int streak;
}

/// The Boop Rush engine. Pure and time-injected: the UI calls [advance] with
/// the elapsed round time every frame and [tap] when a bush is touched, so a
/// whole round can be replayed deterministically in a test.
class RushGame {
  RushGame({
    required this.critterIds,
    this.duration = const Duration(seconds: 30),
    this.holes = 9,
    int seed = 1,
  }) : assert(critterIds.isNotEmpty),
       _rng = Random(seed),
       _slots = List<Popup?>.filled(holes, null);

  final List<String> critterIds;
  final Duration duration;
  final int holes;
  final Random _rng;
  final List<Popup?> _slots;

  int score = 0;
  int streak = 0;
  int bestStreak = 0;

  /// Awake + golden critters booped: these count as real boops (lifetime,
  /// unlocks, daily goal). Sleepy taps never do.
  int goodBoops = 0;
  Duration _now = Duration.zero;
  Duration _nextSpawn = const Duration(milliseconds: 350);
  int _serial = 0;

  List<Popup?> get slots => List.unmodifiable(_slots);
  Duration get elapsed => _now;
  bool get isOver => _now >= duration;
  Duration get remaining => isOver ? Duration.zero : duration - _now;

  /// 0 at the start of the round, 1 at the end.
  double get progress => (_now.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);

  Duration get _spawnGap => Duration(milliseconds: (900 - 450 * progress).round());
  Duration get _lifetime => Duration(milliseconds: (1650 - 750 * progress).round());
  int get _maxLive => 2 + (progress * 2.5).floor(); // 2 → 4

  /// Moves the round clock to [elapsed]: expires popups, spawns new ones.
  void advance(Duration elapsed) {
    if (elapsed < _now) return; // time never runs backwards
    _now = elapsed > duration ? duration : elapsed;
    for (var i = 0; i < holes; i++) {
      final p = _slots[i];
      if (p != null && _now >= p.diesAt) _slots[i] = null;
    }
    if (isOver) {
      for (var i = 0; i < holes; i++) {
        _slots[i] = null;
      }
      return;
    }
    while (_now >= _nextSpawn) {
      _spawn(_nextSpawn);
      _nextSpawn += _spawnGap;
    }
  }

  void _spawn(Duration at) {
    final live = _slots.where((p) => p != null).length;
    if (live >= _maxLive) return;
    final free = [for (var i = 0; i < holes; i++) if (_slots[i] == null) i];
    if (free.isEmpty) return;
    final hole = free[_rng.nextInt(free.length)];
    final r = _rng.nextDouble();
    final kind = r < 0.07
        ? PopKind.golden
        : (r < 0.25 && at > const Duration(seconds: 3) ? PopKind.sleepy : PopKind.awake);
    _slots[hole] = Popup(
      critterId: critterIds[_rng.nextInt(critterIds.length)],
      kind: kind,
      bornAt: at,
      lifetime: kind == PopKind.sleepy ? _lifetime + const Duration(milliseconds: 300) : _lifetime,
      serial: _serial++,
    );
  }

  /// A finger on bush [hole] at round time [at].
  TapResult tap(int hole, Duration at) {
    advance(at);
    if (isOver || hole < 0 || hole >= holes) return const TapResult(TapKind.ignored);
    final p = _slots[hole];
    if (p == null) return TapResult(TapKind.miss, streak: streak);
    _slots[hole] = null;
    switch (p.kind) {
      case PopKind.sleepy:
        final before = score;
        score = max(0, score - 2);
        streak = 0;
        return TapResult(TapKind.sleepy, points: score - before, streak: 0);
      case PopKind.awake:
      case PopKind.golden:
        streak++;
        bestStreak = max(bestStreak, streak);
        goodBoops++;
        final base = p.kind == PopKind.golden ? 5 : 1;
        final points = base + streak ~/ 5;
        score += points;
        return TapResult(p.kind == PopKind.golden ? TapKind.golden : TapKind.hit, points: points, streak: streak);
    }
  }
}
