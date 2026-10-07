import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/critters.dart';
import 'theme.dart';

enum CritterFace { open, happy, hug, sleepy, asleep, surprised }

/// Everything that animates. All fields default to "at rest".
@immutable
class CritterPose {
  const CritterPose({
    this.squashX = 1,
    this.squashY = 1,
    this.tilt = 0,
    this.shear = Offset.zero,
    this.face = CritterFace.open,
    this.look = Offset.zero,
    this.blink = 0,
    this.blush = 0,
    this.noseFlash = 0,
  });

  /// Scale about the critter's base (feet stay on the ground).
  final double squashX;
  final double squashY;

  /// Rotation about the base, radians.
  final double tilt;

  /// Drag deformation, as a fraction of the body size (−1…1 each axis).
  final Offset shear;

  final CritterFace face;

  /// Where the eyes look, −1…1 per axis.
  final Offset look;

  /// 0 = eyes open, 1 = closed (only applies to the open face).
  final double blink;
  final double blush;
  final double noseFlash;
}

/// Layout of a critter inside a square box of side [s]. Shared by the painter
/// and the hit-testing widget so they can never disagree about where the nose is.
@immutable
class CritterGeometry {
  CritterGeometry(this.s, CritterSpecies c)
    : cx = s / 2,
      baseY = s * (c.ears == EarStyle.jelly ? 0.84 : 0.92),
      a = s * 0.33 * math.sqrt(c.aspect),
      b = s * 0.29 / math.sqrt(c.aspect) {
    cy = baseY - b;
  }

  final double s;
  final double cx;
  final double baseY;

  /// Body half-width and half-height.
  final double a;
  final double b;
  late final double cy;

  Offset get center => Offset(cx, cy);
  Offset get nose => Offset(cx, cy + b * 0.14);

  /// Generous: a small nose must still be easy to hit with a thumb.
  double get noseHitRadius => math.max(a * 0.24, 26);
  double get eyeY => cy - b * 0.06;
  double get eyeDx => a * 0.37;
  double get eyeR => a * 0.105;

  bool hitsNose(Offset p) => (p - nose).distance <= noseHitRadius;

  /// Inside the body ellipse (a little forgiving).
  bool hitsBody(Offset p) {
    final dx = (p.dx - cx) / (a * 1.08);
    final dy = (p.dy - cy) / (b * 1.12);
    return dx * dx + dy * dy <= 1;
  }
}

class CritterPainter extends CustomPainter {
  CritterPainter({
    required this.species,
    this.pose = const CritterPose(),
    this.silhouette = false,
    this.golden = false,
    this.shadow = true,
  });

  final CritterSpecies species;
  final CritterPose pose;
  final bool silhouette;
  final bool golden;
  final bool shadow;

  static const _ink = BoopColors.ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    final g = CritterGeometry(s, species);
    final c = species;
    final stroke = s * 0.022;

    Color tint(Color col) {
      if (silhouette) return const Color(0xFFDCCFC3);
      if (golden) return Color.lerp(col, BoopColors.gold, 0.55)!;
      return col;
    }

