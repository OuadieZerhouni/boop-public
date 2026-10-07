import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('pt'),
  ];

  /// App name. Keep 'Boop!' untranslated in every language — it is the brand and the search keyword.
  ///
  /// In en, this message translates to:
  /// **'Boop!'**
  String get appTitle;

  /// No description provided for @tabBoop.
  ///
  /// In en, this message translates to:
  /// **'Boop'**
  String get tabBoop;

  /// No description provided for @tabCritters.
  ///
  /// In en, this message translates to:
  /// **'Critters'**
  String get tabCritters;

  /// No description provided for @tabRush.
  ///
  /// In en, this message translates to:
  /// **'Rush'**
  String get tabRush;

  /// No description provided for @boopCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No boops yet} =1{1 boop} other{{count} boops}}'**
  String boopCount(int count);

  /// Daily goal ring label, e.g. 'Today 12/50'.
  ///
  /// In en, this message translates to:
  /// **'Today {done}/{goal}'**
  String todayProgress(int done, int goal);

  /// No description provided for @dailyDone.
  ///
  /// In en, this message translates to:
  /// **'Daily boops done!'**
  String get dailyDone;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-day streak} other{{count}-day streak}}'**
  String streakDays(int count);

  /// No description provided for @comboLabel.
  ///
  /// In en, this message translates to:
  /// **'Combo ×{count}'**
  String comboLabel(int count);

  /// No description provided for @tierBoopADoop.
  ///
  /// In en, this message translates to:
  /// **'Boop-a-doop!'**
  String get tierBoopADoop;

  /// No description provided for @tierSnootStorm.
  ///
  /// In en, this message translates to:
  /// **'Snoot storm!'**
  String get tierSnootStorm;

  /// No description provided for @tierMegaBoop.
  ///
  /// In en, this message translates to:
  /// **'Mega boop!'**
  String get tierMegaBoop;

  /// No description provided for @achoo.
  ///
  /// In en, this message translates to:
  /// **'Achoo!'**
  String get achoo;

  /// First-run hint pointing at the critter's nose. 'Snoot' = playful word for nose.
  ///
  /// In en, this message translates to:
  /// **'Boop the snoot!'**
  String get onboardingHint;

  /// No description provided for @semanticsCritter.
  ///
  /// In en, this message translates to:
  /// **'{name}. Double-tap to boop the nose.'**
  String semanticsCritter(String name);

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @unlockTitle.
  ///
  /// In en, this message translates to:
  /// **'New friend!'**
  String get unlockTitle;

  /// No description provided for @unlockBody.
  ///
  /// In en, this message translates to:
  /// **'Say hi to {name}!'**
  String unlockBody(String name);

  /// No description provided for @unlockBoop.
  ///
  /// In en, this message translates to:
  /// **'Boop them!'**
  String get unlockBoop;

  /// No description provided for @unlockLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get unlockLater;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your critters'**
  String get collectionTitle;

  /// No description provided for @collectionCount.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} friends'**
  String collectionCount(int unlocked, int total);

  /// No description provided for @nextFriend.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Next friend in 1 boop} other{Next friend in {count} boops}}'**
  String nextFriend(int count);

  /// No description provided for @everyoneHere.
  ///
  /// In en, this message translates to:
  /// **'Everyone\'s here!'**
  String get everyoneHere;

  /// No description provided for @lockedRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more boop} other{{count} more boops}}'**
  String lockedRemaining(int count);

  /// No description provided for @lockedName.
  ///
  /// In en, this message translates to:
  /// **'???'**
  String get lockedName;

  /// No description provided for @lockedSnack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Boop 1 more time to meet this friend.} other{Boop {count} more times to meet this friend.}}'**
  String lockedSnack(int count);

  /// No description provided for @bestCombo.
  ///
  /// In en, this message translates to:
  /// **'Best combo ×{count}'**
  String bestCombo(int count);

  /// No description provided for @nowBooping.
  ///
  /// In en, this message translates to:
  /// **'Now booping'**
  String get nowBooping;

  /// No description provided for @rushTitle.
  ///
  /// In en, this message translates to:
  /// **'Boop Rush'**
  String get rushTitle;

  /// No description provided for @rushIntro.
  ///
  /// In en, this message translates to:
  /// **'Boop the awake critters as fast as you can!'**
  String get rushIntro;

  /// No description provided for @rushRuleSleepy.
  ///
  /// In en, this message translates to:
  /// **'Don\'t boop sleepy ones'**
  String get rushRuleSleepy;

  /// No description provided for @rushRuleGolden.
  ///
  /// In en, this message translates to:
  /// **'Golden = 5 points'**
  String get rushRuleGolden;

  /// No description provided for @rushStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get rushStart;

  /// No description provided for @rushScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get rushScore;

  /// No description provided for @rushBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get rushBest;

  /// No description provided for @rushTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get rushTime;

  /// No description provided for @rushOver.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get rushOver;

  /// No description provided for @rushNewBest.
  ///
  /// In en, this message translates to:
  /// **'New best!'**
  String get rushNewBest;

  /// No description provided for @rushPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get rushPlayAgain;

  /// No description provided for @rushResting.
  ///
  /// In en, this message translates to:
  /// **'Rush is resting. Come back soon!'**
  String get rushResting;

  /// No description provided for @rushBoopsEarned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 boop for your critters} other{+{count} boops for your critters}}'**
  String rushBoopsEarned(int count);

  /// No description provided for @rushStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak ×{count}'**
  String rushStreak(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get settingsHaptics;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionHint.
  ///
  /// In en, this message translates to:
  /// **'Fewer particles and wiggles'**
  String get settingsReduceMotionHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @settingsRate.
  ///
  /// In en, this message translates to:
  /// **'Rate Boop!'**
  String get settingsRate;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get settingsReset;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress?'**
  String get resetTitle;

  /// No description provided for @resetBody.
  ///
  /// In en, this message translates to:
  /// **'Your boops, critters, streak and best scores will be gone. This can\'t be undone.'**
  String get resetBody;

  /// No description provided for @resetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetConfirm;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Fresh start! Mochi says hi.'**
  String get resetDone;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'No ads. No tracking. Just boops.'**
  String get madeWithLove;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version of Boop! is ready.'**
  String get updateAvailable;

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @critterMochi.
  ///
  /// In en, this message translates to:
  /// **'Mochi'**
  String get critterMochi;

  /// No description provided for @critterPip.
  ///
  /// In en, this message translates to:
  /// **'Pip'**
  String get critterPip;

  /// No description provided for @critterBao.
  ///
  /// In en, this message translates to:
  /// **'Bao'**
  String get critterBao;

  /// No description provided for @critterKiwi.
  ///
  /// In en, this message translates to:
  /// **'Kiwi'**
  String get critterKiwi;

  /// No description provided for @critterMomo.
  ///
  /// In en, this message translates to:
  /// **'Momo'**
  String get critterMomo;

  /// No description provided for @critterPuff.
  ///
  /// In en, this message translates to:
  /// **'Puff'**
  String get critterPuff;

  /// No description provided for @critterNori.
  ///
  /// In en, this message translates to:
  /// **'Nori'**
  String get critterNori;

  /// No description provided for @critterTaro.
  ///
  /// In en, this message translates to:
  /// **'Taro'**
  String get critterTaro;

  /// No description provided for @critterCoco.
  ///
  /// In en, this message translates to:
  /// **'Coco'**
  String get critterCoco;

  /// No description provided for @critterJelly.
  ///
  /// In en, this message translates to:
  /// **'Jelly'**
  String get critterJelly;

  /// No description provided for @critterSprout.
  ///
  /// In en, this message translates to:
  /// **'Sprout'**
  String get critterSprout;

  /// No description provided for @critterStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get critterStar;

  /// No description provided for @kindMochi.
  ///
  /// In en, this message translates to:
  /// **'bunny'**
  String get kindMochi;

  /// No description provided for @kindPip.
  ///
  /// In en, this message translates to:
  /// **'chick'**
  String get kindPip;

  /// No description provided for @kindBao.
  ///
  /// In en, this message translates to:
  /// **'panda'**
  String get kindBao;

  /// No description provided for @kindKiwi.
  ///
  /// In en, this message translates to:
  /// **'frog'**
  String get kindKiwi;

  /// No description provided for @kindMomo.
  ///
  /// In en, this message translates to:
  /// **'baby hippo'**
  String get kindMomo;

  /// No description provided for @kindPuff.
  ///
  /// In en, this message translates to:
  /// **'cloud lamb'**
  String get kindPuff;

  /// No description provided for @kindNori.
  ///
  /// In en, this message translates to:
  /// **'seal'**
  String get kindNori;

  /// No description provided for @kindTaro.
  ///
  /// In en, this message translates to:
  /// **'hamster'**
  String get kindTaro;

  /// No description provided for @kindCoco.
  ///
  /// In en, this message translates to:
  /// **'puppy'**
  String get kindCoco;

  /// No description provided for @kindJelly.
  ///
  /// In en, this message translates to:
  /// **'jellyfish'**
  String get kindJelly;

  /// No description provided for @kindSprout.
  ///
  /// In en, this message translates to:
  /// **'leaf sprite'**
  String get kindSprout;

  /// No description provided for @kindStar.
  ///
  /// In en, this message translates to:
  /// **'baby dragon'**
  String get kindStar;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
