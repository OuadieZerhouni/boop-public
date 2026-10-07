import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'theme.dart';

enum _Kind { heart, sparkle, confetti, text }

class _Particle {
  _Particle({
    required this.kind,
    required this.pos,
    required this.vel,
    required this.life,
    required this.size,
    required this.color,
    this.spin = 0,
    this.text,
    this.gravity = 0,
  });

  final _Kind kind;
  Offset pos;
  Offset vel;
  final double life; // seconds
  final double size;
  final Color color;
  final double spin;
  final String? text;
  final double gravity;
  double age = 0;
  double angle = 0;

  double get t => (age / life).clamp(0.0, 1.0);
  bool get dead => age >= life;
}

/// Fire-and-forget effects (hearts, sparkles, confetti, floating text).
/// Positions are in the [ParticleLayer]'s local coordinates.
class ParticleController {
  final _rng = math.Random();
  final List<_Particle> _items = [];
  VoidCallback? _wake;

  /// When true every emit is a no-op (Reduce motion).
  bool muted = false;

  bool get isEmpty => _items.isEmpty;

  /// Live hearts, sparkles and confetti (floating text excluded).
  @visibleForTesting
  int get decorativeCount => _items.where((p) => p.kind != _Kind.text).length;

  void hearts(Offset at, {int count = 3, double scale = 1}) {
    if (muted) return;
    for (var i = 0; i < count; i++) {
      final a = -math.pi / 2 + (_rng.nextDouble() - 0.5) * 1.6;
      final speed = 90 + _rng.nextDouble() * 90;
      _items.add(_Particle(
        kind: _Kind.heart,
        pos: at,
        vel: Offset(math.cos(a), math.sin(a)) * speed,
        life: 0.9 + _rng.nextDouble() * 0.4,
        size: (14 + _rng.nextDouble() * 10) * scale,
        color: [BoopColors.heart, const Color(0xFFFF9FB6), const Color(0xFFFF7FB0)][_rng.nextInt(3)],
        gravity: -40,
      ));
    }
    _wake?.call();
  }

  void sparkles(Offset at, {int count = 6, Color color = BoopColors.butter}) {
    if (muted) return;
    for (var i = 0; i < count; i++) {
      final a = _rng.nextDouble() * math.pi * 2;
      final speed = 60 + _rng.nextDouble() * 140;
      _items.add(_Particle(
        kind: _Kind.sparkle,
        pos: at,
        vel: Offset(math.cos(a), math.sin(a)) * speed,
        life: 0.5 + _rng.nextDouble() * 0.3,
        size: 8 + _rng.nextDouble() * 8,
        color: color,
      ));
    }
    _wake?.call();
  }

  void confetti(Offset at, {int count = 36, double spread = 1}) {
    if (muted) return;
    const colors = [BoopColors.heart, BoopColors.butter, BoopColors.mint, BoopColors.sky, BoopColors.lilac];
    for (var i = 0; i < count; i++) {
      final a = -math.pi / 2 + (_rng.nextDouble() - 0.5) * 2.4 * spread;
      final speed = 220 + _rng.nextDouble() * 260;
      _items.add(_Particle(
        kind: _Kind.confetti,
        pos: at,
        vel: Offset(math.cos(a), math.sin(a)) * speed,
        life: 1.4 + _rng.nextDouble() * 0.6,
        size: 7 + _rng.nextDouble() * 6,
        color: colors[_rng.nextInt(colors.length)],
        spin: (_rng.nextDouble() - 0.5) * 14,
        gravity: 520,
      ));
    }
    _wake?.call();
  }

  /// Floating text such as "+1" or "+5". Shown even with reduced motion,
  /// because it carries information (but it does not drift).
  void text(Offset at, String value, {Color color = BoopColors.ink, double size = 24}) {
    _items.add(_Particle(
      kind: _Kind.text,
      pos: at,
      vel: muted ? Offset.zero : const Offset(0, -70),
      life: 0.8,
      size: size,
      color: color,
      text: value,
    ));
    _wake?.call();
  }

  void _step(double dt) {
    for (final p in _items) {
      p.age += dt;
      p.vel = Offset(p.vel.dx * (1 - 1.2 * dt), p.vel.dy * (1 - 1.2 * dt) + p.gravity * dt);
      p.pos += p.vel * dt;
      p.angle += p.spin * dt;
    }
    _items.removeWhere((p) => p.dead);
  }

  void clear() => _items.clear();
}

class ParticleLayer extends StatefulWidget {
  const ParticleLayer({super.key, required this.controller});
  final ParticleController controller;

  @override
  State<ParticleLayer> createState() => _ParticleLayerState();
}

class _ParticleLayerState extends State<ParticleLayer> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    widget.controller._wake = _wake;
  }

  void _wake() {
    if (!_ticker.isActive && mounted) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero ? 1 / 60 : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    widget.controller._step(dt.clamp(0, 0.05));
    if (widget.controller.isEmpty) _ticker.stop();
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller._wake = null;
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(List.of(widget.controller._items), Directionality.of(context)),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.items, this.dir);
  final List<_Particle> items;
  final TextDirection dir;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in items) {
      final fade = p.t < 0.7 ? 1.0 : 1 - (p.t - 0.7) / 0.3;
      switch (p.kind) {
        case _Kind.heart:
          final s = p.size * (0.6 + 0.4 * math.min(1, p.t * 5));
          _heart(canvas, p.pos, s, p.color.withValues(alpha: fade));
        case _Kind.sparkle:
          _sparkle(canvas, p.pos, p.size * (1 - p.t * 0.6), p.color.withValues(alpha: fade));
        case _Kind.confetti:
          canvas.save();
          canvas.translate(p.pos.dx, p.pos.dy);
          canvas.rotate(p.angle);
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55), const Radius.circular(2)),
            Paint()..color = p.color.withValues(alpha: fade),
          );
          canvas.restore();
        case _Kind.text:
          final tp = TextPainter(
            text: TextSpan(
              text: p.text,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: p.size,
                fontWeight: FontWeight.w700,
                color: p.color.withValues(alpha: fade),
                shadows: [Shadow(color: Colors.white.withValues(alpha: fade), blurRadius: 0, offset: const Offset(0, 2))],
              ),
            ),
            textDirection: dir,
          )..layout();
          tp.paint(canvas, p.pos - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  static void _heart(Canvas canvas, Offset c, double s, Color color) {
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.35)
      ..cubicTo(c.dx - s * 0.75, c.dy - s * 0.15, c.dx - s * 0.35, c.dy - s * 0.65, c.dx, c.dy - s * 0.22)
      ..cubicTo(c.dx + s * 0.35, c.dy - s * 0.65, c.dx + s * 0.75, c.dy - s * 0.15, c.dx, c.dy + s * 0.35)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = BoopColors.ink.withValues(alpha: color.a * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  static void _sparkle(Canvas canvas, Offset c, double r, Color color) {
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
