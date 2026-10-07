// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Boop!';

  @override
  String get tabBoop => 'Boop';

  @override
  String get tabCritters => 'Freunde';

  @override
  String get tabRush => 'Rush';

  @override
  String boopCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Boops',
      one: '1 Boop',
      zero: 'Noch keine Boops',
    );
    return '$_temp0';
  }

  @override
  String todayProgress(int done, int goal) {
    return 'Heute $done/$goal';
  }

  @override
  String get dailyDone => 'Tagesziel geschafft!';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage in Folge',
      one: '1 Tag in Folge',
    );
    return '$_temp0';
  }

  @override
  String comboLabel(int count) {
    return 'Combo ×$count';
  }

  @override
  String get tierBoopADoop => 'Boop-a-doop!';

  @override
  String get tierSnootStorm => 'Stupser-Sturm!';

  @override
  String get tierMegaBoop => 'Mega-Boop!';

  @override
  String get achoo => 'Hatschi!';

  @override
  String get onboardingHint => 'Stups die Nase!';

  @override
  String semanticsCritter(String name) {
    return '$name. Doppeltippen, um die Nase anzustupsen.';
  }

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get unlockTitle => 'Neuer Freund!';

  @override
  String unlockBody(String name) {
    return 'Sag hallo zu $name!';
  }

  @override
  String get unlockBoop => 'Anstupsen!';

  @override
  String get unlockLater => 'Später';

  @override
  String get collectionTitle => 'Deine Freunde';

  @override
  String collectionCount(int unlocked, int total) {
    return '$unlocked von $total Freunden';
  }

  @override
  String nextFriend(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nächster Freund in $countString Boops',
      one: 'Nächster Freund in 1 Boop',
    );
    return '$_temp0';
  }

  @override
  String get everyoneHere => 'Alle sind da!';

  @override
  String lockedRemaining(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $countString Boops',
      one: 'Noch 1 Boop',
    );
    return '$_temp0';
  }

  @override
  String get lockedName => '???';

  @override
  String lockedSnack(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $countString Boops, dann lernst du diesen Freund kennen.',
      one: 'Noch 1 Boop, dann lernst du diesen Freund kennen.',
    );
    return '$_temp0';
  }

  @override
  String bestCombo(int count) {
    return 'Beste Combo ×$count';
  }

  @override
  String get nowBooping => 'Gerade dran';

  @override
  String get rushTitle => 'Boop Rush';

  @override
  String get rushIntro => 'Stups die wachen Freunde so schnell du kannst!';

  @override
  String get rushRuleSleepy => 'Schlafende nicht anstupsen';

  @override
  String get rushRuleGolden => 'Golden = 5 Punkte';

  @override
  String get rushStart => 'Los!';

  @override
  String get rushScore => 'Punkte';

  @override
  String get rushBest => 'Rekord';

  @override
  String get rushTime => 'Zeit';

  @override
  String get rushOver => 'Zeit ist um!';

  @override
  String get rushNewBest => 'Neuer Rekord!';

  @override
  String get rushPlayAgain => 'Nochmal';

  @override
  String get rushResting => 'Rush macht gerade Pause. Bis bald!';

  @override
  String rushBoopsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count Boops für deine Freunde',
      one: '+1 Boop für deine Freunde',
    );
    return '$_temp0';
  }

  @override
  String rushStreak(int count) {
    return 'Serie ×$count';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSound => 'Ton';

  @override
  String get settingsHaptics => 'Haptik';

  @override
  String get settingsReduceMotion => 'Bewegung reduzieren';

  @override
  String get settingsReduceMotionHint => 'Weniger Partikel und Wackeln';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get settingsRate => 'Boop! bewerten';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsReset => 'Fortschritt zurücksetzen';

  @override
  String get resetTitle => 'Gesamten Fortschritt zurücksetzen?';

  @override
  String get resetBody =>
      'Deine Boops, Freunde, Serie und Rekorde gehen verloren. Das kann nicht rückgängig gemacht werden.';

  @override
  String get resetConfirm => 'Zurücksetzen';

  @override
  String get resetDone => 'Neustart! Mochi sagt hallo.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get madeWithLove => 'Keine Werbung. Kein Tracking. Nur Boops.';

  @override
  String get updateAvailable => 'Eine neue Version von Boop! ist bereit.';

  @override
  String get updateAction => 'Aktualisieren';

  @override
  String get dismiss => 'Schließen';

  @override
  String get critterMochi => 'Mochi';

  @override
  String get critterPip => 'Pip';

  @override
  String get critterBao => 'Bao';

  @override
  String get critterKiwi => 'Kiwi';

  @override
  String get critterMomo => 'Momo';

  @override
  String get critterPuff => 'Puff';

  @override
  String get critterNori => 'Nori';

  @override
  String get critterTaro => 'Taro';

  @override
  String get critterCoco => 'Coco';

  @override
  String get critterJelly => 'Jelly';

  @override
  String get critterSprout => 'Sprout';

  @override
  String get critterStar => 'Star';

  @override
  String get kindMochi => 'Häschen';

  @override
  String get kindPip => 'Küken';

  @override
  String get kindBao => 'Panda';

  @override
  String get kindKiwi => 'Frosch';

  @override
  String get kindMomo => 'Baby-Nilpferd';

  @override
  String get kindPuff => 'Wolkenlamm';

  @override
  String get kindNori => 'Robbe';

  @override
  String get kindTaro => 'Hamster';

  @override
  String get kindCoco => 'Welpe';

  @override
  String get kindJelly => 'Qualle';

  @override
  String get kindSprout => 'Blattgeist';

  @override
  String get kindStar => 'Babydrache';
}
