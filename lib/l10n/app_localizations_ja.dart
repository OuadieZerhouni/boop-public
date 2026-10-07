// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Boop!';

  @override
  String get tabBoop => 'ブープ';

  @override
  String get tabCritters => 'なかま';

  @override
  String get tabRush => 'ラッシュ';

  @override
  String boopCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringブープ',
      zero: 'まだブープなし',
    );
    return '$_temp0';
  }

  @override
  String todayProgress(int done, int goal) {
    return '今日 $done/$goal';
  }

  @override
  String get dailyDone => '今日のブープ達成！';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日連続',
    );
    return '$_temp0';
  }

  @override
  String comboLabel(int count) {
    return 'コンボ ×$count';
  }

  @override
  String get tierBoopADoop => 'ブーパドゥー！';

  @override
  String get tierSnootStorm => 'ブープの嵐！';

  @override
  String get tierMegaBoop => 'メガブープ！';

  @override
  String get achoo => 'ハックション！';

  @override
  String get onboardingHint => 'おはなをブープ！';

  @override
  String semanticsCritter(String name) {
    return '$name。ダブルタップでおはなをブープ。';
  }

  @override
  String get settingsTooltip => '設定';

  @override
  String get unlockTitle => '新しいなかま！';

  @override
  String unlockBody(String name) {
    return '$nameにあいさつしよう！';
  }

  @override
  String get unlockBoop => 'ブープする！';

  @override
  String get unlockLater => 'あとで';

  @override
  String get collectionTitle => 'なかまたち';

  @override
  String collectionCount(int unlocked, int total) {
    return '$total匹中 $unlocked匹';
  }

  @override
  String nextFriend(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '次のなかままで あと$countStringブープ',
    );
    return '$_temp0';
  }

  @override
  String get everyoneHere => 'みんなそろった！';

  @override
  String lockedRemaining(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$countStringブープ',
    );
    return '$_temp0';
  }

  @override
  String get lockedName => '？？？';

  @override
  String lockedSnack(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$countString回ブープすると会えるよ。',
    );
    return '$_temp0';
  }

  @override
  String bestCombo(int count) {
    return '最高コンボ ×$count';
  }

  @override
  String get nowBooping => 'いまのなかま';

  @override
  String get rushTitle => 'ブープラッシュ';

  @override
  String get rushIntro => '起きているなかまを素早くブープ！';

  @override
  String get rushRuleSleepy => 'ねている子はブープしないで';

  @override
  String get rushRuleGolden => '金色 = 5点';

  @override
  String get rushStart => 'スタート';

  @override
  String get rushScore => 'スコア';

  @override
  String get rushBest => 'ベスト';

  @override
  String rushTime(int seconds) {
    return 'のこり$seconds秒';
  }

  @override
  String get rushOver => 'タイムアップ！';

  @override
  String get rushNewBest => 'ベスト更新！';

  @override
  String get rushPlayAgain => 'もう一回';

  @override
  String get rushResting => 'ラッシュはお休み中。また来てね！';

  @override
  String rushBoopsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'なかまに+$countブープ',
    );
    return '$_temp0';
  }

  @override
  String rushStreak(int count) {
    return '連続 ×$count';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSound => 'サウンド';

  @override
  String get settingsHaptics => '振動';

  @override
  String get settingsReduceMotion => '動きを減らす';

  @override
  String get settingsReduceMotionHint => 'パーティクルや揺れを減らします';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageSystem => 'システム';

  @override
  String get settingsRate => 'Boop!を評価';

  @override
  String get settingsPrivacy => 'プライバシーポリシー';

  @override
  String get settingsSupport => 'サポート';

  @override
  String get settingsReset => '進行状況をリセット';

  @override
  String get resetTitle => 'すべてリセットしますか？';

  @override
  String get resetBody => 'ブープ、なかま、連続記録、ベストスコアが消えます。元に戻せません。';

  @override
  String get resetConfirm => 'リセット';

  @override
  String get resetDone => 'はじめから！モチがあいさつしてるよ。';

  @override
  String get cancel => 'キャンセル';

  @override
  String settingsVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get madeWithLove => '広告なし。トラッキングなし。ブープだけ。';

  @override
  String get updateAvailable => 'Boop!の新しいバージョンがあります。';

  @override
  String get updateAction => 'アップデート';

  @override
  String get dismiss => '閉じる';

  @override
  String get critterMochi => 'モチ';

  @override
  String get critterPip => 'ピップ';

  @override
  String get critterBao => 'バオ';

  @override
  String get critterKiwi => 'キウイ';

  @override
  String get critterMomo => 'モモ';

  @override
  String get critterPuff => 'パフ';

  @override
  String get critterNori => 'ノリ';

  @override
  String get critterTaro => 'タロ';

  @override
  String get critterCoco => 'ココ';

  @override
  String get critterJelly => 'ゼリー';

  @override
  String get critterSprout => 'スプラウト';

  @override
  String get critterStar => 'スター';

  @override
  String get kindMochi => 'うさぎ';

  @override
  String get kindPip => 'ひよこ';

  @override
  String get kindBao => 'パンダ';

  @override
  String get kindKiwi => 'カエル';

  @override
  String get kindMomo => '赤ちゃんカバ';

  @override
  String get kindPuff => 'くもひつじ';

  @override
  String get kindNori => 'アザラシ';

  @override
  String get kindTaro => 'ハムスター';

  @override
  String get kindCoco => 'こいぬ';

  @override
  String get kindJelly => 'クラゲ';

  @override
  String get kindSprout => 'はっぱの妖精';

  @override
  String get kindStar => 'ちびドラゴン';
}