    final outline = Paint()
      ..color = silhouette ? const Color(0xFFC8B8AA) : _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Ground shadow (not deformed by tilt, only by squash).
    if (shadow) {
      final sw = g.a * 1.7 * pose.squashX;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(g.cx + pose.shear.dx * g.a * 0.3, g.baseY + s * 0.012), width: sw, height: s * 0.05),
        Paint()..color = _ink.withValues(alpha: silhouette ? 0.06 : 0.12),
      );
    }

    // Deformation about the base point.
    canvas.translate(g.cx, g.baseY);
    canvas.rotate(pose.tilt);
    canvas.scale(pose.squashX, pose.squashY);
    if (pose.shear != Offset.zero) {
      final m = Matrix4.identity()
        ..setEntry(0, 1, -pose.shear.dx * 0.45)
        ..setEntry(1, 1, 1 + pose.shear.dy * 0.25);
      canvas.transform(m.storage);
    }
    canvas.translate(-g.cx, -g.baseY);

    final bodyPath = _bodyPath(g);

    // 1. Things behind the body.
    _earsBehind(canvas, g, outline, tint);
    if (c.ears == EarStyle.jelly) _tentacles(canvas, g, outline, tint);

    // 2. Body.
    final bodyRect = Rect.fromCenter(center: g.center, width: g.a * 2, height: g.b * 2);
    final bodyFill = Paint()
      ..shader = ui.Gradient.linear(
        bodyRect.topCenter,
        bodyRect.bottomCenter,
        [Color.lerp(tint(c.body), Colors.white, 0.28)!, tint(c.body), Color.lerp(tint(c.body), _ink, 0.06)!],
        [0, 0.55, 1],
      );
    if (c.glossy && !silhouette) bodyFill.color = bodyFill.color.withValues(alpha: 0.92);
    canvas.drawPath(bodyPath, bodyFill);

    if (!silhouette) {
      // Belly patch, clipped to the body.
      canvas.save();
      canvas.clipPath(bodyPath);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(g.cx, g.cy + g.b * 0.62), width: g.a * 1.25, height: g.b * 1.0),
        Paint()..color = tint(c.belly).withValues(alpha: 0.9),
      );
      // Soft top-left highlight.
      canvas.drawOval(
        Rect.fromCenter(center: Offset(g.cx - g.a * 0.42, g.cy - g.b * 0.52), width: g.a * 0.5, height: g.b * 0.26),
        Paint()..color = Colors.white.withValues(alpha: c.glossy ? 0.55 : 0.35),
      );
      canvas.restore();
    }
    canvas.drawPath(bodyPath, outline);

    // 3. Things on top of the body.
    _earsFront(canvas, g, outline, tint);
    _limbs(canvas, g, outline, tint);

    if (!silhouette) {
      if (c.patches) _patches(canvas, g);
      _cheeks(canvas, g);
      if (c.freckles) _freckles(canvas, g);
      _eyes(canvas, g, outline);
      _mouth(canvas, g, outline);
      _nose(canvas, g, outline);
      if (c.whiskers) _whiskers(canvas, g);
      if (golden) _sparkles(canvas, g);
    } else {
      // A locked critter keeps a hint of its silhouette and a question mark.
      final tp = TextPainter(
        text: TextSpan(
          text: '?',
          style: TextStyle(fontFamily: 'Fredoka', fontSize: g.b * 0.9, fontWeight: FontWeight.w700, color: const Color(0xFFB8A698)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, g.center - Offset(tp.width / 2, tp.height / 2));
    }
    canvas.restore();
  }

  // ---------------------------------------------------------------- body

  Path _bodyPath(CritterGeometry g) {
    // A squircle-ish "mochi": superellipse, bottom slightly flattened.
    const n = 2.5;
    const steps = 96;
    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final t = i / steps * 2 * math.pi;
      final ct = math.cos(t), st = math.sin(t);
      var x = g.a * ct.sign * math.pow(ct.abs(), 2 / n);
      var y = g.b * st.sign * math.pow(st.abs(), 2 / n);
      if (y > 0) y *= 0.97;
      // a slightly fuller bottom: widen as y goes down
      x *= 1 + 0.06 * (y / g.b);
      final p = Offset(g.cx + x, g.cy + y);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  void _fillStroke(Canvas canvas, Path p, Color fill, Paint outline) {
    canvas.drawPath(p, Paint()..color = fill);
    canvas.drawPath(p, outline);
  }

  // ---------------------------------------------------------------- ears

  void _earsBehind(Canvas canvas, CritterGeometry g, Paint outline, Color Function(Color) tint) {
    final c = species;
    switch (c.ears) {
      case EarStyle.bunny:
        for (final side in [-1.0, 1.0]) {
          canvas.save();
          final base = Offset(g.cx + side * g.a * 0.36, g.cy - g.b * 0.72);
          canvas.translate(base.dx, base.dy);
          canvas.rotate(side * 0.2);
          final ear = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -g.b * 0.55), width: g.a * 0.36, height: g.b * 1.25), Radius.circular(g.a * 0.18));
          _fillStroke(canvas, Path()..addRRect(ear), tint(c.body), outline);
          if (!silhouette) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -g.b * 0.6), width: g.a * 0.16, height: g.b * 0.85), Radius.circular(g.a * 0.08)),
              Paint()..color = tint(c.accent),
            );
          }
          canvas.restore();
        }
      case EarStyle.round:
        for (final side in [-1.0, 1.0]) {
          final ctr = Offset(g.cx + side * g.a * 0.66, g.cy - g.b * 0.78);
          final r = g.a * 0.27;
          _fillStroke(canvas, Path()..addOval(Rect.fromCircle(center: ctr, radius: r)), tint(c.patches ? c.accent : c.body), outline);
          if (!silhouette && !c.patches) {
            canvas.drawCircle(ctr + Offset(0, r * 0.12), r * 0.55, Paint()..color = tint(c.accent));
          }
        }
      case EarStyle.pig:
        for (final side in [-1.0, 1.0]) {
          final tip = Offset(g.cx + side * g.a * 0.78, g.cy - g.b * 1.08);
          final p = Path()
            ..moveTo(g.cx + side * g.a * 0.34, g.cy - g.b * 0.86)
            ..quadraticBezierTo(g.cx + side * g.a * 0.62, g.cy - g.b * 1.2, tip.dx, tip.dy)
            ..quadraticBezierTo(g.cx + side * g.a * 0.98, g.cy - g.b * 0.7, g.cx + side * g.a * 0.72, g.cy - g.b * 0.58)
            ..close();
          _fillStroke(canvas, p, tint(c.body), outline);
          if (!silhouette) {
            final inner = Path()
              ..moveTo(g.cx + side * g.a * 0.48, g.cy - g.b * 0.86)
              ..quadraticBezierTo(g.cx + side * g.a * 0.66, g.cy - g.b * 1.05, tip.dx - side * g.a * 0.05, tip.dy + g.b * 0.1)
              ..quadraticBezierTo(g.cx + side * g.a * 0.84, g.cy - g.b * 0.78, g.cx + side * g.a * 0.68, g.cy - g.b * 0.7)
              ..close();
            canvas.drawPath(inner, Paint()..color = tint(c.accent));
          }
        }
      case EarStyle.floppy:
        for (final side in [-1.0, 1.0]) {
          final p = Path()
            ..moveTo(g.cx + side * g.a * 0.45, g.cy - g.b * 0.86)
            ..cubicTo(
              g.cx + side * g.a * 1.15, g.cy - g.b * 1.0,
              g.cx + side * g.a * 1.22, g.cy + g.b * 0.05,
              g.cx + side * g.a * 0.98, g.cy + g.b * 0.12,
            )
            ..cubicTo(
              g.cx + side * g.a * 0.78, g.cy + g.b * 0.18,
              g.cx + side * g.a * 0.7, g.cy - g.b * 0.4,
              g.cx + side * g.a * 0.62, g.cy - g.b * 0.62,
            )
            ..close();
          _fillStroke(canvas, p, tint(c.accent), outline);
        }
      case EarStyle.horns:
        // Little wings peek out behind the body.
        for (final side in [-1.0, 1.0]) {
          final root = Offset(g.cx + side * g.a * 0.86, g.cy - g.b * 0.05);
          final p = Path()
            ..moveTo(root.dx, root.dy - g.b * 0.18)
            ..quadraticBezierTo(root.dx + side * g.a * 0.55, root.dy - g.b * 0.55, root.dx + side * g.a * 0.5, root.dy - g.b * 0.05)
            ..quadraticBezierTo(root.dx + side * g.a * 0.42, root.dy + g.b * 0.05, root.dx + side * g.a * 0.3, root.dy + g.b * 0.02)
            ..quadraticBezierTo(root.dx + side * g.a * 0.22, root.dy + g.b * 0.12, root.dx, root.dy + g.b * 0.12)
            ..close();
          _fillStroke(canvas, p, tint(Color.lerp(c.body, Colors.white, 0.35)!), outline);
        }
      case EarStyle.tuft:
      case EarStyle.bumps:
      case EarStyle.cloud:
      case EarStyle.none:
      case EarStyle.jelly:
      case EarStyle.leaf:
        break;
    }
  }

  void _earsFront(Canvas canvas, CritterGeometry g, Paint outline, Color Function(Color) tint) {
    final c = species;
    switch (c.ears) {
      case EarStyle.tuft:
        for (final (dx, h, rot) in [(-0.14, 0.32, -0.45), (0.0, 0.42, 0.0), (0.14, 0.32, 0.45)]) {
          canvas.save();
          canvas.translate(g.cx + dx * g.a, g.cy - g.b * 0.94);
          canvas.rotate(rot);
          final p = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(-g.a * 0.11, -g.b * h * 0.6, 0, -g.b * h)
            ..quadraticBezierTo(g.a * 0.11, -g.b * h * 0.6, 0, 0)
            ..close();
          _fillStroke(canvas, p, tint(c.accent), outline);
          canvas.restore();
        }
      case EarStyle.bumps:
        // Frog eye-domes: the eyes sit inside them (see _eyeCenters).
        for (final side in [-1.0, 1.0]) {
          final ctr = Offset(g.cx + side * g.a * 0.44, g.cy - g.b * 0.74);
          final r = g.a * 0.3;
          final dome = Path()..addOval(Rect.fromCircle(center: ctr, radius: r));
          canvas.drawPath(dome, Paint()..color = tint(c.body));
          canvas.drawArc(Rect.fromCircle(center: ctr, radius: r), math.pi * 0.98, math.pi * 1.04, false, outline);
        }
      case EarStyle.cloud:
        final puffs = <(Offset, double)>[
          for (var i = 0; i < 7; i++)
            (
              Offset(g.cx + math.cos(math.pi + i / 6 * math.pi) * g.a * 0.78, g.cy - g.b * 0.52 + math.sin(math.pi + i / 6 * math.pi) * g.b * 0.5),
              g.a * (i == 3 ? 0.3 : 0.25),
            ),
        ];
        for (final (p, r) in puffs) {
          canvas.drawCircle(p, r, outline);
        }
        for (final (p, r) in puffs) {
          canvas.drawCircle(p, r - outline.strokeWidth / 2, Paint()..color = tint(c.belly));
        }
        // Little horn-curls for a lamb.
        for (final side in [-1.0, 1.0]) {
          final ctr = Offset(g.cx + side * g.a * 0.92, g.cy - g.b * 0.18);
          _fillStroke(canvas, Path()..addOval(Rect.fromCenter(center: ctr, width: g.a * 0.3, height: g.b * 0.24)), tint(c.accent), outline);
        }
      case EarStyle.leaf:
        canvas.drawLine(Offset(g.cx, g.cy - g.b * 0.96), Offset(g.cx + g.a * 0.04, g.cy - g.b * 1.22), outline);
        for (final side in [-1.0, 1.0]) {
          canvas.save();
          canvas.translate(g.cx + g.a * 0.04, g.cy - g.b * 1.2);
          canvas.rotate(side * 0.9 - 0.15);
          final leaf = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(g.a * 0.18, -g.b * 0.18, 0, -g.b * 0.42)
            ..quadraticBezierTo(-g.a * 0.18, -g.b * 0.18, 0, 0)
            ..close();
          _fillStroke(canvas, leaf, tint(c.accent), outline);
          canvas.restore();
        }
      case EarStyle.horns:
        for (final side in [-1.0, 1.0]) {
          // A small curved cone leaning outward; every x mirrored by `side`.
          final bx = g.cx + side * g.a * 0.46;
          final by = g.cy - g.b * 0.86;
          final p = Path()
            ..moveTo(bx - side * g.a * 0.11, by + g.b * 0.05)
            ..quadraticBezierTo(bx - side * g.a * 0.02, by - g.b * 0.26, bx + side * g.a * 0.16, by - g.b * 0.36)
            ..quadraticBezierTo(bx + side * g.a * 0.1, by - g.b * 0.12, bx + side * g.a * 0.12, by + g.b * 0.06)
            ..close();
          _fillStroke(canvas, p, tint(c.accent), outline);
        }
        // A spiky crest down the middle.
        for (var i = 0; i < 3; i++) {
          final x = g.cx + (i - 1) * g.a * 0.14;
          final p = Path()
            ..moveTo(x - g.a * 0.07, g.cy - g.b * 0.93)
            ..lineTo(x, g.cy - g.b * (1.12 + (i == 1 ? 0.06 : 0)))
            ..lineTo(x + g.a * 0.07, g.cy - g.b * 0.93)
            ..close();
          _fillStroke(canvas, p, tint(Color.lerp(c.body, Colors.white, 0.3)!), outline);
        }
      case EarStyle.jelly:
        // A little glossy dome highlight band.
        if (!silhouette) {
          canvas.drawArc(
            Rect.fromCenter(center: g.center, width: g.a * 1.55, height: g.b * 1.55),
            math.pi * 1.15, math.pi * 0.7, false,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.6)
              ..style = PaintingStyle.stroke
              ..strokeWidth = g.s * 0.018
              ..strokeCap = StrokeCap.round,
          );
        }
      case EarStyle.bunny:
      case EarStyle.round:
      case EarStyle.pig:
      case EarStyle.none:
      case EarStyle.floppy:
        break;
    }
  }

  void _tentacles(Canvas canvas, CritterGeometry g, Paint outline, Color Function(Color) tint) {
    for (var i = 0; i < 4; i++) {
      final x = g.cx + (i - 1.5) * g.a * 0.42;
      final p = Path()
        ..moveTo(x - g.a * 0.1, g.cy + g.b * 0.6)
        ..quadraticBezierTo(x - g.a * 0.2, g.cy + g.b * 1.05, x, g.cy + g.b * 1.32)
        ..quadraticBezierTo(x + g.a * 0.2, g.cy + g.b * 1.05, x + g.a * 0.1, g.cy + g.b * 0.6)
        ..close();
      _fillStroke(canvas, p, tint(species.accent), outline);
    }
  }

  void _limbs(Canvas canvas, CritterGeometry g, Paint outline, Color Function(Color) tint) {
    final c = species;
    if (c.ears == EarStyle.jelly) return;
    // Two little paws resting on the sides of the body, and two feet.
    final armColor = tint(Color.lerp(c.body, _ink, 0.05)!);
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(g.cx + side * g.a * 0.9, g.cy + g.b * 0.3);
      canvas.rotate(side * -0.5);
      final paw = Path()..addOval(Rect.fromCenter(center: Offset.zero, width: g.a * 0.26, height: g.b * 0.34));
      canvas.drawPath(paw, Paint()..color = armColor);
      canvas.drawPath(paw, outline);
      canvas.restore();
    }
    if (c.ears == EarStyle.none) {
      // Seal: flippers instead of feet.
      for (final side in [-1.0, 1.0]) {
        canvas.save();
        canvas.translate(g.cx + side * g.a * 0.62, g.baseY - g.b * 0.06);
        canvas.rotate(side * 0.5);
        _fillStroke(canvas, Path()..addOval(Rect.fromCenter(center: Offset.zero, width: g.a * 0.42, height: g.b * 0.17)), tint(c.accent), outline);
        canvas.restore();
      }
      return;
    }
    for (final side in [-1.0, 1.0]) {
      final foot = Rect.fromCenter(center: Offset(g.cx + side * g.a * 0.38, g.baseY - g.b * 0.03), width: g.a * 0.42, height: g.b * 0.2);
      _fillStroke(canvas, Path()..addOval(foot), tint(Color.lerp(c.body, _ink, 0.05)!), outline);
    }
  }

  // ---------------------------------------------------------------- face

  List<Offset> _eyeCenters(CritterGeometry g) {
    if (species.ears == EarStyle.bumps) {
      return [Offset(g.cx - g.a * 0.44, g.cy - g.b * 0.74), Offset(g.cx + g.a * 0.44, g.cy - g.b * 0.74)];
    }
    return [Offset(g.cx - g.eyeDx, g.eyeY), Offset(g.cx + g.eyeDx, g.eyeY)];
  }

  void _patches(Canvas canvas, CritterGeometry g) {
    final p = Paint()..color = species.accent;
    for (final e in _eyeCenters(g)) {
      canvas.save();
      canvas.translate(e.dx, e.dy + g.b * 0.02);
      canvas.rotate(e.dx < g.cx ? 0.5 : -0.5);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: g.a * 0.44, height: g.b * 0.5), p);
      canvas.restore();
    }
  }

  void _cheeks(Canvas canvas, CritterGeometry g) {
    final alpha = (0.5 + pose.blush * 0.45).clamp(0.0, 1.0);
    final p = Paint()
      ..shader = null
      ..color = species.cheek.withValues(alpha: alpha);
    for (final side in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(g.cx + side * g.a * 0.6, g.cy + g.b * 0.14), width: g.a * 0.3 * (1 + pose.blush * 0.15), height: g.b * 0.17),
        p,
      );
    }
  }

  void _eyes(Canvas canvas, CritterGeometry g, Paint outline) {
    final r = g.eyeR;
    final onDark = species.patches;
    final eyeColor = onDark ? Colors.white : _ink;
    final stroke = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = g.s * 0.024
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final centers = _eyeCenters(g);
    for (var i = 0; i < 2; i++) {
      final e = centers[i];
      final left = i == 0;
      switch (pose.face) {
        case CritterFace.open:
          final look = Offset(pose.look.dx.clamp(-1, 1) * r * 0.35, pose.look.dy.clamp(-1, 1) * r * 0.3);
          final open = (1 - pose.blink).clamp(0.08, 1.0);
          canvas.save();
          canvas.translate(e.dx + look.dx, e.dy + look.dy);
          canvas.scale(1, open);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2.3), Paint()..color = onDark ? Colors.white : _ink);
          if (!onDark) {
            canvas.drawCircle(Offset(r * 0.35, -r * 0.45), r * 0.42, Paint()..color = Colors.white);
            canvas.drawCircle(Offset(-r * 0.38, r * 0.45), r * 0.18, Paint()..color = Colors.white.withValues(alpha: 0.9));
          } else {
            canvas.drawCircle(Offset(r * 0.1, r * 0.1), r * 0.62, Paint()..color = _ink);
            canvas.drawCircle(Offset(r * 0.32, -r * 0.2), r * 0.24, Paint()..color = Colors.white);
          }
          canvas.restore();
        case CritterFace.happy:
          // > <
          final dir = left ? 1.0 : -1.0;
          final p = Path()
            ..moveTo(e.dx - dir * r * 0.9, e.dy - r * 0.9)
            ..lineTo(e.dx + dir * r * 0.9, e.dy)
            ..lineTo(e.dx - dir * r * 0.9, e.dy + r * 0.9);
          canvas.drawPath(p, stroke);
        case CritterFace.hug:
          // ^ ^
          canvas.drawArc(Rect.fromCenter(center: e + Offset(0, r * 0.5), width: r * 2.2, height: r * 2.0), math.pi * 1.1, math.pi * 0.8, false, stroke);
        case CritterFace.sleepy:
          canvas.drawLine(e + Offset(-r * 1.05, 0), e + Offset(r * 1.05, 0), stroke);
          canvas.drawArc(Rect.fromCenter(center: e, width: r * 2, height: r * 2), 0, math.pi, true, Paint()..color = eyeColor);
        case CritterFace.asleep:
          canvas.drawArc(Rect.fromCenter(center: e - Offset(0, r * 0.4), width: r * 2.1, height: r * 1.8), math.pi * 0.15, math.pi * 0.7, false, stroke);
        case CritterFace.surprised:
          canvas.drawCircle(e, r * 1.15, Paint()..color = Colors.white);
          canvas.drawCircle(e, r * 1.15, stroke);
          canvas.drawCircle(e, r * 0.45, Paint()..color = eyeColor == Colors.white ? _ink : _ink);
      }
    }
  }

  void _mouth(Canvas canvas, CritterGeometry g, Paint outline) {
    final m = Offset(g.cx, g.nose.dy + g.b * (species.noseStyle == NoseStyle.snout ? 0.26 : 0.2));
    final w = g.a * 0.16;
    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = g.s * 0.018
      ..strokeCap = StrokeCap.round;
    switch (pose.face) {
      case CritterFace.happy:
        final p = Path()
          ..moveTo(m.dx - w * 1.1, m.dy - w * 0.25)
          ..quadraticBezierTo(m.dx, m.dy + w * 1.6, m.dx + w * 1.1, m.dy - w * 0.25)
          ..close();
        canvas.drawPath(p, Paint()..color = const Color(0xFF8C3B4A));
        canvas.save();
        canvas.clipPath(p);
        canvas.drawCircle(Offset(m.dx, m.dy + w * 0.95), w * 0.7, Paint()..color = BoopColors.heart);
        canvas.restore();
        canvas.drawPath(p, stroke);
      case CritterFace.sleepy:
      case CritterFace.asleep:
      case CritterFace.surprised:
        canvas.drawOval(Rect.fromCenter(center: m + Offset(0, w * 0.2), width: w * 0.8, height: w * (pose.face == CritterFace.surprised ? 1.0 : 0.6)), Paint()..color = const Color(0xFF8C3B4A));
      case CritterFace.open:
      case CritterFace.hug:
        if (species.noseStyle == NoseStyle.beak) return; // the beak is the mouth
        canvas.drawArc(Rect.fromCenter(center: m - Offset(w * 0.5, 0), width: w, height: w * 0.9), 0.1, math.pi * 0.85, false, stroke);
        canvas.drawArc(Rect.fromCenter(center: m + Offset(w * 0.5, 0), width: w, height: w * 0.9), 0.1, math.pi * 0.85, false, stroke);
    }
  }

  void _nose(Canvas canvas, CritterGeometry g, Paint outline) {
    final n = g.nose;
    final col = Color.lerp(golden ? Color.lerp(species.nose, BoopColors.gold, 0.4)! : species.nose, const Color(0xFFFF3D6E), pose.noseFlash * 0.6)!;
    final fill = Paint()..color = col;
    final thin = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = g.s * 0.014
      ..strokeJoin = StrokeJoin.round;
    final u = g.a * 0.1;
    Path p;
    switch (species.noseStyle) {
      case NoseStyle.button:
        p = Path()..addOval(Rect.fromCenter(center: n, width: u * 1.9, height: u * 1.35));
      case NoseStyle.heart:
        p = Path()
          ..moveTo(n.dx, n.dy + u * 0.8)
          ..cubicTo(n.dx - u * 1.5, n.dy - u * 0.1, n.dx - u * 0.75, n.dy - u * 1.15, n.dx, n.dy - u * 0.35)
          ..cubicTo(n.dx + u * 0.75, n.dy - u * 1.15, n.dx + u * 1.5, n.dy - u * 0.1, n.dx, n.dy + u * 0.8)
          ..close();
      case NoseStyle.beak:
        p = Path()
          ..moveTo(n.dx - u * 1.2, n.dy - u * 0.35)
          ..quadraticBezierTo(n.dx, n.dy - u * 0.95, n.dx + u * 1.2, n.dy - u * 0.35)
          ..quadraticBezierTo(n.dx + u * 0.2, n.dy + u * 1.2, n.dx, n.dy + u * 1.25)
          ..quadraticBezierTo(n.dx - u * 0.2, n.dy + u * 1.2, n.dx - u * 1.2, n.dy - u * 0.35)
          ..close();
      case NoseStyle.snout:
        p = Path()..addOval(Rect.fromCenter(center: n, width: u * 3.4, height: u * 2.3));
      case NoseStyle.triangle:
        p = Path()
          ..moveTo(n.dx - u * 1.0, n.dy - u * 0.55)
          ..quadraticBezierTo(n.dx, n.dy - u * 0.85, n.dx + u * 1.0, n.dy - u * 0.55)
          ..quadraticBezierTo(n.dx + u * 0.3, n.dy + u * 0.75, n.dx, n.dy + u * 0.75)
          ..quadraticBezierTo(n.dx - u * 0.3, n.dy + u * 0.75, n.dx - u * 1.0, n.dy - u * 0.55)
          ..close();
      case NoseStyle.star:
        p = Path();
        for (var i = 0; i < 10; i++) {
          final ang = -math.pi / 2 + i * math.pi / 5;
          final rr = i.isEven ? u * 1.25 : u * 0.6;
          final pt = n + Offset(math.cos(ang) * rr, math.sin(ang) * rr);
          i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
        }
        p.close();
    }
    canvas.drawPath(p, fill);
    canvas.drawPath(p, thin);
    if (species.noseStyle == NoseStyle.snout) {
      for (final side in [-1.0, 1.0]) {
        canvas.drawOval(Rect.fromCenter(center: n + Offset(side * u * 0.65, 0), width: u * 0.5, height: u * 0.75), Paint()..color = const Color(0xFFB0505E));
      }
    } else {
      // Shine: makes the nose read as the thing to touch.
      canvas.drawOval(Rect.fromCenter(center: n + Offset(-u * 0.35, -u * 0.3), width: u * 0.55, height: u * 0.35), Paint()..color = Colors.white.withValues(alpha: 0.75));
    }
  }

  void _whiskers(Canvas canvas, CritterGeometry g) {
    final p = Paint()
      ..color = _ink.withValues(alpha: 0.55)
      ..strokeWidth = g.s * 0.009
      ..strokeCap = StrokeCap.round;
    for (final side in [-1.0, 1.0]) {
      for (var k = -1; k <= 1; k++) {
        final from = g.nose + Offset(side * g.a * 0.3, g.b * (0.05 * k));
        final to = g.nose + Offset(side * g.a * 0.62, g.b * (0.1 * k - 0.02));
        canvas.drawLine(from, to, p);
      }
    }
  }

  void _freckles(Canvas canvas, CritterGeometry g) {
    final p = Paint()..color = Color.lerp(species.accent, _ink, 0.25)!.withValues(alpha: 0.55);
    for (final side in [-1.0, 1.0]) {
      for (final o in const [Offset(0, 0), Offset(0.09, -0.07), Offset(0.12, 0.07)]) {
        canvas.drawCircle(Offset(g.cx + side * (g.a * 0.62 + o.dx * g.a), g.cy + g.b * 0.02 + o.dy * g.b), g.s * 0.008, p);
      }
    }
  }

  void _sparkles(Canvas canvas, CritterGeometry g) {
    final p = Paint()..color = Colors.white;
    for (final (o, r) in [(const Offset(-0.75, -0.75), 0.11), (const Offset(0.82, -0.4), 0.08), (const Offset(0.6, 0.55), 0.06)]) {
      final c = Offset(g.cx + o.dx * g.a, g.cy + o.dy * g.b);
      final rr = g.a * r;
      final star = Path()
        ..moveTo(c.dx, c.dy - rr)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + rr, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + rr)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - rr, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - rr)
        ..close();
      canvas.drawPath(star, p);
    }
  }

  @override
  bool shouldRepaint(CritterPainter old) =>
      old.species != species || old.pose != pose || old.silhouette != silhouette || old.golden != golden || old.shadow != shadow;
}
