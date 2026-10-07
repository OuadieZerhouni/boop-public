import 'dart:convert';

import 'package:boop/core/app_services.dart';
import 'package:boop/core/remote_config.dart';
import 'package:boop/game/critters.dart';
import 'package:boop/game/progress.dart';
import 'package:boop/main.dart';
import 'package:boop/ui/critter_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The real app, on a phone-sized screen, driven like a player would.
void main() {
  late AppServices services;

  Future<void> boot(WidgetTester tester, {Map<String, Object> prefs = const {}, Locale? locale, double textScale = 1}) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    services = (await tester.runAsync(() => AppServices.create()))!;
    if (locale != null) {
      await tester.runAsync(() => services.settings.update(services.settings.value.copyWith(languageCode: locale.languageCode)));
    }
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(size: const Size(390, 844), devicePixelRatio: 3, textScaler: TextScaler.linear(textScale)),
      child: BoopApp(services: services),
    ));
    await tester.pumpAndSettle();
  }

  Offset nose(WidgetTester tester) {
    final stage = find.byKey(const ValueKey('critter-stage'));
    final size = tester.getSize(stage);
    final side = size.shortestSide;
    final topLeft = tester.getTopLeft(stage) + Offset((size.width - side) / 2, (size.height - side) / 2);
    return topLeft + CritterGeometry(side, services.progress.value.selected).nose;
  }

  Future<void> boop(WidgetTester tester, {int times = 1}) async {
    for (var i = 0; i < times; i++) {
      await tester.tapAt(nose(tester));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pumpAndSettle();
  }

  Future<void> flushSnackBars(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('first launch: Mochi, zero boops, and the boop hint', (tester) async {
    await boot(tester);
    expect(find.text('Mochi'), findsOneWidget);
    expect(find.text('No boops yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-hint')), findsOneWidget);
    expect(find.text('Next friend in 30 boops'), findsOneWidget);
  });

  testWidgets('a nose tap is a boop; a body tap is not; the hint goes away (F1, F7)', (tester) async {
    await boot(tester);
    await boop(tester);
    expect(services.progress.value.lifetimeBoops, 1);
    expect(find.text('1 boop'), findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-hint')), findsNothing);

    // Tap the belly, well away from the nose: a giggle, not a boop.
    final stage = find.byKey(const ValueKey('critter-stage'));
    final c = tester.getCenter(stage);
    await tester.tapAt(c + Offset(tester.getSize(stage).shortestSide * 0.2, tester.getSize(stage).shortestSide * 0.2));
    await tester.pumpAndSettle();
    expect(services.progress.value.lifetimeBoops, 1);

    // Tapping empty space around the critter does nothing either.
    await tester.tapAt(tester.getTopLeft(stage) + const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(services.progress.value.lifetimeBoops, 1);
  });

  testWidgets('combo pill and tier banner (F2)', (tester) async {
    await boot(tester);
    await boop(tester, times: 3);
    expect(find.text('Combo ×3'), findsOneWidget);
    for (var i = 0; i < 7; i++) {
      await tester.tapAt(nose(tester));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Boop-a-doop!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(services.progress.value.bestCombo, 10);
  });

  testWidgets('30 boops unlock Pip with a celebration, once (F3)', (tester) async {
    await boot(tester);
    await boop(tester, times: 30);
    expect(find.byKey(const ValueKey('unlock-dialog')), findsOneWidget);
    expect(find.text('Say hi to Pip!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('unlock-boop')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('unlock-dialog')), findsNothing);
    expect(find.text('Pip'), findsOneWidget, reason: '"Boop them!" switches to the new friend');
    expect(services.progress.value.selectedId, 'pip');
    expect(services.progress.value.celebrated, contains('pip'));

    // More boops do not re-celebrate.
    await boop(tester, times: 3);
    expect(find.byKey(const ValueKey('unlock-dialog')), findsNothing);
    await flushSnackBars(tester);
  });

  testWidgets('celebrations missed while the app was closed are shown on launch', (tester) async {
    final saved = const Progress(lifetimeBoops: 100).toJson();
    await boot(tester, prefs: {ProgressStore.storageKey: jsonEncode(saved)});
    expect(find.text('Say hi to Pip!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('unlock-later')));
    await tester.pumpAndSettle();
    expect(find.text('Say hi to Bao!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('unlock-later')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('unlock-dialog')), findsNothing);
    expect(services.progress.value.selectedId, 'mochi', reason: '"Later" keeps the current critter');
  });

  testWidgets('daily goal toast (F4)', (tester) async {
    await boot(tester);
    services.remote.value = RemoteConfig.fromJson({'dailyGoal': 10});
    await tester.pump();
    await boop(tester, times: 9);
    await tester.tapAt(nose(tester));
    await tester.pump(const Duration(milliseconds: 500)); // the toast lives 2 s; look while it is up
    expect(find.text('Daily boops done!'), findsOneWidget);
    expect(services.progress.value.streakAt(DateTime.now()), 1);
    await flushSnackBars(tester);
  });

  testWidgets('collection: 12 cards, locked explains, unlocked selects (F3)', (tester) async {
    final saved = Progress(lifetimeBoops: 90, celebrated: {for (final c in kCritters) c.id}).toJson();
    await boot(tester, prefs: {ProgressStore.storageKey: jsonEncode(saved)});
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('3 of 12 friends'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('critter-card-kiwi')));
    await tester.pump();
    expect(find.text('Boop 60 more times to meet this friend.'), findsOneWidget);
    expect(services.progress.value.selectedId, 'mochi');

    await tester.tap(find.byKey(const ValueKey('critter-card-bao')));
    await tester.pumpAndSettle();
    expect(services.progress.value.selectedId, 'bao');
    expect(find.text('Bao'), findsOneWidget, reason: 'back on the Boop tab with Bao');

    // Every card exists somewhere in the scrollable grid.
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    for (final c in kCritters) {
      await tester.scrollUntilVisible(find.byKey(ValueKey('critter-card-${c.id}')), 200, scrollable: find.byType(Scrollable).last);
    }
    await flushSnackBars(tester);
  });

  testWidgets('Boop Rush: a full round scores, saves the best, credits boops (F5)', (tester) async {
    await boot(tester);
    await tester.tap(find.byKey(const ValueKey('tab-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rush-start')));
    await tester.pump();
    // Play: tap every bush every 120 ms for the whole round.
    for (var t = 0; t < 31000; t += 120) {
      for (var i = 0; i < 9; i++) {
        await tester.tap(find.byKey(ValueKey('bush-$i')), warnIfMissed: false);
      }
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rush-results')), findsOneWidget);
    final p = services.progress.value;
    expect(p.bestRush, greaterThan(0));
    expect(p.lifetimeBoops, greaterThan(0), reason: 'awake critters booped in Rush count as boops');
    expect(find.text('New best!'), findsOneWidget);

    // Play again resets the round.
    await tester.tap(find.byKey(const ValueKey('rush-again')));
    await tester.pump();
    expect(find.byKey(const ValueKey('rush-results')), findsNothing);
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rush-results')), findsOneWidget);
    expect(find.text("Time's up!"), findsOneWidget, reason: 'an idle round is not a new best');
    await flushSnackBars(tester);
  });

  testWidgets('Rush kill switch shows the resting message (F5/F8)', (tester) async {
    await boot(tester);
    services.remote.value = RemoteConfig.fromJson({'features': {'rushEnabled': false}});
    await tester.tap(find.byKey(const ValueKey('tab-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rush-resting')), findsOneWidget);
    expect(find.byKey(const ValueKey('rush-start')), findsNothing);
  });

  testWidgets('settings persist; Arabic switches the UI to RTL; reset is complete (F6)', (tester) async {
    await boot(tester);
    await boop(tester, times: 3);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('set-sound')));
    await tester.tap(find.byKey(const ValueKey('set-motion')));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('set.sound'), isFalse);
    expect(prefs.getBool('set.reduceMotion'), isTrue);

    await tester.tap(find.byKey(const ValueKey('set-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('lang-ar')));
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات'), findsWidgets);
    expect(Directionality.of(tester.element(find.text('الإعدادات').first)), TextDirection.rtl);
    expect(prefs.getString('set.lang'), 'ar');

    await tester.tap(find.byKey(const ValueKey('set-reset')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reset-confirm')));
    await tester.pumpAndSettle();
    expect(services.progress.value.lifetimeBoops, 0);
    expect(prefs.getString(ProgressStore.storageKey), isNull, reason: 'reset removes the whole progress key');
    expect(prefs.getBool('set.sound'), isFalse, reason: 'settings are not progress');

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('onboarding-hint')), findsOneWidget, reason: 'back to first-launch state');
    await flushSnackBars(tester);
  });

  for (final lang in ['en', 'ar', 'de', 'es', 'fr', 'ja', 'pt']) {
    testWidgets('no overflow in $lang at 1.3× text on every tab', (tester) async {
      final saved = Progress(lifetimeBoops: 3200, bestCombo: 77, bestRush: 120, onboardingDone: true, celebrated: {for (final c in kCritters) c.id}).toJson();
      await boot(tester, prefs: {ProgressStore.storageKey: jsonEncode(saved)}, locale: Locale(lang), textScale: 1.3);
      expect(tester.takeException(), isNull);
      for (final tab in [1, 2, 0]) {
        await tester.tap(find.byKey(ValueKey('tab-$tab')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'tab $tab overflowed in $lang');
      }
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'settings overflowed in $lang');
    });
  }
}
