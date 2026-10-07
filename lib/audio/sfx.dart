import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/settings.dart';
import '../core/test_env.dart';

/// Every one-shot sound in the app. Files are rendered by
/// tools/audio/make_sounds.py into assets/sounds/.
enum Sfx { giggle, boing, chime, fanfare, pop, golden, oops, sneeze, whoosh, tick, hug }

/// Plays sounds and haptics, honouring [SettingsService].
///
/// Sounds go through small [AudioPool]s so rapid boops overlap instead of
/// cutting each other off. The iOS session is `ambient`: it respects the
/// silent switch and mixes with the user's music — a toy must never stop a
/// podcast.
///
/// Every call is fire-and-forget and swallows errors: a missing audio route
/// must never break a boop.
class SoundBoard {
  SoundBoard(this.settings);

  final SettingsService settings;
  final Map<String, AudioPool> _pools = {};
  bool _ready = false;
  bool _disabled = false;

  static const boopSteps = 19;

  Future<void> init() async {
    if (skipDeviceOnlyWork) {
      _disabled = true;
      return;
    }
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      final names = [for (var i = 0; i < boopSteps; i++) _boopName(i), for (final s in Sfx.values) s.name];
      for (final n in names) {
        _pools[n] = await AudioPool.create(
          source: AssetSource('sounds/$n.wav'),
          maxPlayers: n.startsWith('boop') ? 3 : 2,
        );
      }
      _ready = true;
    } catch (e) {
      debugPrint('sound init failed, continuing silently: $e');
      _disabled = true;
    }
  }

  static String _boopName(int i) => 'boop_${i.clamp(0, boopSteps - 1).toString().padLeft(2, '0')}';

  /// Sees every sound that passed the Settings check, before the audio route.
  @visibleForTesting
  void Function(String name)? debugOnPlay;

  void _play(String name, {double volume = 1}) {
    if (!settings.value.sound) return;
    debugOnPlay?.call(name);
    if (_disabled || !_ready) return;
    final pool = _pools[name];
    if (pool == null) return;
    unawaited(pool.start(volume: volume).then((_) {}, onError: (Object e) => debugPrint('sfx $name: $e')));
  }

  void boop(int pitchIndex) => _play(_boopName(pitchIndex), volume: 0.9);
  void play(Sfx s, {double volume = 1}) => _play(s.name, volume: volume);

  // ---- haptics ----------------------------------------------------------

  void light() {
    if (settings.value.haptics) HapticFeedback.lightImpact();
  }

  void medium() {
    if (settings.value.haptics) HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (settings.value.haptics) HapticFeedback.heavyImpact();
  }

  void selection() {
    if (settings.value.haptics) HapticFeedback.selectionClick();
  }
}
