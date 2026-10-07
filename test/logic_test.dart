import 'dart:convert';
import 'dart:io';

import 'package:boop/audio/sfx.dart';
import 'package:boop/core/remote_config.dart';
import 'package:boop/game/combo.dart';
import 'package:boop/game/critters.dart';
import 'package:boop/game/progress.dart';
import 'package:boop/game/rush.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day1 = DateTime(2026, 10, 7, 9);
  final day2 = DateTime(2026, 10, 8, 23, 50);
  final day3 = DateTime(2026, 10, 9, 0, 5);
  final day5 = DateTime(2026, 10, 11, 12);

  group('critters (SPEC F3)', () {
    test('twelve critters with the documented thresholds, in order', () {
      expect(kCritters.map((c) => c.unlockAt).toList(), [0, 30, 80, 150, 250, 400, 600, 850, 1150, 1500, 2000, 3000]);
      expect(kCritters.map((c) => c.id).toSet().length, 12);
    });

    test('no two critters look alike (ears + nose + body colour)', () {
      final looks = kCritters.map((c) => '${c.ears}|${c.noseStyle}|${c.body.toARGB32()}').toSet();
      expect(looks.length, kCritters.length);
    });

    test('every critter has its own squeak pitch, inside the rendered range', () {
      expect(kCritters.map((c) => c.pitch).toSet().length, kCritters.length);
      for (final c in kCritters) {
        expect(c.pitch, inInclusiveRange(0, 11));
        expect(boopPitchIndex(c.pitch, 1000), lessThan(SoundBoard.boopSteps));
        expect(File('assets/sounds/boop_${boopPitchIndex(c.pitch, 1000).toString().padLeft(2, '0')}.wav').existsSync(), isTrue);
      }
    });

    test('nextLocked walks the thresholds and ends at null', () {
      expect(nextLocked(0)!.id, 'pip');
      expect(nextLocked(29)!.id, 'pip');
      expect(nextLocked(30)!.id, 'bao');
      expect(nextLocked(2999)!.id, 'star');
      expect(nextLocked(3000), isNull);
    });
  });

  group('progress: boops & unlocks', () {
    test('a boop adds exactly one, per critter and lifetime', () {
      final (p, _) = const Progress().addBoops(id: 'mochi', n: 1, now: day1, goal: 50);
      expect(p.lifetimeBoops, 1);
      expect(p.boopsFor('mochi'), 1);
      expect(p.todayAt(day1), 1);
    });

    test('crossing a threshold unlocks exactly that critter, once', () {
      var p = const Progress();
      final unlocked = <String>[];
      for (var i = 0; i < 90; i++) {
        final (next, out) = p.addBoops(id: 'mochi', n: 1, now: day1, goal: 500);
        unlocked.addAll(out.newUnlocks.map((c) => c.id));
        p = next;
      }
      expect(unlocked, ['pip', 'bao']);
      expect(p.pendingCelebrations.map((c) => c.id), ['pip', 'bao']);
    });

    test('a big batch can unlock several at once', () {
      final (_, out) = const Progress().addBoops(id: 'mochi', n: 300, now: day1, goal: 50);
      expect(out.newUnlocks.map((c) => c.id), ['pip', 'bao', 'kiwi', 'momo']);
    });

    test('a locked selection falls back to Mochi', () {
      expect(const Progress(selectedId: 'star').selected.id, 'mochi');
    });

    test('JSON round-trip, and corrupt fields fall back instead of throwing', () {
      final (p, _) = const Progress().addBoops(id: 'pip', n: 40, now: day1, goal: 10);
      final back = Progress.fromJson(p.copyWith(bestCombo: 12, bestRush: 33, onboardingDone: true).toJson());
      expect(back.lifetimeBoops, 40);
      expect(back.boopsFor('pip'), 40);
      expect(back.bestCombo, 12);
      expect(back.bestRush, 33);
      expect(back.onboardingDone, isTrue);
      expect(back.streakAt(day1), 1);

      final junk = Progress.fromJson({'lifetime': 'lots', 'per': [1, 2], 'cel': 'x', 'bestRush': -5, 'onb': 'yes'});
      expect(junk.lifetimeBoops, 0);
      expect(junk.perCritter, isEmpty);
      expect(junk.bestRush, 0);
      expect(junk.onboardingDone, isFalse);
      expect(junk.celebrated, contains('mochi'));
    });
  });

  group('daily goal & streak (SPEC F4)', () {
    Progress boop(Progress p, int n, DateTime t, {int goal = 50}) => p.addBoops(id: 'mochi', n: n, now: t, goal: goal).$1;

    test('goal fires once per day', () {
      var p = const Progress();
      var (next, out) = p.addBoops(id: 'mochi', n: 49, now: day1, goal: 50);
      expect(out.goalJustMet, isFalse);
      (next, out) = next.addBoops(id: 'mochi', n: 1, now: day1, goal: 50);
      expect(out.goalJustMet, isTrue);
      (next, out) = next.addBoops(id: 'mochi', n: 30, now: day1, goal: 50);
      expect(out.goalJustMet, isFalse);
      expect(next.streakAt(day1), 1);
      p = next;
      expect(p.goalMetAt(day1), isTrue);
    });

    test('consecutive days build the streak; today resets at midnight', () {
      var p = boop(const Progress(), 50, day1);
      expect(p.todayAt(day2), 0, reason: 'a new local day starts at zero');
      p = boop(p, 50, day2);
      expect(p.streakAt(day2), 2);
      p = boop(p, 50, day3);
      expect(p.streakAt(day3), 3);
    });

    test('a whole unmet day breaks the streak', () {
      var p = boop(const Progress(), 50, day1);
      p = boop(p, 50, day2);
      expect(p.streakAt(day3), 2, reason: 'still alive the next day');
      expect(p.streakAt(day5), 0, reason: 'a whole day passed unmet');
      p = boop(p, 50, day5);
      expect(p.streakAt(day5), 1);
    });

    test('dayKey/previousDayKey across month and DST boundaries', () {
      expect(dayKey(DateTime(2026, 3, 1, 0, 1)), '2026-03-01');
      expect(previousDayKey('2026-03-01'), '2026-02-28');
      expect(previousDayKey('2026-01-01'), '2025-12-31');
      expect(previousDayKey('2026-03-30'), '2026-03-29');
    });
  });

  group('combo (SPEC F2)', () {
    test('chains within 1 s, resets after', () {
      final c = ComboTracker();
      final t0 = DateTime(2026, 1, 1);
      expect(c.boop(t0).count, 1);
      expect(c.boop(t0.add(const Duration(milliseconds: 900))).count, 2);
      expect(c.boop(t0.add(const Duration(milliseconds: 2001))).count, 1, reason: 'gap > 1 s');
      expect(c.countAt(t0.add(const Duration(seconds: 10))), 0);
    });

    test('tiers at 10, 25, 50 and a sneeze every 30', () {
      final c = ComboTracker();
      var t = DateTime(2026, 1, 1);
      final tiers = <int, ComboTier>{};
      final sneezes = <int>[];
      for (var i = 1; i <= 60; i++) {
        final s = c.boop(t);
        if (s.tier != null) tiers[s.count] = s.tier!;
        if (s.sneeze) sneezes.add(s.count);
        t = t.add(const Duration(milliseconds: 200));
      }
      expect(tiers, {10: ComboTier.boopADoop, 25: ComboTier.snootStorm, 50: ComboTier.megaBoop});
      expect(sneezes, [30, 60]);
    });

    test('pitch rises every 3 boops and caps', () {
      expect(boopPitchIndex(3, 1), 3);
      expect(boopPitchIndex(3, 4), 4);
      expect(boopPitchIndex(3, 22), 10);
      expect(boopPitchIndex(3, 999), 10);
      expect(boopPitchIndex(11, 999), 18);
    });
  });

  group('Boop Rush engine (SPEC F5)', () {
    const ms = Duration(milliseconds: 1);

    test('a round ends at the configured duration and ignores later taps', () {
      final g = RushGame(critterIds: ['mochi'], duration: const Duration(seconds: 15), seed: 3);
      for (var t = 0; t < 15000; t += 1) {
        g.advance(ms * t);
        expect(g.isOver, isFalse, reason: 'still playing at $t ms');
      }
      expect(g.tap(0, const Duration(milliseconds: 14999)).kind, isNot(TapKind.ignored));
      g.advance(const Duration(seconds: 15));
      expect(g.isOver, isTrue);
      expect(g.slots.every((s) => s == null), isTrue);
      expect(g.tap(0, const Duration(seconds: 16)).kind, TapKind.ignored);
    });

    test('scoring: +1 awake, +5 golden, streak bonus, −2 sleepy floored at 0', () {
      final g = RushGame(critterIds: ['mochi', 'pip'], seed: 11);
      final counts = {for (final k in TapKind.values) k: 0};
      var t = Duration.zero;
      var expected = 0;
      while (!g.isOver) {
        t += const Duration(milliseconds: 50);
        g.advance(t);
        for (var i = 0; i < 9; i++) {
          final p = g.slots[i];
          if (p == null) continue;
          final before = g.score;
          final r = g.tap(i, t);
          counts[r.kind] = counts[r.kind]! + 1;
          switch (r.kind) {
            case TapKind.hit:
              expect(r.points, 1 + r.streak ~/ 5);
            case TapKind.golden:
              expect(r.points, 5 + r.streak ~/ 5);
            case TapKind.sleepy:
              expect(g.score, (before - 2).clamp(0, 1 << 30));
              expect(g.streak, 0);
            default:
              break;
          }
          expected = g.score;
          expect(g.score, greaterThanOrEqualTo(0));
        }
      }
      expect(g.score, expected);
      expect(counts[TapKind.hit]! > 20, isTrue, reason: 'a full round spawns plenty of critters');
      expect(counts[TapKind.sleepy]! > 0, isTrue);
      expect(counts[TapKind.golden]! > 0, isTrue);
      expect(g.goodBoops, counts[TapKind.hit]! + counts[TapKind.golden]!);
    });

    test('a bush never holds two critters, and live count stays ≤ 4', () {
      final g = RushGame(critterIds: ['mochi'], seed: 5);
      final serials = <int, int>{};
      for (var t = 0; t <= 30000; t += 10) {
        g.advance(ms * t);
        final live = g.slots.whereType<Popup>().toList();
        expect(live.length, lessThanOrEqualTo(4));
        for (var i = 0; i < 9; i++) {
          final p = g.slots[i];
          if (p != null) serials.putIfAbsent(p.serial, () => i);
          if (p != null) expect(serials[p.serial], i, reason: 'a popup never moves bushes');
        }
      }
    });

    test('no sleepy critter in the first 3 s (a fair start)', () {
      for (var seed = 0; seed < 20; seed++) {
        final g = RushGame(critterIds: ['mochi'], seed: seed);
        for (var t = 0; t <= 3000; t += 10) {
          g.advance(ms * t);
          expect(g.slots.whereType<Popup>().where((p) => p.kind == PopKind.sleepy), isEmpty);
        }
      }
    });

    test('time never runs backwards', () {
      final g = RushGame(critterIds: ['mochi'], seed: 1)..advance(const Duration(seconds: 5));
      g.advance(const Duration(seconds: 2));
      expect(g.elapsed, const Duration(seconds: 5));
    });
  });

  group('remote config (SPEC F8)', () {
    test('defaults are a complete app', () {
      const d = RemoteConfig.defaults;
      expect(d.rushEnabled, isTrue);
      expect(d.dailyGoal, 50);
      expect(d.rushDurationSec, 30);
      expect(d.announcement, isNull);
      expect(d.privacyUrl, startsWith('https://'));
    });

    test('values are clamped to their documented ranges', () {
      final c = RemoteConfig.fromJson({'dailyGoal': 5, 'rush': {'durationSec': 600}, 'reviewPrompt': {'afterUnlocks': 99}});
      expect(c.dailyGoal, 10);
      expect(c.rushDurationSec, 60);
      expect(c.reviewAfterUnlocks, 11);
      expect(RemoteConfig.fromJson({'dailyGoal': 9999}).dailyGoal, 500);
      expect(RemoteConfig.fromJson({'dailyGoal': 75.4}).dailyGoal, 75);
    });

    test('malformed values fall back; nothing throws', () {
      final c = RemoteConfig.fromJson({
        'features': 'yes',
        'dailyGoal': 'fifty',
        'rush': [1],
        'links': {'privacyPolicy': 'javascript:alert(1)', 'support': 42},
        'announcement': {'enabled': true, 'id': '', 'title': 'x'},
      });
      expect(c.rushEnabled, isTrue);
      expect(c.dailyGoal, 50);
      expect(c.privacyUrl, RemoteConfig.defaults.privacyUrl);
      expect(c.supportUrl, RemoteConfig.defaults.supportUrl);
      expect(c.announcement, isNull, reason: 'an announcement needs an id');
    });

    test('kill switch and localized announcement', () {
      final c = RemoteConfig.fromJson({
        'features': {'rushEnabled': false},
        'announcement': {
          'enabled': true,
          'id': 'hello-1',
          'title': {'en': 'Hi', 'ar': 'مرحبا'},
          'body': 'Plain body',
          'url': 'http://insecure.example',
        },
      });
      expect(c.rushEnabled, isFalse);
      expect(c.announcement!.title.resolve('ar'), 'مرحبا');
      expect(c.announcement!.title.resolve('ja'), 'Hi');
      expect(c.announcement!.body.resolve('de'), 'Plain body');
      expect(c.announcement!.url, '', reason: 'only https links are opened');
    });

    test('the published config (config/remote_config_*.json) matches the code defaults', () {
      // The live file and the compiled defaults must agree, or a user who has
      // never fetched sees a different app from one who has.
      for (final name in ['current', 'template']) {
        final j = jsonDecode(File('config/remote_config_$name.json').readAsStringSync()) as Map<String, dynamic>;
        final c = RemoteConfig.fromJson(j);
        const d = RemoteConfig.defaults;
        expect(c.rushEnabled, d.rushEnabled, reason: name);
        expect(c.dailyGoal, d.dailyGoal, reason: name);
        expect(c.rushDurationSec, d.rushDurationSec, reason: name);
        expect(c.reviewPromptEnabled, d.reviewPromptEnabled, reason: name);
        expect(c.reviewAfterUnlocks, d.reviewAfterUnlocks, reason: name);
        expect(c.privacyUrl, d.privacyUrl, reason: name);
        expect(c.supportUrl, d.supportUrl, reason: name);
        expect(c.adsEnabled, isFalse, reason: name);
      }
    });

    test('compareVersions', () {
      expect(compareVersions('1.2.10', '1.2.9'), greaterThan(0));
      expect(compareVersions('1.0.0', '1.0.0'), 0);
      expect(compareVersions('1.0', '1.0.1'), lessThan(0));
      expect(compareVersions('2.0.0+5', '2.0.0'), 0);
    });
  });
}
