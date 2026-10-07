// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Boop!';

  @override
  String get tabBoop => 'Boop';

  @override
  String get tabCritters => 'Amigos';

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
      zero: 'Aún sin boops',
    );
    return '$_temp0';
  }

  @override
  String todayProgress(int done, int goal) {
    return 'Hoy $done/$goal';
  }

  @override
  String get dailyDone => '¡Boops del día listos!';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de $count días',
      one: 'Racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String comboLabel(int count) {
    return 'Combo ×$count';
  }

  @override
  String get tierBoopADoop => '¡Boop-a-doop!';

  @override
  String get tierSnootStorm => '¡Tormenta de boops!';

  @override
  String get tierMegaBoop => '¡Mega boop!';

  @override
  String get achoo => '¡Achís!';

  @override
  String get onboardingHint => '¡Toca la naricita!';

  @override
  String semanticsCritter(String name) {
    return '$name. Toca dos veces para hacer boop en la nariz.';
  }

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get unlockTitle => '¡Nuevo amigo!';

  @override
  String unlockBody(String name) {
    return '¡Saluda a $name!';
  }

  @override
  String get unlockBoop => '¡A hacer boop!';

  @override
  String get unlockLater => 'Luego';

  @override
  String get collectionTitle => 'Tus amigos';

  @override
  String collectionCount(int unlocked, int total) {
    return '$unlocked de $total amigos';
  }

  @override
  String nextFriend(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nuevo amigo en $countString boops',
      one: 'Nuevo amigo en 1 boop',
    );
    return '$_temp0';
  }

  @override
  String get everyoneHere => '¡Ya están todos!';

  @override
  String lockedRemaining(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $countString boops',
      one: 'Falta 1 boop',
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
      other: 'Haz $countString boops más para conocer a este amigo.',
      one: 'Haz 1 boop más para conocer a este amigo.',
    );
    return '$_temp0';
  }

  @override
  String bestCombo(int count) {
    return 'Mejor combo ×$count';
  }

  @override
  String get nowBooping => 'Ahora con';

  @override
  String get rushTitle => 'Boop Rush';

  @override
  String get rushIntro =>
      '¡Haz boop a los amigos despiertos lo más rápido que puedas!';

  @override
  String get rushRuleSleepy => 'No toques a los dormidos';

  @override
  String get rushRuleGolden => 'Dorado = 5 puntos';

  @override
  String get rushStart => 'Empezar';

  @override
  String get rushScore => 'Puntos';

  @override
  String get rushBest => 'Récord';

  @override
  String rushTime(int seconds) {
    return 'Tiempo $seconds s';
  }

  @override
  String get rushOver => '¡Se acabó el tiempo!';

  @override
  String get rushNewBest => '¡Nuevo récord!';

  @override
  String get rushPlayAgain => 'Jugar otra vez';

  @override
  String get rushResting => 'Rush está descansando. ¡Vuelve pronto!';

  @override
  String rushBoopsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count boops para tus amigos',
      one: '+1 boop para tus amigos',
    );
    return '$_temp0';
  }

  @override
  String rushStreak(int count) {
    return 'Racha ×$count';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsReduceMotion => 'Reducir movimiento';

  @override
  String get settingsReduceMotionHint => 'Menos partículas y meneos';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get settingsRate => 'Valorar Boop!';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsSupport => 'Soporte';

  @override
  String get settingsReset => 'Restablecer progreso';

  @override
  String get resetTitle => '¿Restablecer todo el progreso?';

  @override
  String get resetBody =>
      'Tus boops, amigos, racha y récords se perderán. No se puede deshacer.';

  @override
  String get resetConfirm => 'Restablecer';

  @override
  String get resetDone => '¡Nuevo comienzo! Mochi te saluda.';

  @override
  String get cancel => 'Cancelar';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get madeWithLove => 'Sin anuncios. Sin rastreo. Solo boops.';

  @override
  String get updateAvailable => 'Hay una nueva versión de Boop!.';

  @override
  String get updateAction => 'Actualizar';

  @override
  String get dismiss => 'Cerrar';

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
  String get kindMochi => 'conejito';

  @override
  String get kindPip => 'pollito';

  @override
  String get kindBao => 'panda';

  @override
  String get kindKiwi => 'rana';

  @override
  String get kindMomo => 'hipopótamo bebé';

  @override
  String get kindPuff => 'ovejita nube';

  @override
  String get kindNori => 'foca';

  @override
  String get kindTaro => 'hámster';

  @override
  String get kindCoco => 'cachorro';

  @override
  String get kindJelly => 'medusa';

  @override
  String get kindSprout => 'duende de hoja';

  @override
  String get kindStar => 'dragoncito';
}
