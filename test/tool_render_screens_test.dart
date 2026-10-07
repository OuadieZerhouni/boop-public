import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:boop/core/app_services.dart';
import 'package:boop/game/progress.dart';
import 'package:boop/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dev tool (skipped by default): renders real app screens at the App Store
/// 6.9" size (440×956 pt @3x = 1320×2868 px), so layouts are judged by looking
/// and the store-screenshot pipeline has raw frames.
///
///   RENDER_SCREENS=1 flutter test test/tool_render_screens_test.dart
///
/// Writes build/shots/*.png. Captures run inside `tester.runAsync`, because
/// toImage never completes in fake-async.
void main() {
  final run = Platform.environment.containsKey('RENDER_SCREENS');
  const shotKey = ValueKey('shot');
  late AppServices services;

  Map<String, Object> playedPrefs() {
    final now = DateTime.now();
    final j = const Progress(lifetimeBoops: 640).toJson()
      ..['sel'] = 'bao'
      ..['cel'] = ['mochi', 'pip', 'bao', 'kiwi', 'momo', 'puff', 'nori', 'taro']
      ..['per'] = {'mochi': 210, 'pip': 96, 'bao': 180, 'kiwi': 64, 'momo': 40, 'puff': 30, 'nori': 14, 'taro': 6}
      ..['todayKey'] = dayKey(now)
      ..['today'] = 34
      ..['goalDay'] = previousDayKey(dayKey(now))
      ..['streak'] = 6
      ..['bestCombo'] = 42
      ..['bestRush'] = 31
      ..['onb'] = true;
    return {ProgressStore.storageKey: jsonEncode(j)};
  }

  Future<void> boot(WidgetTester tester, {Map<String, Object> prefs = const {}, String? lang}) async {
    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    services = (await tester.runAsync(() => AppServices.create()))!;
    if (lang != null) {
      await tester.runAsync(() => services.settings.update(services.settings.value.copyWith(languageCode: lang)));
    }
    await tester.pumpWidget(RepaintBoundary(key: shotKey, child: BoopApp(services: services)));
    await tester.pumpAndSettle();
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.runAsync(() async {
      final ro = tester.renderObject<RenderRepaintBoundary>(find.byKey(shotKey));
      final img = await ro.toImage(pixelRatio: 3);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      File('build/shots/$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  for (final lang in ['en', 'ar', 'ja']) {
    testWidgets('render $lang screens', (tester) async {
      await boot(tester, prefs: playedPrefs(), lang: lang);
      await shot(tester, '${lang}_1_boop');

      await tester.tap(find.byKey(const ValueKey('tab-1')));
      await tester.pumpAndSettle();
      await shot(tester, '${lang}_2_critters');

      await tester.tap(find.byKey(const ValueKey('tab-2')));
      await tester.pumpAndSettle();
      await shot(tester, '${lang}_3_rush_intro');
      await tester.tap(find.byKey(const ValueKey('rush-start')));
      for (var i = 0; i < 260; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await shot(tester, '${lang}_4_rush_play');
      for (var i = 0; i < 2000; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      await shot(tester, '${lang}_5_rush_over');

      await tester.tap(find.byKey(const ValueKey('tab-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();
      await shot(tester, '${lang}_6_settings');
      await tester.pump(const Duration(seconds: 5));
    }, skip: !run);
  }

  testWidgets('render first launch', (tester) async {
    await boot(tester);
    await shot(tester, 'en_0_first_launch');
  }, skip: !run);
}
