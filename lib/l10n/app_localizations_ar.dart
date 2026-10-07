// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Boop!';

  @override
  String get tabBoop => 'بوب';

  @override
  String get tabCritters => 'الأصدقاء';

  @override
  String get tabRush => 'السباق';

  @override
  String boopCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString بوب',
      many: '$countString بوبًا',
      few: '$countString بوبات',
      two: 'بوبان',
      one: 'بوب واحد',
      zero: 'لا بوب بعد',
    );
    return '$_temp0';
  }

  @override
  String todayProgress(int done, int goal) {
    return 'اليوم $done/$goal';
  }

  @override
  String get dailyDone => 'أنجزت بوبات اليوم!';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سلسلة $count يوم',
      many: 'سلسلة $count يومًا',
      few: 'سلسلة $count أيام',
      two: 'سلسلة يومين',
      one: 'سلسلة يوم واحد',
      zero: 'لا سلسلة',
    );
    return '$_temp0';
  }

  @override
  String comboLabel(int count) {
    return 'كومبو ×$count';
  }

  @override
  String get tierBoopADoop => 'بوب-آ-دوب!';

  @override
  String get tierSnootStorm => 'عاصفة البوب!';

  @override
  String get tierMegaBoop => 'بوب خارق!';

  @override
  String get achoo => 'أتشوو!';

  @override
  String get onboardingHint => 'المس الأنف الصغير!';

  @override
  String semanticsCritter(String name) {
    return '$name. اضغط مرتين لتلمس الأنف.';
  }

  @override
  String get settingsTooltip => 'الإعدادات';

  @override
  String get unlockTitle => 'صديق جديد!';

  @override
  String unlockBody(String name) {
    return 'قل مرحبًا لـ$name!';
  }

  @override
  String get unlockBoop => 'هيا نلعب!';

  @override
  String get unlockLater => 'لاحقًا';

  @override
  String get collectionTitle => 'أصدقاؤك';

  @override
  String collectionCount(int unlocked, int total) {
    return '$unlocked من $total أصدقاء';
  }

  @override
  String nextFriend(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'صديق جديد بعد $countString بوب',
      many: 'صديق جديد بعد $countString بوبًا',
      few: 'صديق جديد بعد $countString بوبات',
      two: 'صديق جديد بعد بوبين',
      one: 'صديق جديد بعد بوب واحد',
      zero: 'صديق جديد الآن',
    );
    return '$_temp0';
  }

  @override
  String get everyoneHere => 'الجميع هنا!';

  @override
  String lockedRemaining(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بقي $countString بوب',
      many: 'بقي $countString بوبًا',
      few: 'بقيت $countString بوبات',
      two: 'بقي بوبان',
      one: 'بقي بوب واحد',
      zero: 'جاهز!',
    );
    return '$_temp0';
  }

  @override
  String get lockedName => '؟؟؟';

  @override
  String lockedSnack(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString بوب إضافي لتلتقي بهذا الصديق.',
      many: '$countString بوبًا إضافيًا لتلتقي بهذا الصديق.',
      few: '$countString بوبات إضافية لتلتقي بهذا الصديق.',
      two: 'بوبان إضافيان لتلتقي بهذا الصديق.',
      one: 'بوب واحد إضافي لتلتقي بهذا الصديق.',
      zero: 'هذا الصديق جاهز!',
    );
    return '$_temp0';
  }

  @override
  String bestCombo(int count) {
    return 'أفضل كومبو ×$count';
  }

  @override
  String get nowBooping => 'الصديق الحالي';

  @override
  String get rushTitle => 'سباق البوب';

  @override
  String get rushIntro => 'المس الأصدقاء المستيقظين بأسرع ما يمكن!';

  @override
  String get rushRuleSleepy => 'لا تلمس النائمين';

  @override
  String get rushRuleGolden => 'الذهبي = 5 نقاط';

  @override
  String get rushStart => 'ابدأ';

  @override
  String get rushScore => 'النقاط';

  @override
  String get rushBest => 'الأفضل';

  @override
  String rushTime(int seconds) {
    return 'الوقت $seconds ث';
  }

  @override
  String get rushOver => 'انتهى الوقت!';

  @override
  String get rushNewBest => 'رقم قياسي جديد!';

  @override
  String get rushPlayAgain => 'العب مجددًا';

  @override
  String get rushResting => 'السباق في استراحة. عد قريبًا!';

  @override
  String rushBoopsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count بوب لأصدقائك',
      many: '+$count بوبًا لأصدقائك',
      few: '+$count بوبات لأصدقائك',
      two: '+بوبان لأصدقائك',
      one: '+بوب واحد لأصدقائك',
      zero: 'لا بوب هذه المرة',
    );
    return '$_temp0';
  }

  @override
  String rushStreak(int count) {
    return 'سلسلة ×$count';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSound => 'الصوت';

  @override
  String get settingsHaptics => 'الاهتزاز';

  @override
  String get settingsReduceMotion => 'تقليل الحركة';

  @override
  String get settingsReduceMotionHint => 'جزيئات وحركات أقل';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get settingsRate => 'قيّم Boop!';

  @override
  String get settingsPrivacy => 'سياسة الخصوصية';

  @override
  String get settingsSupport => 'الدعم';

  @override
  String get settingsReset => 'إعادة ضبط التقدم';

  @override
  String get resetTitle => 'إعادة ضبط كل التقدم؟';

  @override
  String get resetBody =>
      'ستختفي بوباتك وأصدقاؤك وسلسلتك وأفضل نتائجك. لا يمكن التراجع عن ذلك.';

  @override
  String get resetConfirm => 'إعادة ضبط';

  @override
  String get resetDone => 'بداية جديدة! موتشي يقول مرحبًا.';

  @override
  String get cancel => 'إلغاء';

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get madeWithLove => 'بلا إعلانات. بلا تتبّع. فقط بوب.';

  @override
  String get updateAvailable => 'إصدار جديد من Boop! جاهز.';

  @override
  String get updateAction => 'تحديث';

  @override
  String get dismiss => 'إغلاق';

  @override
  String get critterMochi => 'موتشي';

  @override
  String get critterPip => 'بيب';

  @override
  String get critterBao => 'باو';

  @override
  String get critterKiwi => 'كيوي';

  @override
  String get critterMomo => 'مومو';

  @override
  String get critterPuff => 'باف';

  @override
  String get critterNori => 'نوري';

  @override
  String get critterTaro => 'تارو';

  @override
  String get critterCoco => 'كوكو';

  @override
  String get critterJelly => 'جيلي';

  @override
  String get critterSprout => 'برعوم';

  @override
  String get critterStar => 'نجمة';

  @override
  String get kindMochi => 'أرنب';

  @override
  String get kindPip => 'كتكوت';

  @override
  String get kindBao => 'باندا';

  @override
  String get kindKiwi => 'ضفدع';

  @override
  String get kindMomo => 'فرس نهر صغير';

  @override
  String get kindPuff => 'خروف الغيمة';

  @override
  String get kindNori => 'فقمة';

  @override
  String get kindTaro => 'هامستر';

  @override
  String get kindCoco => 'جرو';

  @override
  String get kindJelly => 'قنديل بحر';

  @override
  String get kindSprout => 'جنّية الورقة';

  @override
  String get kindStar => 'تنين صغير';
}
