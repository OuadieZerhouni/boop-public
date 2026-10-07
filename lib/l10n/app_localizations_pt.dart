// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

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
      zero: 'Nenhum boop ainda',
    );
    return '$_temp0';
  }

  @override
  String todayProgress(int done, int goal) {
    return 'Hoje $done/$goal';
  }

  @override
  String get dailyDone => 'Boops do dia concluídos!';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $count dias',
      one: 'Sequência de 1 dia',
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
  String get tierSnootStorm => 'Tempestade de boops!';

  @override
  String get tierMegaBoop => 'Mega boop!';

  @override
  String get achoo => 'Atchim!';

  @override
  String get onboardingHint => 'Dê um boop no narizinho!';

  @override
  String semanticsCritter(String name) {
    return '$name. Toque duas vezes para dar um boop no nariz.';
  }

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get unlockTitle => 'Novo amigo!';

  @override
  String unlockBody(String name) {
    return 'Diga oi para $name!';
  }

  @override
  String get unlockBoop => 'Dar um boop!';

  @override
  String get unlockLater => 'Depois';

  @override
  String get collectionTitle => 'Seus amigos';

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
      other: 'Novo amigo em $countString boops',
      one: 'Novo amigo em 1 boop',
    );
    return '$_temp0';
  }

  @override
  String get everyoneHere => 'Todos estão aqui!';

  @override
  String lockedRemaining(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $countString boops',
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
      other: 'Mais $countString boops para conhecer este amigo.',
      one: 'Mais 1 boop para conhecer este amigo.',
    );
    return '$_temp0';
  }

  @override
  String bestCombo(int count) {
    return 'Melhor combo ×$count';
  }

  @override
  String get nowBooping => 'Agora com';

  @override
  String get rushTitle => 'Boop Rush';

  @override
  String get rushIntro =>
      'Dê boop nos amigos acordados o mais rápido que puder!';

  @override
  String get rushRuleSleepy => 'Não toque nos que estão dormindo';

  @override
  String get rushRuleGolden => 'Dourado = 5 pontos';

  @override
  String get rushStart => 'Começar';

  @override
  String get rushScore => 'Pontos';

  @override
  String get rushBest => 'Recorde';

  @override
  String rushTime(int seconds) {
    return 'Tempo ${seconds}s';
  }

  @override
  String get rushOver => 'Acabou o tempo!';

  @override
  String get rushNewBest => 'Novo recorde!';

  @override
  String get rushPlayAgain => 'Jogar de novo';

  @override
  String get rushResting => 'O Rush está descansando. Volte logo!';

  @override
  String rushBoopsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count boops para seus amigos',
      one: '+1 boop para seus amigos',
    );
    return '$_temp0';
  }

  @override
  String rushStreak(int count) {
    return 'Sequência ×$count';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSound => 'Som';

  @override
  String get settingsHaptics => 'Vibração';

  @override
  String get settingsReduceMotion => 'Reduzir movimento';

  @override
  String get settingsReduceMotionHint => 'Menos partículas e balanços';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get settingsRate => 'Avaliar o Boop!';

  @override
  String get settingsPrivacy => 'Política de privacidade';

  @override
  String get settingsSupport => 'Suporte';

  @override
  String get settingsReset => 'Redefinir progresso';

  @override
  String get resetTitle => 'Redefinir todo o progresso?';

  @override
  String get resetBody =>
      'Seus boops, amigos, sequência e recordes serão apagados. Isso não pode ser desfeito.';

  @override
  String get resetConfirm => 'Redefinir';

  @override
  String get resetDone => 'Recomeço! A Mochi diz oi.';

  @override
  String get cancel => 'Cancelar';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get madeWithLove => 'Sem anúncios. Sem rastreamento. Só boops.';

  @override
  String get updateAvailable => 'Uma nova versão do Boop! está pronta.';

  @override
  String get updateAction => 'Atualizar';

  @override
  String get dismiss => 'Fechar';

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
  String get kindMochi => 'coelhinho';

  @override
  String get kindPip => 'pintinho';

  @override
  String get kindBao => 'panda';

  @override
  String get kindKiwi => 'sapinho';

  @override
  String get kindMomo => 'filhote de hipopótamo';

  @override
  String get kindPuff => 'ovelhinha nuvem';

  @override
  String get kindNori => 'foca';

  @override
  String get kindTaro => 'hamster';

  @override
  String get kindCoco => 'cachorrinho';

  @override
  String get kindJelly => 'água-viva';

  @override
  String get kindSprout => 'fadinha folha';

  @override
  String get kindStar => 'dragãozinho';
}
