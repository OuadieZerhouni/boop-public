// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Boop!';

  @override
  String get tabBoop => 'Boop';

  @override
  String get tabCritters => 'Amis';

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
      zero: 'Pas encore de boop',
    );
    return '$_temp0';
  }

  @override
  String todayProgress(int done, int goal) {
    return 'Aujourd\'hui $done/$goal';
  }

  @override
  String get dailyDone => 'Boops du jour terminés !';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série de $count jours',
      one: 'Série de 1 jour',
    );
    return '$_temp0';
  }

  @override
  String comboLabel(int count) {
    return 'Combo ×$count';
  }

  @override
  String get tierBoopADoop => 'Boop-a-doop !';

  @override
  String get tierSnootStorm => 'Tempête de boops !';

  @override
  String get tierMegaBoop => 'Méga boop !';

  @override
  String get achoo => 'Atchoum !';

  @override
  String get onboardingHint => 'Touche le petit nez !';

  @override
  String semanticsCritter(String name) {
    return '$name. Touchez deux fois pour faire boop sur le nez.';
  }

  @override
  String get settingsTooltip => 'Réglages';

  @override
  String get unlockTitle => 'Nouvel ami !';

  @override
  String unlockBody(String name) {
    return 'Dis bonjour à $name !';
  }

  @override
  String get unlockBoop => 'Faire boop !';

  @override
  String get unlockLater => 'Plus tard';

  @override
  String get collectionTitle => 'Tes amis';

  @override
  String collectionCount(int unlocked, int total) {
    return '$unlocked amis sur $total';
  }

  @override
  String nextFriend(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prochain ami dans $countString boops',
      one: 'Prochain ami dans 1 boop',
    );
    return '$_temp0';
  }

  @override
  String get everyoneHere => 'Tout le monde est là !';

  @override
  String lockedRemaining(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $countString boops',
      one: 'Encore 1 boop',
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
      other: 'Encore $countString boops pour rencontrer cet ami.',
      one: 'Encore 1 boop pour rencontrer cet ami.',
    );
    return '$_temp0';
  }

  @override
  String bestCombo(int count) {
    return 'Meilleur combo ×$count';
  }

  @override
  String get nowBooping => 'En ce moment';

  @override
  String get rushTitle => 'Boop Rush';

  @override
  String get rushIntro =>
      'Fais boop aux amis réveillés le plus vite possible !';

  @override
  String get rushRuleSleepy => 'Ne touche pas ceux qui dorment';

  @override
  String get rushRuleGolden => 'Doré = 5 points';

  @override
  String get rushStart => 'Jouer';

  @override
  String get rushScore => 'Score';

  @override
  String get rushBest => 'Record';

  @override
  String get rushTime => 'Temps';

  @override
  String get rushOver => 'Temps écoulé !';

  @override
  String get rushNewBest => 'Nouveau record !';

  @override
  String get rushPlayAgain => 'Rejouer';

  @override
  String get rushResting => 'Rush fait une pause. Reviens bientôt !';

  @override
  String rushBoopsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count boops pour tes amis',
      one: '+1 boop pour tes amis',
    );
    return '$_temp0';
  }

  @override
  String rushStreak(int count) {
    return 'Série ×$count';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSound => 'Son';

  @override
  String get settingsHaptics => 'Vibrations';

  @override
  String get settingsReduceMotion => 'Réduire les animations';

  @override
  String get settingsReduceMotionHint =>
      'Moins de particules et de tremblements';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get settingsRate => 'Noter Boop!';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsSupport => 'Assistance';

  @override
  String get settingsReset => 'Réinitialiser la progression';

  @override
  String get resetTitle => 'Tout réinitialiser ?';

  @override
  String get resetBody =>
      'Tes boops, amis, séries et records seront perdus. Action irréversible.';

  @override
  String get resetConfirm => 'Réinitialiser';

  @override
  String get resetDone => 'Nouveau départ ! Mochi te dit bonjour.';

  @override
  String get cancel => 'Annuler';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get madeWithLove => 'Sans pub. Sans pistage. Juste des boops.';

  @override
  String get updateAvailable => 'Une nouvelle version de Boop! est prête.';

  @override
  String get updateAction => 'Mettre à jour';

  @override
  String get dismiss => 'Fermer';

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
  String get kindMochi => 'lapin';

  @override
  String get kindPip => 'poussin';

  @override
  String get kindBao => 'panda';

  @override
  String get kindKiwi => 'grenouille';

  @override
  String get kindMomo => 'bébé hippo';

  @override
  String get kindPuff => 'agneau nuage';

  @override
  String get kindNori => 'phoque';

  @override
  String get kindTaro => 'hamster';

  @override
  String get kindCoco => 'chiot';

  @override
  String get kindJelly => 'méduse';

  @override
  String get kindSprout => 'lutin feuille';

  @override
  String get kindStar => 'bébé dragon';
}
