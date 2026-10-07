import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app's real fonts before every test file, so layout tests measure
/// real glyph widths. The default test font draws every glyph one em wide,
/// which turns "does this fit?" into a question about a font nobody ships.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<ByteData> bytes(String path) async => ByteData.sublistView(Uint8List.fromList(File(path).readAsBytesSync()));
  for (final (family, path) in const [
    ('Fredoka', 'assets/fonts/Fredoka.ttf'),
    ('Nunito', 'assets/fonts/Nunito-Variable.ttf'),
    ('Baloo', 'assets/fonts/BalooBhaijaan2-Variable.ttf'),
  ]) {
    if (!File(path).existsSync()) continue;
    await (FontLoader(family)..addFont(bytes(path))).load();
  }
  // Icons, and (for the screen renders only) an emoji font, so rendered frames
  // show what a phone shows instead of tofu boxes.
  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = root == null ? null : File('$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
  if (icons != null && icons.existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(bytes(icons.path))).load();
  }
  const emoji = r'C:\Windows\Fonts\seguiemj.ttf';
  if (Platform.environment.containsKey('RENDER_SCREENS') && File(emoji).existsSync()) {
    await (FontLoader('Segoe UI Emoji')..addFont(bytes(emoji))).load();
  }
  await testMain();
}
