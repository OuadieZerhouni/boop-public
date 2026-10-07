import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';

import '../audio/sfx.dart';
import '../game/combo.dart';
import '../game/critters.dart';
import '../game/progress.dart';
import 'remote_config.dart';
import 'settings.dart';
import 'test_env.dart';

/// Something worth celebrating, raised by [AppServices.boop] and shown by the
/// shell no matter which tab is open.
sealed class BoopEvent {
  const BoopEvent();
}

class UnlockEvent extends BoopEvent {
  const UnlockEvent(this.critter);
  final CritterSpecies critter;
}

class GoalMetEvent extends BoopEvent {
  const GoalMetEvent(this.streak);
  final int streak;
}

/// Everything the UI needs, created once at startup.
class AppServices {
  AppServices({
    required this.settings,
    required this.remote,
    required this.progress,
    required this.sound,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final SettingsService settings;
  final RemoteConfigService remote;
  final ProgressStore progress;
  final SoundBoard sound;
  final DateTime Function() clock;

  /// The home-screen combo. Lives here (not in a widget) so switching tabs
  /// mid-combo does not silently restart it.
  final ComboTracker combo = ComboTracker();

  final _events = StreamController<BoopEvent>.broadcast();
  Stream<BoopEvent> get events => _events.stream;

  int get dailyGoal => remote.value.dailyGoal;

  /// Records [n] real boops on critter [id] and raises any celebrations.
  BoopOutcome boop(String id, {int n = 1}) {
    final outcome = progress.addBoops(id, n, goal: dailyGoal);
    for (final c in outcome.newUnlocks) {
      _events.add(UnlockEvent(c));
    }
    if (outcome.goalJustMet) {
      _events.add(GoalMetEvent(progress.value.streakAt(clock())));
    }
    return outcome;
  }

  /// Asks for an App Store review once, after a few unlocks — a happy moment,
  /// never mid-interaction. Apple rate-limits the prompt on its own too.
  Future<void> maybeAskForReview() async {
    final p = progress.value;
    final cfg = remote.value;
    if (!cfg.reviewPromptEnabled || p.reviewAsked) return;
    if (p.unlockedCount - 1 < cfg.reviewAfterUnlocks) return;
    progress.markReviewAsked();
    if (skipDeviceOnlyWork) return;
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) await review.requestReview();
    } catch (e) {
      debugPrint('review prompt skipped: $e');
    }
  }

  Future<void> resetProgress() async {
    combo.reset();
    await progress.reset();
  }

  static Future<AppServices> create({DateTime Function()? clock}) async {
    final settings = SettingsService();
    final remote = RemoteConfigService();
    final progress = ProgressStore(clock: clock);
    await Future.wait([settings.load(), remote.init(), progress.load()]);
    final sound = SoundBoard(settings);
    unawaited(sound.init());
    return AppServices(settings: settings, remote: remote, progress: progress, sound: sound, clock: clock);
  }

  void dispose() {
    _events.close();
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});
  final AppServices services;

  static AppServices of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(s != null, 'AppScope missing');
    return s!.services;
  }

  @override
  bool updateShouldNotify(AppScope old) => old.services != services;
}
