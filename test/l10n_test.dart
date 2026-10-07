import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every locale ships every string. A missing key silently falls back to
/// English at runtime, which is a translation bug no screen test notices.
void main() {
  final dir = Directory('lib/l10n');
  final base = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
  final keys = base.keys.where((k) => !k.startsWith('@')).toSet();

  final arbs = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'));

  test('there are six translations', () => expect(arbs.length, 6));

  for (final f in arbs) {
    test('${f.uri.pathSegments.last} has every key and keeps placeholders', () {
      final j = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      final have = j.keys.where((k) => !k.startsWith('@')).toSet();
      expect(keys.difference(have), isEmpty, reason: 'missing');
      expect(have.difference(keys), isEmpty, reason: 'extra');
      final ph = RegExp(r'\{(\w+)[,}]');
      for (final k in keys) {
        final want = ph.allMatches(base[k] as String).map((m) => m.group(1)).toSet();
        final got = ph.allMatches(j[k] as String).map((m) => m.group(1)).toSet();
        expect(got.containsAll(want), isTrue, reason: '$k lost a placeholder: want $want, got $got');
      }
      expect(j['appTitle'], 'Boop!', reason: 'the brand is never translated');
    });
  }
}
