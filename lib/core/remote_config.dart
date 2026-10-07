import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_env.dart';

/// Where the live config lives: a public, JSON-only GitHub repo shared by the
/// owner's apps. Contains no secrets by design — anyone can read it.
const kRemoteConfigUrl = 'https://raw.githubusercontent.com/OuadieZerhouni/app-configs/main/boop/config.json';

/// A localized string map: {"en": "...", "de": "..."} → best match.
@immutable
class LocalizedText {
  const LocalizedText(this.values);
  final Map<String, String> values;

  String resolve(String languageCode) => values[languageCode] ?? values['en'] ?? values.values.firstOrNull ?? '';

  bool get isEmpty => values.values.every((v) => v.trim().isEmpty);

  factory LocalizedText.fromJson(Object? j) {
    if (j is String) return LocalizedText({'en': j});
    if (j is Map) return LocalizedText(j.map((k, v) => MapEntry('$k', '$v')));
    return const LocalizedText({});
  }
}

@immutable
class Announcement {
  const Announcement({required this.id, required this.title, required this.body, this.url = ''});
  final String id;
  final LocalizedText title;
  final LocalizedText body;
  final String url;
}

/// Everything the app can be tuned with remotely. See docs/REMOTE_CONFIG.md.
///
/// Rules: config tunes behaviour, it never invents it; every key has a safe
/// code default; malformed values fall back or clamp rather than crash. The
/// very first launch has no fetched config, so [RemoteConfig.defaults] must be
/// a complete, shippable app on its own.
@immutable
class RemoteConfig {
  const RemoteConfig({
    this.schemaVersion = 1,
    this.minSupportedVersion = '1.0.0',
    this.latestVersion = '1.0.0',
    this.updateUrlIos = '',
    this.announcement,
    this.rushEnabled = true,
    this.dailyGoal = 50,
    this.rushDurationSec = 30,
    this.reviewPromptEnabled = true,
    this.reviewAfterUnlocks = 3,
    this.privacyUrl = 'https://github.com/OuadieZerhouni/app-configs/blob/main/boop/PRIVACY.md',
    this.supportUrl = 'https://github.com/OuadieZerhouni/app-configs/blob/main/boop/SUPPORT.md',
    this.adsEnabled = false,
  });

  static const defaults = RemoteConfig();

  final int schemaVersion;
  final String minSupportedVersion;
  final String latestVersion;
  final String updateUrlIos;
  final Announcement? announcement;

  /// Kill switch for the Boop Rush tab.
  final bool rushEnabled;

  /// Boops that complete the day. Clamped 10–500.
  final int dailyGoal;

  /// Length of one Boop Rush round, seconds. Clamped 15–60.
  final int rushDurationSec;

  final bool reviewPromptEnabled;

  /// Ask for a review once this many critters are unlocked (beyond the first).
  final int reviewAfterUnlocks;

  final String privacyUrl;
  final String supportUrl;

  /// Reserved: v1 ships with no ad code at all, so this can only ever be read,
  /// never acted on. Present so the schema is stable if ads ever arrive.
  final bool adsEnabled;

