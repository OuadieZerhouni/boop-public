import 'package:flutter/material.dart';

/// "Candy sticker" palette — see SPEC § Look & feel.
abstract final class BoopColors {
  static const cream = Color(0xFFFFF6EC);
  static const creamDeep = Color(0xFFFCE9D6);
  static const glow = Color(0xFFFFE3EC);
  static const ink = Color(0xFF3B2A2A);
  static const inkSoft = Color(0xFF7A6363);
  static const heart = Color(0xFFFF6F8E);
  static const butter = Color(0xFFFFD36B);
  static const mint = Color(0xFF7FD8B6);
  static const sky = Color(0xFF8EC9FF);
  static const lilac = Color(0xFFC7A6FF);
  static const card = Color(0xFFFFFFFF);
  static const meadow = Color(0xFFBFE8A6);
  static const meadowDeep = Color(0xFF8FCF7A);
  static const gold = Color(0xFFFFC23D);
}

const kRadius = 24.0;
const kOutline = 3.0;
const kShadowOffset = Offset(0, 4);

bool isArabic(BuildContext context) => Localizations.localeOf(context).languageCode == 'ar';

/// Heading face: Fredoka, or Baloo Bhaijaan 2 for Arabic. Variable fonts get
/// both a weight and a matching `wght` variation so they render true weights.
TextStyle display(BuildContext context, double size, {FontWeight weight = FontWeight.w600, Color color = BoopColors.ink, double? height}) {
  final ar = isArabic(context);
  return TextStyle(
    fontFamily: ar ? 'Baloo' : 'Fredoka',
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    color: color,
    height: height ?? (ar ? 1.25 : 1.1),
  );
}

/// Body face: Nunito, or Baloo Bhaijaan 2 for Arabic.
TextStyle body(BuildContext context, double size, {FontWeight weight = FontWeight.w600, Color color = BoopColors.ink, double? height}) {
  final ar = isArabic(context);
  return TextStyle(
    fontFamily: ar ? 'Baloo' : 'Nunito',
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    color: color,
    height: height ?? (ar ? 1.35 : 1.3),
  );
}

ThemeData buildTheme(Locale locale) {
  final family = locale.languageCode == 'ar' ? 'Baloo' : 'Nunito';
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: family,
    colorScheme: ColorScheme.fromSeed(
      seedColor: BoopColors.heart,
      brightness: Brightness.light,
      surface: BoopColors.cream,
      primary: BoopColors.heart,
      onSurface: BoopColors.ink,
    ),
    scaffoldBackgroundColor: BoopColors.cream,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: BoopColors.ink, displayColor: BoopColors.ink),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : BoopColors.inkSoft),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? BoopColors.heart : BoopColors.creamDeep),
      trackOutlineColor: const WidgetStatePropertyAll(BoopColors.ink),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: BoopColors.cream),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: BoopColors.ink,
      behavior: SnackBarBehavior.floating,
      shape: StadiumBorder(),
    ),
  );
}

/// True when motion should be reduced: the in-app toggle OR the OS setting.
bool motionReduced(BuildContext context, bool userSetting) =>
    userSetting || (MediaQuery.maybeOf(context)?.disableAnimations ?? false);
