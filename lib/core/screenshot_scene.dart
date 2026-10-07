import '../game/progress.dart';
import 'debug_flags.dart';

/// The App Store screenshot scenes (`screenshots/screens.yaml`), chosen at
/// build time with `--dart-define=DEBUG_SCREEN=<name>`. `DebugFlags.screen`
/// is a compile-time constant, so every branch on it is stripped from a
/// release build.
enum Scene { boop, critters, combo, rush, settings }

final Scene? debugScene = Scene.values.where((s) => s.name == DebugFlags.screen).firstOrNull;

/// A few days of play: eight friends, Bao selected, a streak going.
/// Mirrors `playedPrefs()` in test/tool_render_screens_test.dart.
Progress playedProgress(DateTime now) => Progress(
  lifetimeBoops: 640,
  perCritter: const {'mochi': 210, 'pip': 96, 'bao': 180, 'kiwi': 64, 'momo': 40, 'puff': 30, 'nori': 14, 'taro': 6},
  selectedId: 'bao',
  celebrated: const {'mochi', 'pip', 'bao', 'kiwi', 'momo', 'puff', 'nori', 'taro'},
  bestCombo: 42,
  bestRush: 31,
  todayKey: dayKey(now),
  todayBoops: 18,
  lastGoalDay: previousDayKey(dayKey(now)),
  streak: 6,
  onboardingDone: true,
);