  factory RemoteConfig.fromJson(Map<String, dynamic> j) {
    const d = RemoteConfig.defaults;
    T pick<T>(Object? v, T fallback) => v is T ? v : fallback;
    int pickInt(Object? v, int fallback) => v is num ? v.round() : fallback;
    String pickUrl(Object? v, String fallback) {
      if (v is! String) return fallback;
      final u = Uri.tryParse(v);
      return (u != null && u.scheme == 'https' && u.host.isNotEmpty) ? v : fallback;
    }

    final features = pick<Map<String, dynamic>>(j['features'], const {});
    final rush = pick<Map<String, dynamic>>(j['rush'], const {});
    final review = pick<Map<String, dynamic>>(j['reviewPrompt'], const {});
    final links = pick<Map<String, dynamic>>(j['links'], const {});
    final ads = pick<Map<String, dynamic>>(j['ads'], const {});

    Announcement? ann;
    final a = j['announcement'];
    if (a is Map<String, dynamic> && a['enabled'] == true && (a['id'] ?? '').toString().isNotEmpty) {
      final candidate = Announcement(
        id: a['id'].toString(),
        title: LocalizedText.fromJson(a['title']),
        body: LocalizedText.fromJson(a['body']),
        url: pickUrl(a['url'], ''),
      );
      if (!candidate.title.isEmpty || !candidate.body.isEmpty) ann = candidate;
    }

    return RemoteConfig(
      schemaVersion: pickInt(j['schemaVersion'], d.schemaVersion),
      minSupportedVersion: pick<String>(j['minSupportedVersion'], d.minSupportedVersion),
      latestVersion: pick<String>(j['latestVersion'], d.latestVersion),
      updateUrlIos: pickUrl(j['updateUrlIos'], d.updateUrlIos),
      announcement: ann,
      rushEnabled: pick<bool>(features['rushEnabled'], d.rushEnabled),
      dailyGoal: pickInt(j['dailyGoal'], d.dailyGoal).clamp(10, 500),
      rushDurationSec: pickInt(rush['durationSec'], d.rushDurationSec).clamp(15, 60),
      reviewPromptEnabled: pick<bool>(review['enabled'], d.reviewPromptEnabled),
      reviewAfterUnlocks: pickInt(review['afterUnlocks'], d.reviewAfterUnlocks).clamp(1, 11),
      privacyUrl: pickUrl(links['privacyPolicy'], d.privacyUrl),
      supportUrl: pickUrl(links['support'], d.supportUrl),
      adsEnabled: pick<bool>(ads['enabled'], false),
    );
  }
}

/// Fetches, caches and exposes [RemoteConfig].
///
/// Startup never waits on the network: the cached copy (or the code defaults)
/// is available synchronously, and a fresh fetch replaces it when it lands —
/// at most once per [minFetchInterval]. The whole app works offline.
class RemoteConfigService extends ValueNotifier<RemoteConfig> {
  RemoteConfigService() : super(RemoteConfig.defaults);

  static const _cacheKey = 'rc.cache';
  static const _fetchedAtKey = 'rc.fetchedAt';
  static const minFetchInterval = Duration(hours: 6);

  /// Keys this service owns. Deliberately NOT cleared by "reset progress":
  /// config is not progress.
  static const allKeys = [_cacheKey, _fetchedAtKey];

  String appVersion = '1.0.0';

  Future<void> init() async {
    try {
      appVersion = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    int fetchedAt = 0;
    try {
      final p = await SharedPreferences.getInstance();
      final cached = p.getString(_cacheKey);
      fetchedAt = p.getInt(_fetchedAtKey) ?? 0;
      if (cached != null) {
        final j = jsonDecode(cached);
        if (j is Map<String, dynamic>) value = RemoteConfig.fromJson(j);
      }
    } catch (_) {}
    final age = DateTime.now().millisecondsSinceEpoch - fetchedAt;
    if (!skipDeviceOnlyWork && age > minFetchInterval.inMilliseconds) unawaited(refresh());
  }

  Future<void> refresh() async {
    try {
      final res = await http
          .get(Uri.parse('$kRemoteConfigUrl?t=${DateTime.now().millisecondsSinceEpoch ~/ 600000}'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return;
      final body = utf8.decode(res.bodyBytes);
      final j = jsonDecode(body);
      if (j is! Map<String, dynamic>) return;
      value = RemoteConfig.fromJson(j);
      final p = await SharedPreferences.getInstance();
      await p.setString(_cacheKey, body);
      await p.setInt(_fetchedAtKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('remote config fetch skipped: $e');
    }
  }

  /// True when the running build is older than the minimum supported one.
  bool get updateRequired => compareVersions(appVersion, value.minSupportedVersion) < 0;
  bool get updateAvailable => compareVersions(appVersion, value.latestVersion) < 0;
}

/// Semantic-ish version compare: "1.2.10" > "1.2.9". Non-numeric parts → 0.
int compareVersions(String a, String b) {
  List<int> parts(String v) => v.split(RegExp(r'[.+-]')).take(3).map((p) => int.tryParse(p) ?? 0).toList();
  final pa = parts(a), pb = parts(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}
