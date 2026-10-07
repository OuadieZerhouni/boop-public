import '../game/critters.dart';
import '../l10n/app_localizations.dart';

/// Localized display name of a critter.
String critterName(AppLocalizations l, CritterSpecies c) => switch (c.id) {
  'mochi' => l.critterMochi,
  'pip' => l.critterPip,
  'bao' => l.critterBao,
  'kiwi' => l.critterKiwi,
  'momo' => l.critterMomo,
  'puff' => l.critterPuff,
  'nori' => l.critterNori,
  'taro' => l.critterTaro,
  'coco' => l.critterCoco,
  'jelly' => l.critterJelly,
  'sprout' => l.critterSprout,
  'star' => l.critterStar,
  _ => c.id,
};

/// Localized "what is it" line (bunny, chick, …).
String critterKind(AppLocalizations l, CritterSpecies c) => switch (c.id) {
  'mochi' => l.kindMochi,
  'pip' => l.kindPip,
  'bao' => l.kindBao,
  'kiwi' => l.kindKiwi,
  'momo' => l.kindMomo,
  'puff' => l.kindPuff,
  'nori' => l.kindNori,
  'taro' => l.kindTaro,
  'coco' => l.kindCoco,
  'jelly' => l.kindJelly,
  'sprout' => l.kindSprout,
  'star' => l.kindStar,
  _ => '',
};

/// Each language's name in itself, for the language picker.
const kLanguageNames = {
  'en': 'English',
  'ar': 'العربية',
  'de': 'Deutsch',
  'es': 'Español',
  'fr': 'Français',
  'ja': '日本語',
  'pt': 'Português',
};
