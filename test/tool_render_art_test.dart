import 'dart:io';
import 'dart:ui' as ui;

import 'package:boop/game/critters.dart';
import 'package:boop/ui/critter_painter.dart';
import 'package:boop/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dev tool (skipped by default): renders the critter gallery and the app icon
/// master from the app's own painter, so art is judged by looking.
///
///   RENDER_ART=1 flutter test test/tool_render_art_test.dart
///
/// Writes tools/art/gallery.png, tools/art/faces.png and tools/art/icon_1024.png.
/// Plain `test` (not testWidgets): Picture.toImage hangs in fake-async.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final run = Platform.environment.containsKey('RENDER_ART');

  Future<void> save(ui.Picture pic, int w, int h, String path) async {
    final img = await pic.toImage(w, h);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  }

  test('render gallery', () async {
    const cell = 300.0;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawRect(const Rect.fromLTWH(0, 0, cell * 4, cell * 3), Paint()..color = BoopColors.cream);
    for (var i = 0; i < kCritters.length; i++) {
      canvas.save();
      canvas.translate((i % 4) * cell, (i ~/ 4) * cell);
      CritterPainter(species: kCritters[i]).paint(canvas, const Size(cell, cell));
      canvas.restore();
    }
    await save(rec.endRecording(), (cell * 4).toInt(), (cell * 3).toInt(), 'tools/art/gallery.png');
  }, skip: !run);

  test('render faces', () async {
    const cell = 260.0;
    final faces = CritterFace.values;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawRect(Rect.fromLTWH(0, 0, cell * faces.length, cell * 2), Paint()..color = BoopColors.cream);
    for (var i = 0; i < faces.length; i++) {
      for (final (row, c) in [(0, kCritters[2]), (1, kCritters[9])]) {
        canvas.save();
        canvas.translate(i * cell, row * cell);
        CritterPainter(species: c, pose: CritterPose(face: faces[i], blush: 0.6)).paint(canvas, const Size(cell, cell));
        canvas.restore();
      }
    }
    // A squashed boop, a golden one and a silhouette in the corner cells.
    await save(rec.endRecording(), (cell * faces.length).toInt(), (cell * 2).toInt(), 'tools/art/faces.png');
  }, skip: !run);

  test('render icon master', () async {
    const s = 1024.0;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, s, s),
      Paint()
        ..shader = ui.Gradient.radial(const Offset(512, 470), 720, [const Color(0xFFFFE9F0), const Color(0xFFFFC9D8), const Color(0xFFFF9DB8)], [0, 0.6, 1]),
    );
    // Soft sparkles.
    final sp = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final (o, r) in [(const Offset(190, 210), 34.0), (const Offset(850, 300), 26.0), (const Offset(820, 820), 20.0)]) {
      final p = Path()
        ..moveTo(o.dx, o.dy - r)
        ..quadraticBezierTo(o.dx, o.dy, o.dx + r, o.dy)
        ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r)
        ..quadraticBezierTo(o.dx, o.dy, o.dx - r, o.dy)
        ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r)
        ..close();
      canvas.drawPath(p, sp);
    }
    canvas.save();
    canvas.translate(52, 40);
    CritterPainter(
      species: kCritters.first,
      shadow: false,
      pose: const CritterPose(face: CritterFace.happy, blush: 1, squashX: 1.04, squashY: 0.97),
    ).paint(canvas, const Size(920, 920));
    canvas.restore();
    await save(rec.endRecording(), 1024, 1024, 'tools/art/icon_1024.png');
  }, skip: !run);
}
