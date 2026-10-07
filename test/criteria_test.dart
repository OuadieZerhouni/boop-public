import 'dart:convert';

import 'package:boop/core/app_services.dart';
import 'package:boop/core/remote_config.dart';
import 'package:boop/core/settings.dart';
import 'package:boop/game/critters.dart';
import 'package:boop/game/progress.dart';
import 'package:boop/game/rush.dart';
import 'package:boop/main.dart';
import 'package:boop/ui/critter_painter.dart';
import 'package:boop/ui/critter_stage.dart';
import 'package:boop/ui/particles.dart';
import 'package:boop/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SPEC acceptance criteria that app_flow_test.dart and logic_test.dart do not
/// already prove. Each test names the criterion it stands behind.
void main() {
  late AppServices services;
  late List<String> sounds;
  late List<String> haptics;

  Future<void> boot(WidgetTester tester, {Map<String, Object> prefs = const {}, bool reduceMotion = false}) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    services = (await tester.runAsync(() => AppServices.create(clock: () => tester.binding.clock.now())))!;
    if (reduceMotion) {
      await tester.runAsync(() => services.settings.update(services.settings.value.copyWith(reduceMotion: true)));
    }
    sounds = [];
    haptics = [];
    services.sound.debugOnPlay = sounds.add;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(390, 844), devicePixelRatio: 3),
      child: BoopApp(services: services),
    ));
    await tester.pumpAndSettle();
  }

  Finder stage() => find.byKey(const ValueKey('critter-stage'));

  Offset stageOrigin(WidgetTester tester) {
    final size = tester.getSize(stage());
    final side = size.shortestSide;
    return tester.getTopLeft(stage()) + Offset((size.width - side) / 2, (size.height - side) / 2);
  }

  CritterGeometry geometry(WidgetTester tester) => CritterGeometry(tester.getSize(stage()).shortestSide, services.progress.value.selected);
  Offset nose(WidgetTester tester) => stageOrigin(tester) + geometry(tester).nose;
  Offset belly(WidgetTester tester) {
    final g = geometry(tester);
    return stageOrigin(tester) + Offset(g.cx + g.a * 0.35, g.cy + g.b * 0.4);
  }

  CritterPose pose(WidgetTester tester, [Finder? within]) {
    final paints = tester.widgetList<CustomPaint>(find.descendant(of: within ?? stage(), matching: find.byType(CustomPaint)));
    return paints.map((p) => p.painter).whereType<CritterPainter>().first.pose;
  }

  ParticleController particles(WidgetTester tester) => tester.widget<ParticleLayer>(find.byType(ParticleLayer).first).controller;

  Future<void> frames(WidgetTester tester, int n, [int ms = 16]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(Duration(milliseconds: ms));
    }
  }

  Future<void> flush(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  group('F1 — boop the snoot', () {
    testWidgets('c1: a nose tap adds exactly 1 to today and lifetime', (tester) async {
      await boot(tester);
      await tester.tapAt(nose(tester));
      await tester.pumpAndSettle();
      final p = services.progress.value;
      expect(p.lifetimeBoops, 1);
      expect(p.todayAt(services.clock()), 1);
      expect(find.text('1 boop'), findsOneWidget);
      expect(find.text('Today 1/50'), findsOneWidget);
    });

    testWidgets('c2: a body tap wobbles and giggles, and is not a boop', (tester) async {
      await boot(tester);
      await tester.tapAt(belly(tester));
      await tester.pump();
      await frames(tester, 3);
      expect(pose(tester).tilt, isNot(0), reason: 'wobble');
      expect(sounds, contains('giggle'));
      expect(services.progress.value.lifetimeBoops, 0);
      await tester.pumpAndSettle();
    });

    testWidgets('c3: dragging stretches toward the finger; release springs back', (tester) async {
      await boot(tester);
      final g = await tester.startGesture(belly(tester));
      for (var i = 0; i < 8; i++) {
        await g.moveBy(const Offset(12, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await frames(tester, 20);
      expect(pose(tester).shear.dx, greaterThan(0.1), reason: 'stretched right, toward the finger');
      await g.up();
      await tester.pumpAndSettle();
      expect(pose(tester).shear, Offset.zero);
      expect(sounds, contains('boing'));
      expect(services.progress.value.lifetimeBoops, 0);
    });

    testWidgets('c4: holding 0.6 s is a hug — eyes closed, hearts stream while held, no boop', (tester) async {
      await boot(tester);
      final g = await tester.startGesture(belly(tester));
      await frames(tester, 30); // 0.48 s
      expect(pose(tester).face, isNot(CritterFace.hug));
      await frames(tester, 10); // 0.64 s
      expect(pose(tester).face, CritterFace.hug);
      expect(sounds, contains('hug'));
      // Well past the first burst's lifetime (≤ 1.3 s), hearts are still coming.
      await frames(tester, 200); // +3.2 s
      expect(pose(tester).face, CritterFace.hug);
      expect(particles(tester).decorativeCount, greaterThan(0), reason: 'hearts stream for as long as the finger is down');
      await g.up();
      await tester.pumpAndSettle();
      expect(pose(tester).face, CritterFace.open);
      expect(services.progress.value.lifetimeBoops, 0);
      expect(particles(tester).decorativeCount, 0);
    });

    testWidgets('c5: idle — breathes, blinks every 2–5 s, sleepy after 30 s, a touch wakes it', (tester) async {
      Future<void> pumpStage({required bool reduceMotion}) => tester.pumpWidget(MaterialApp(
        home: Center(
          child: SizedBox.square(
            dimension: 300,
            child: CritterStage(key: const ValueKey('idle-stage'), species: kCritters.first, onBoop: (_) {}, idle: true, reduceMotion: reduceMotion),
          ),
        ),
      ));
      final s = find.byKey(const ValueKey('idle-stage'));
      await pumpStage(reduceMotion: false);

      final heights = <double>{};
      var blinks = 0;
      var blinking = false;
      for (var i = 0; i < 200; i++) { // 10 s
        await tester.pump(const Duration(milliseconds: 50));
        final p = pose(tester, s);
        heights.add((p.squashY * 1000).roundToDouble());
        if (p.blink > 0 && !blinking) blinks++;
        blinking = p.blink > 0;
      }
      expect(heights.length, greaterThan(5), reason: 'breathing moves the body');
      expect(blinks, inInclusiveRange(2, 5), reason: '10 s at one blink per 2–5 s');
      expect(pose(tester, s).face, CritterFace.open);

      await frames(tester, 420, 50); // past 30 s without input
      expect(pose(tester, s).face, CritterFace.sleepy);
      expect(find.descendant(of: s, matching: find.text('z')), findsWidgets);

      await tester.tapAt(tester.getCenter(s) + const Offset(0, 50));
      await tester.pump(const Duration(milliseconds: 50));
      expect(pose(tester, s).face, isNot(CritterFace.sleepy));
      expect(find.descendant(of: s, matching: find.text('z')), findsNothing);

      // Reduce motion stops the breathing, not the dozing off.
      await tester.pumpWidget(const SizedBox());
      await pumpStage(reduceMotion: true);
      await frames(tester, 620, 50);
      expect(pose(tester, s).face, CritterFace.sleepy);
      expect(pose(tester, s).squashY, 1);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.binding.hasScheduledFrame, isFalse, reason: 'at rest the stage stops repainting until its next event');
      final zBefore = tester.getTopLeft(find.descendant(of: s, matching: find.text('z')).first);
      await frames(tester, 40, 50);
      expect(tester.getTopLeft(find.descendant(of: s, matching: find.text('z')).first), zBefore, reason: 'static z z z');
      await frames(tester, 600, 50); // the doze deepens on its own, past 60 s
      expect(pose(tester, s).face, CritterFace.asleep);
    });

    testWidgets('c6: sound and haptics obey Settings; both off = silent and still', (tester) async {
      await boot(tester);
      await tester.tapAt(nose(tester));
      await tester.pumpAndSettle();
      expect(sounds.where((s) => s.startsWith('boop')), isNotEmpty);
      expect(haptics, contains('HapticFeedbackType.lightImpact'));

      await tester.runAsync(() => services.settings.update(const AppSettings(sound: false, haptics: false)));
      sounds.clear();
      haptics.clear();
      await tester.pump(const Duration(seconds: 2));
      for (var i = 0; i < 12; i++) {
        await tester.tapAt(nose(tester));
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.tapAt(belly(tester));
      await tester.pumpAndSettle();
      expect(services.progress.value.lifetimeBoops, 13);
      expect(sounds, isEmpty);
      expect(haptics, isEmpty);
    });

    testWidgets('c7: every tap target is labelled; the critter announces its name', (tester) async {
      final handle = tester.ensureSemantics();
      await boot(tester);
      expect(find.bySemanticsLabel(RegExp(r'^Mochi\. Double-tap to boop')), findsOneWidget);
      for (final tab in [0, 1, 2]) {
        await tester.tap(find.byKey(ValueKey('tab-$tab')));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline), reason: 'tab $tab');
      }
      // Mid-round: popped-up critters are labelled, sleepy ones say so.
      await tester.tap(find.byKey(const ValueKey('rush-start')));
      var sawSleepy = false;
      for (var i = 0; i < 100 && !sawSleepy; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        sawSleepy = find.bySemanticsLabel(RegExp("Don't boop")).evaluate().isNotEmpty;
      }
      expect(sawSleepy, isTrue);
      expect(find.bySemanticsLabel(RegExp(r'^\w+$')), findsWidgets, reason: 'an awake critter is announced by name');
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline), reason: 'rush mid-round');
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tab-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline), reason: 'settings');
      handle.dispose();
    });
  });

  group('F2 — combos', () {
    testWidgets('c2/c3: tiers chime with a medium haptic; the 30th boop sneezes with confetti', (tester) async {
      await boot(tester);
      for (var i = 0; i < 9; i++) {
        await tester.tapAt(nose(tester));
        await tester.pump(const Duration(milliseconds: 60));
      }
      expect(sounds, isNot(contains('chime')));
      haptics.clear();
      await tester.tapAt(nose(tester));
      await tester.pump(const Duration(milliseconds: 60));
      expect(sounds, contains('chime'));
      expect(haptics, contains('HapticFeedbackType.mediumImpact'));

      for (var i = 10; i < 29; i++) {
        await tester.tapAt(nose(tester));
        await tester.pump(const Duration(milliseconds: 60));
      }
      expect(sounds, isNot(contains('sneeze')));
      final before = particles(tester).decorativeCount;
      await tester.tapAt(nose(tester));
      await tester.pump();
      expect(sounds, contains('sneeze'));
      expect(pose(tester).face, CritterFace.surprised);
      expect(particles(tester).decorativeCount - before, greaterThanOrEqualTo(30), reason: 'one tap, a burst of confetti');
      await tester.pumpAndSettle();
      await flush(tester);
    });

    testWidgets('c4: the best combo is shown on the Critters screen', (tester) async {
      await boot(tester, prefs: {ProgressStore.storageKey: jsonEncode(const Progress(bestCombo: 42).toJson())});
      await tester.tap(find.byKey(const ValueKey('tab-1')));
      await tester.pumpAndSettle();
      expect(find.text('Best combo ×42'), findsOneWidget);
    });
  });

  group('F3 — collection', () {
    testWidgets('c2: unlocked cards show name and count; locked show ??? and N more boops', (tester) async {
      final saved = Progress(lifetimeBoops: 45, perCritter: const {'mochi': 40, 'pip': 5}, celebrated: {for (final c in kCritters) c.id}).toJson();
      await boot(tester, prefs: {ProgressStore.storageKey: jsonEncode(saved)});
      await tester.tap(find.byKey(const ValueKey('tab-1')));
      await tester.pumpAndSettle();
      Finder inCard(String id, String text) => find.descendant(of: find.byKey(ValueKey('critter-card-$id')), matching: find.text(text));
      expect(inCard('mochi', 'Mochi'), findsOneWidget);
      expect(inCard('mochi', '40 boops'), findsOneWidget);
      expect(inCard('pip', '5 boops'), findsOneWidget);
      expect(inCard('bao', '???'), findsOneWidget);
      expect(inCard('bao', '35 more boops'), findsOneWidget);
      expect(inCard('bao', 'Bao'), findsNothing);
    });

    testWidgets("c5: \"Everyone's here!\" once all twelve are unlocked", (tester) async {
      final saved = Progress(lifetimeBoops: 3000, onboardingDone: true, celebrated: {for (final c in kCritters) c.id}).toJson();
      await boot(tester, prefs: {ProgressStore.storageKey: jsonEncode(saved)});
      expect(find.text("Everyone's here!"), findsOneWidget);
      expect(find.byKey(const ValueKey('next-friend')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('tab-1')));
      await tester.pumpAndSettle();
      expect(find.text("Everyone's here!"), findsOneWidget);
    });
  });

  group('F4 — daily ring', () {
    testWidgets('c1: the ring fills with today and completes at the goal', (tester) async {
      await boot(tester);
      services.remote.value = RemoteConfig.fromJson({'dailyGoal': 10});
      await tester.pump();
      GoalRing ring() => tester.widget<GoalRing>(find.byType(GoalRing));
      expect(ring().progress, 0);
      for (var i = 0; i < 4; i++) {
        await tester.tapAt(nose(tester));
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pumpAndSettle();
      expect(ring().progress, closeTo(0.4, 1e-9));
      expect(ring().done, isFalse);
      for (var i = 0; i < 6; i++) {
        await tester.tapAt(nose(tester));
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pumpAndSettle();
      expect(ring().done, isTrue);
      await flush(tester);
    });
  });

  group('F5 — Boop Rush', () {
    test('c3: a booped or timed-out critter leaves its bush', () {
      final g = RushGame(critterIds: ['mochi'], seed: 7);
      var t = Duration.zero;
      var booped = 0, expired = 0;
      final seen = <int, Popup>{};
      while (!g.isOver) {
        t += const Duration(milliseconds: 10);
        g.advance(t);
        for (var i = 0; i < 9; i++) {
          final p = g.slots[i];
          final before = seen[i];
          if (!g.isOver && before != null && (p == null || p.serial != before.serial)) {
            expect(p, isNull, reason: 'the old critter left before a new one arrived');
            expect(t >= before.diesAt, isTrue, reason: 'it left because it timed out');
            expired++;
          }
          if (p == null) {
            seen.remove(i);
          } else {
            seen[i] = p;
          }
        }
        // Boop every other new arrival.
        for (var i = 0; i < 9; i++) {
          final p = g.slots[i];
          if (p != null && p.serial.isEven && t - p.bornAt > const Duration(milliseconds: 100)) {
            g.tap(i, t);
            expect(g.slots[i], isNull, reason: 'a booped critter leaves at once');
            seen.remove(i);
            booped++;
          }
        }
      }
      expect(booped, greaterThan(5));
      expect(expired, greaterThan(5));
    });

    testWidgets('c5: Rush boops count toward unlocks and the daily goal', (tester) async {
      await boot(tester, prefs: {ProgressStore.storageKey: jsonEncode(const Progress(lifetimeBoops: 25, onboardingDone: true).toJson())});
      services.remote.value = RemoteConfig.fromJson({'dailyGoal': 10});
      await tester.tap(find.byKey(const ValueKey('tab-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('rush-start')));
      await tester.pump();
      for (var t = 0; t < 31000; t += 120) {
        for (var i = 0; i < 9; i++) {
          await tester.tap(find.byKey(ValueKey('bush-$i')), warnIfMissed: false);
        }
        await tester.pump(const Duration(milliseconds: 120));
      }
      await tester.pumpAndSettle();
      final p = services.progress.value;
      expect(p.lifetimeBoops, greaterThanOrEqualTo(35));
      expect(p.isUnlocked(critterById('pip')), isTrue);
      expect(p.goalMetAt(services.clock()), isTrue);
      await flush(tester);
    });
  });

  group('F5 — Boop Rush (screen)', () {
    Future<void> openRush(WidgetTester tester, {Map<String, Object> remote = const {}}) async {
      await boot(tester, prefs: {ProgressStore.storageKey: jsonEncode(const Progress(onboardingDone: true).toJson())});
      services.remote.value = RemoteConfig.fromJson(remote);
      await tester.tap(find.byKey(const ValueKey('tab-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('rush-start')));
      await tester.pump();
    }

    testWidgets('c1: the round lasts the remote duration', (tester) async {
      await openRush(tester, remote: {'rush': {'durationSec': 15}});
      await frames(tester, 145, 100); // 14.5 s
      expect(find.byKey(const ValueKey('rush-results')), findsNothing);
      await frames(tester, 8, 100); // 15.3 s
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('rush-results')), findsOneWidget);
      await flush(tester);
    });

    testWidgets('c4/c5: the best survives a reload; sleepy taps earn no boops', (tester) async {
      final handle = tester.ensureSemantics();
      await openRush(tester);
      var sleepyTaps = 0;
      for (var t = 0; t < 31000; t += 50) {
        for (final f in find.bySemanticsLabel(RegExp("Don't boop")).evaluate().toList()) {
          await tester.tapAt(tester.getCenter(find.byWidget(f.widget)));
          sleepyTaps++;
        }
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
      expect(sleepyTaps, greaterThan(0));
      expect(services.progress.value.lifetimeBoops, 0, reason: 'sleepy critters never count as boops');

      await tester.tap(find.byKey(const ValueKey('rush-again')));
      await tester.pump();
      for (var t = 0; t < 31000; t += 120) {
        for (var i = 0; i < 9; i++) {
          await tester.tap(find.byKey(ValueKey('bush-$i')), warnIfMissed: false);
        }
        await tester.pump(const Duration(milliseconds: 120));
      }
      await tester.pumpAndSettle();
      final best = services.progress.value.bestRush;
      expect(best, greaterThan(0));
      final reloaded = ProgressStore();
      await tester.runAsync(reloaded.load);
      expect(reloaded.value.bestRush, best);
      handle.dispose();
      await flush(tester);
    });
  });

  group('F6 — settings', () {
    testWidgets('c1: every toggle persists across a restart', (tester) async {
      await boot(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      for (final k in ['set-sound', 'set-haptics', 'set-motion']) {
        await tester.tap(find.byKey(ValueKey(k)));
        await tester.pumpAndSettle();
      }
      expect(services.settings.value.sound, isFalse);
      expect(services.settings.value.haptics, isFalse);
      expect(services.settings.value.reduceMotion, isTrue);
      final reloaded = SettingsService();
      await tester.runAsync(reloaded.load);
      expect(reloaded.value.sound, isFalse);
      expect(reloaded.value.haptics, isFalse);
      expect(reloaded.value.reduceMotion, isTrue);
    });

    testWidgets('c2: Reduce motion drops particles and stretch, keeps a scale pulse', (tester) async {
      await boot(tester, reduceMotion: true);
      await tester.tapAt(nose(tester));
      await tester.pump(const Duration(milliseconds: 16));
      expect(pose(tester).squashX, lessThan(1), reason: 'a simple scale pulse');
      expect(pose(tester).squashX, closeTo(pose(tester).squashY, 0.02), reason: 'uniform, not a squash');
      expect(particles(tester).decorativeCount, 0);
      await tester.pumpAndSettle();

      final g = await tester.startGesture(belly(tester));
      for (var i = 0; i < 8; i++) {
        await g.moveBy(const Offset(12, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(pose(tester).shear, Offset.zero);
      await g.up();
      await tester.pumpAndSettle();

      for (var i = 0; i < 29; i++) {
        await tester.tapAt(nose(tester));
        await tester.pump(const Duration(milliseconds: 60));
      }
      expect(particles(tester).decorativeCount, 0, reason: 'no confetti on the sneeze either');
      await tester.pumpAndSettle();
      await flush(tester);
    });

    testWidgets('c3: reset leaves only settings and the config cache behind', (tester) async {
      final saved = Progress(
        lifetimeBoops: 900, bestCombo: 30, bestRush: 50, selectedId: 'taro', onboardingDone: true, reviewAsked: true,
        celebrated: {for (final c in kCritters) c.id}, dismissedAnnouncements: const {'a'},
      ).toJson();
      await boot(tester, prefs: {ProgressStore.storageKey: jsonEncode(saved)});
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('set-sound')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('set-reset')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('reset-confirm')));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      final allowed = {...SettingsService.allKeys, ...RemoteConfigService.allKeys};
      expect(prefs.getKeys().difference(allowed), isEmpty);
      final p = services.progress.value;
      expect(p.toJson(), const Progress().toJson(), reason: 'every field back to first launch');
      await flush(tester);
    });
  });

  group('F8 — remote config', () {
    testWidgets('c1: a malformed cached blob falls back to defaults without crashing', (tester) async {
      await boot(tester, prefs: {'rc.cache': '{"dailyGoal": 7, oops'});
      expect(services.remote.value.dailyGoal, RemoteConfig.defaults.dailyGoal);
      expect(find.text('Today 0/50'), findsOneWidget);
      await boot(tester, prefs: {'rc.cache': '[1, 2, 3]'});
      expect(services.remote.value.rushEnabled, isTrue);
    });
  });
}
