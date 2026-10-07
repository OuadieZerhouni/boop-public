// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Boop!';

  @override
  String get tabBoop => 'Boop';

  @override
  String get tabCritters => 'Critters';

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
      other: '$countString boops',
      one: '1 boop',
      zero: 'No boops yet',
    );
    return '$_temp0';
  }

  @override
  String todayProgress(int done, int goal) {
    return 'Today $done/$goal';
  }

  @override
  String get dailyDone => 'Daily boops done!';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
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
  String get tierSnootStorm => 'Snoot storm!';

  @override
  String get tierMegaBoop => 'Mega boop!';

  @override
  String get achoo => 'Achoo!';

  @override
  String get onboardingHint => 'Boop the snoot!';

  @override
  String semanticsCritter(String name) {
    return '$name. Double-tap to boop the nose.';
  }

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get unlockTitle => 'New friend!';

  @override
  String unlockBody(String name) {
    return 'Say hi to $name!';
  }

  @override
  String get unlockBoop => 'Boop them!';

  @override
  String get unlockLater => 'Later';

  @override
  String get collectionTitle => 'Your critters';

  @override
  String collectionCount(int unlocked, int total) {
    return '$unlocked of $total friends';
  }

  @override
  String nextFriend(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Next friend in $countString boops',
      one: 'Next friend in 1 boop',
    );
    return '$_temp0';
  }

  @override
  String get everyoneHere => 'Everyone\'s here!';

  @override
  String lockedRemaining(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString more boops',
      one: '1 more boop',
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
      other: 'Boop $countString more times to meet this friend.',
      one: 'Boop 1 more time to meet this friend.',
    );
    return '$_temp0';
  }

  @override
  String bestCombo(int count) {
    return 'Best combo ×$count';
  }

  @override
  String get nowBooping => 'Now booping';

  @override
  String get rushTitle => 'Boop Rush';

  @override
  String get rushIntro => 'Boop the awake critters as fast as you can!';

  @override
  String get rushRuleSleepy => 'Don\'t boop sleepy ones';

  @override
  String get rushRuleGolden => 'Golden = 5 points';

  @override
  String get rushStart => 'Start';

  @override
  String get rushScore => 'Score';

  @override
  String get rushBest => 'Best';

  @override
  String rushTime(int seconds) {
    return 'Time ${seconds}s';
  }

  @override
  String get rushOver => 'Time\'s up!';

  @override
  String get rushNewBest => 'New best!';

  @override
  String get rushPlayAgain => 'Play again';

  @override
  String get rushResting => 'Rush is resting. Come back soon!';

  @override
  String rushBoopsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count boops for your critters',
      one: '+1 boop for your critters',
    );
    return '$_temp0';
  }

  @override
  String rushStreak(int count) {
    return 'Streak ×$count';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsHaptics => 'Haptics';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHint => 'Fewer particles and wiggles';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get settingsRate => 'Rate Boop!';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsReset => 'Reset progress';

  @override
  String get resetTitle => 'Reset all progress?';

  @override
  String get resetBody =>
      'Your boops, critters, streak and best scores will be gone. This can\'t be undone.';

  @override
  String get resetConfirm => 'Reset';

  @override
  String get resetDone => 'Fresh start! Mochi says hi.';

  @override
  String get cancel => 'Cancel';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get madeWithLove => 'No ads. No tracking. Just boops.';

  @override
  String get updateAvailable => 'A new version of Boop! is ready.';

  @override
  String get updateAction => 'Update';

  @override
  String get dismiss => 'Dismiss';

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
  String get kindMochi => 'bunny';

  @override
  String get kindPip => 'chick';

  @override
  String get kindBao => 'panda';

  @override
  String get kindKiwi => 'frog';

  @override
  String get kindMomo => 'baby hippo';

  @override
  String get kindPuff => 'cloud lamb';

  @override
  String get kindNori => 'seal';

  @override
  String get kindTaro => 'hamster';

  @override
  String get kindCoco => 'puppy';

  @override
  String get kindJelly => 'jellyfish';

  @override
  String get kindSprout => 'leaf sprite';

  @override
  String get kindStar => 'baby dragon';
}
