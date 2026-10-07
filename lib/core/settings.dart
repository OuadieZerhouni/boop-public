import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The languages the UI ships in (mirrors `locales.supported` in app.yaml;
/// `manifest_sync_test.dart` keeps the .arb set honest).
const kSupportedLanguages = ['en', 'ar', 'de', 'es', 'fr', 'ja', 'pt'];

@immutable
class AppSettings {
  const AppSettings({
    this.sound = true,
    this.haptics = true,
    this.reduceMotion = false,
    this.languageCode,
  });

  final bool sound;
  final bool haptics;

  /// The user's in-app choice. The effective value also honours the OS
  /// accessibility setting — see `motionReduced` in ui/theme.dart.
  final bool reduceMotion;

  /// null = follow the system language.
  final String? languageCode;

  AppSettings copyWith({
    bool? sound,
    bool? haptics,
    bool? reduceMotion,
    String? languageCode,
    bool clearLanguage = false,
  }) => AppSettings(
    sound: sound ?? this.sound,
    haptics: haptics ?? this.haptics,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
  );
}

/// Persisted user preferences. Not progress: "Reset progress" keeps these.
class SettingsService extends ValueNotifier<AppSettings> {
  SettingsService() : super(const AppSettings());

  static const _kSound = 'set.sound';
  static const _kHaptics = 'set.haptics';
  static const _kMotion = 'set.reduceMotion';
  static const _kLang = 'set.lang';

  static const allKeys = [_kSound, _kHaptics, _kMotion, _kLang];

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final lang = p.getString(_kLang);
    value = AppSettings(
      sound: p.getBool(_kSound) ?? true,
      haptics: p.getBool(_kHaptics) ?? true,
      reduceMotion: p.getBool(_kMotion) ?? false,
      languageCode: (lang != null && kSupportedLanguages.contains(lang)) ? lang : null,
    );
  }

  Future<void> update(AppSettings s) async {
    value = s;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSound, s.sound);
    await p.setBool(_kHaptics, s.haptics);
    await p.setBool(_kMotion, s.reduceMotion);
    await p.setString(_kLang, s.languageCode ?? '');
  }
}
