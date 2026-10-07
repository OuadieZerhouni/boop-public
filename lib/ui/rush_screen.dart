import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../audio/sfx.dart';
import '../core/app_services.dart';
import '../core/screenshot_scene.dart';
import '../game/critters.dart';
import '../game/rush.dart';
import '../l10n/l10n.dart';
import 'critter_painter.dart';
import 'names.dart';
import 'particles.dart';
import 'theme.dart';
import 'widgets.dart';

enum _Phase { intro, playing, over }

class RushScreen extends StatefulWidget {
  const RushScreen({super.key, this.seed});

  /// Fixed seed for tests; null = random each round.
  final int? seed;

  @override
  State<RushScreen> createState() => _RushScreenState();
}

class _RushScreenState extends State<RushScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _particles = ParticleController();
  final _rng = math.Random();
  final _gridKey = GlobalKey();
  _Phase _phase = _Phase.intro;
  RushGame? _game;
  Duration _elapsed = Duration.zero;
  int _lastTickSecond = -1;
  bool _newBest = false;
  int _earned = 0;
  final Map<String, int> _boopedBy = {};

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick); // eager: a lazy ticker first touched in dispose throws
    if (debugScene == Scene.rush) WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _start() : null);
  }

  /// Screenshot scene: boops each awake critter once it is fully up.
  void _botTap(RushGame g) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final cell = box.size.width / 3;
    for (var i = 0; i < 9; i++) {
      final p = g.slots[i];
      if (p == null || p.kind == PopKind.sleepy || _elapsed - p.bornAt < const Duration(milliseconds: 450)) continue;
      _tap(i, Offset((i % 3 + 0.5) * cell, (i ~/ 3 + 0.35) * cell));
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  AppServices get _s => AppScope.of(context);

  void _start() {
    final s = _s;
    final p = s.progress.value;
    final ids = [for (final c in kCritters) if (p.isUnlocked(c)) c.id];
    _game = RushGame(
      critterIds: ids,
      duration: Duration(seconds: s.remote.value.rushDurationSec),
      seed: widget.seed ?? _rng.nextInt(1 << 30),
    );
    _elapsed = Duration.zero;
    _lastTickSecond = -1;
    _boopedBy.clear();
    _newBest = false;
    _earned = 0;
    _particles.clear();
    s.sound.play(Sfx.whoosh);
    s.sound.medium();
    setState(() => _phase = _Phase.playing);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final g = _game;
    if (g == null) return;
    _elapsed = elapsed;
    g.advance(elapsed);
    if (debugScene == Scene.rush) _botTap(g);
    final left = g.remaining.inSeconds;
    if (!g.isOver && left < 3 && left != _lastTickSecond && g.remaining.inMilliseconds % 1000 > 0) {
      _lastTickSecond = left;
      _s.sound.play(Sfx.tick);
    }
    if (g.isOver) {
      _ticker.stop();
      _finish(g);
    }
    setState(() {});
  }

  void _finish(RushGame g) {
    final s = _s;
    _earned = g.goodBoops;
    // Credit each critter with the boops it actually received.
    _boopedBy.forEach((id, n) {
      if (n > 0) s.boop(id, n: n);
    });
    _newBest = s.progress.recordRush(g.score);
    s.sound.play(_newBest ? Sfx.fanfare : Sfx.chime);
    s.sound.heavy();
    _phase = _Phase.over;
    if (_newBest) {
      final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) _particles.confetti(box.size.center(Offset.zero), count: 50, spread: 1.3);
    }
  }

  void _tap(int hole, Offset localInGrid) {
    final g = _game;
    if (g == null || _phase != _Phase.playing) return;
    final popup = g.slots[hole];
    final r = g.tap(hole, _elapsed);
    final s = _s;
    switch (r.kind) {
      case TapKind.hit:
        s.sound.boop(math.min(13, 4 + r.streak ~/ 2));
        s.sound.light();
        _boopedBy.update(popup!.critterId, (v) => v + 1, ifAbsent: () => 1);
        _particles.text(localInGrid, '+${r.points}', color: BoopColors.heart);
        _particles.hearts(localInGrid, count: 1);
      case TapKind.golden:
        s.sound.play(Sfx.golden);
        s.sound.medium();
        _boopedBy.update(popup!.critterId, (v) => v + 1, ifAbsent: () => 1);
        _particles.text(localInGrid, '+${r.points}', color: const Color(0xFFE09A00), size: 30);
        _particles.sparkles(localInGrid, count: 10, color: BoopColors.gold);
      case TapKind.sleepy:
        s.sound.play(Sfx.oops);
        s.sound.heavy();
        _particles.text(localInGrid, r.points == 0 ? 'z' : '${r.points}', color: const Color(0xFF6E7DA8), size: 28);
      case TapKind.miss:
      case TapKind.ignored:
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: Listenable.merge([s.remote, s.settings, s.progress]),
      builder: (context, _) {
        _particles.muted = motionReduced(context, s.settings.value.reduceMotion);
        if (!s.remote.value.rushEnabled && _phase != _Phase.playing) {
          return SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: StickerCard(
                  color: BoopColors.creamDeep,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('😴', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(l.rushResting, key: const ValueKey('rush-resting'), textAlign: TextAlign.center, style: display(context, 20)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        final g = _game;
        final best = s.progress.value.bestRush;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(l.rushTitle, style: display(context, 30)),
                    const Spacer(),
                    _Stat(label: l.rushBest, value: '$best'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _Stat(label: l.rushScore, value: '${g?.score ?? 0}', big: true, key: const ValueKey('rush-score')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.rushTime(((g?.remaining.inMilliseconds ?? s.remote.value.rushDurationSec * 1000) / 1000).ceil()),
                              style: body(context, 14, weight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          StickerProgress(value: g == null ? 1 : 1 - g.progress, color: (g != null && g.remaining.inSeconds < 5) ? BoopColors.heart : BoopColors.mint),
                        ],
                      ),
                    ),
                    if (g != null && g.streak >= 3) ...[
                      const SizedBox(width: 10),
                      Pill(color: BoopColors.butter, child: Text(l.rushStreak(g.streak))),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final side = math.min(box.maxWidth - 24, box.maxHeight - 12).clamp(120.0, 440.0);
                    return Center(
                      child: SizedBox.square(
                        dimension: side,
                        child: Stack(
                          key: _gridKey,
                          clipBehavior: Clip.none,
                          children: [
                            _Meadow(game: g, side: side, onTap: _tap),
                            Positioned.fill(child: ParticleLayer(controller: _particles)),
                            if (_phase == _Phase.intro) Positioned.fill(child: _Intro(onStart: _start)),
                            if (_phase == _Phase.over && g != null)
                              Positioned.fill(
                                child: _Results(score: g.score, best: best, newBest: _newBest, earned: _earned, onAgain: _start),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.label, required this.value, this.big = false});
  final String label;
  final String value;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return StickerCard(
      padding: EdgeInsets.symmetric(horizontal: big ? 16 : 12, vertical: 6),
      color: big ? BoopColors.butter : Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: body(context, 12, color: BoopColors.inkSoft)),
          Text(value, style: display(context, big ? 28 : 20)),
        ],
      ),
    );
  }
}

/// The 3×3 field of bushes.
class _Meadow extends StatelessWidget {
  const _Meadow({required this.game, required this.side, required this.onTap});
  final RushGame? game;
  final double side;
  final void Function(int hole, Offset localInGrid) onTap;

  @override
  Widget build(BuildContext context) {
    final cell = side / 3;
    final slots = game?.slots ?? List<Popup?>.filled(9, null);
    final now = game?.elapsed ?? Duration.zero;
    return Stack(
      children: [
        for (var i = 0; i < 9; i++)
          Positioned(
            left: (i % 3) * cell,
            top: (i ~/ 3) * cell,
            width: cell,
            height: cell,
            // An empty bush is nothing to boop, so VoiceOver skips it.
            child: ExcludeSemantics(
              excluding: slots[i] == null,
              child: Semantics(
                label: _label(context, slots[i]),
                button: true,
                child: GestureDetector(
                  key: ValueKey('bush-$i'),
                  behavior: HitTestBehavior.opaque,
                  // A VoiceOver double-tap has no pointer (kind == null): aim at the bush's middle.
                  onTapDown: (d) => onTap(i, Offset((i % 3) * cell, (i ~/ 3) * cell) + (d.kind == null ? Offset(cell / 2, cell / 2) : d.localPosition)),
                  child: _Bush(popup: slots[i], now: now),
                ),
              ),
            ),
          ),
      ],
    );
  }

  static String? _label(BuildContext context, Popup? p) {
    if (p == null) return null;
    final l = context.l10n;
    final name = critterName(l, critterById(p.critterId));
    return switch (p.kind) {
      PopKind.awake => name,
      PopKind.sleepy => '$name. ${l.rushRuleSleepy}',
      PopKind.golden => '$name. ${l.rushRuleGolden}',
    };
  }
}

class _Bush extends StatelessWidget {
  const _Bush({required this.popup, required this.now});
  final Popup? popup;
  final Duration now;

  @override
  Widget build(BuildContext context) {
    final p = popup;
    double rise = 0;
    if (p != null) {
      final age = (now - p.bornAt).inMilliseconds;
      final left = (p.diesAt - now).inMilliseconds;
      rise = math.min(1.0, age / 140) * math.min(1.0, left / 140);
      rise = Curves.easeOut.transform(rise.clamp(0.0, 1.0));
    }
    return Padding(
      padding: const EdgeInsets.all(5),
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Hole + critter, clipped at the bush line so it "pops out".
            Positioned.fill(
              child: ClipRect(
                clipper: _TopClip(w * 0.78),
                child: Stack(
                  children: [
                    Positioned(
                      left: w * 0.12,
                      top: w * 0.58,
                      width: w * 0.76,
                      height: w * 0.22,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B4E3D),
                          borderRadius: BorderRadius.circular(w),
                        ),
                      ),
                    ),
                    if (p != null)
                      Positioned(
                        left: w * 0.08,
                        width: w * 0.84,
                        height: w * 0.84,
                        top: w * 0.74 - rise * w * 0.9, // fully up: the whole face clears the bush
                        child: ExcludeSemantics(
                          child: CustomPaint(
                            painter: CritterPainter(
                              species: critterById(p.critterId),
                              golden: p.kind == PopKind.golden,
                              shadow: false,
                              pose: CritterPose(
                                face: p.kind == PopKind.sleepy ? CritterFace.asleep : CritterFace.open,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // The bush in front.
            Positioned(
              left: 0,
              right: 0,
              top: w * 0.66,
              height: w * 0.32,
              child: CustomPaint(painter: _BushPainter()),
            ),
            if (p != null && p.kind == PopKind.sleepy && rise > 0.8)
              Positioned(
                right: w * 0.08,
                top: w * 0.02,
                child: Text('z', style: TextStyle(fontFamily: 'Fredoka', fontSize: w * 0.18, fontWeight: FontWeight.w700, color: BoopColors.inkSoft)),
              ),
          ],
        );
      }),
    );
  }
}

class _TopClip extends CustomClipper<Rect> {
  _TopClip(this.bottom);
  final double bottom;
  @override
  Rect getClip(Size size) => Rect.fromLTRB(-size.width, -size.height, size.width * 2, bottom);
  @override
  bool shouldReclip(_TopClip old) => old.bottom != bottom;
}

class _BushPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()..moveTo(0, h);
    final bumps = [(0.12, 0.42, 0.16), (0.32, 0.18, 0.2), (0.55, 0.12, 0.21), (0.78, 0.22, 0.19), (0.94, 0.45, 0.14)];
    for (final (x, y, r) in bumps) {
      path.addOval(Rect.fromCircle(center: Offset(x * w, y * h + r * w * 0.5), radius: r * w));
    }
    path.addRect(Rect.fromLTRB(0, h * 0.5, w, h));
    final outline = Paint()
      ..color = BoopColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, outline);
    canvas.drawPath(path, Paint()..color = BoopColors.meadowDeep);
    // Lighter tops for depth.
    for (final (x, y, r) in bumps) {
      canvas.drawCircle(Offset(x * w - r * w * 0.2, y * h + r * w * 0.35), r * w * 0.45, Paint()..color = BoopColors.meadow);
    }
  }

  @override
  bool shouldRepaint(_BushPainter oldDelegate) => false;
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: StickerCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.rushIntro, textAlign: TextAlign.center, style: display(context, 20)),
              const SizedBox(height: 12),
              _Rule(icon: '😴', text: l.rushRuleSleepy),
              const SizedBox(height: 6),
              _Rule(icon: '⭐', text: l.rushRuleGolden),
              const SizedBox(height: 14),
              StickerButton(
                key: const ValueKey('rush-start'),
                onPressed: onStart,
                child: Text(l.rushStart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.icon, required this.text});
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Flexible(child: Text(text, style: body(context, 15))),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.score, required this.best, required this.newBest, required this.earned, required this.onAgain});
  final int score;
  final int best;
  final bool newBest;
  final int earned;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: StickerCard(
          key: const ValueKey('rush-results'),
          color: newBest ? BoopColors.butter : Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(newBest ? l.rushNewBest : l.rushOver, style: display(context, 26)),
              const SizedBox(height: 6),
              Text('$score', style: display(context, 56, weight: FontWeight.w700)),
              Text('${l.rushBest}: $best', style: body(context, 15, color: BoopColors.inkSoft)),
              const SizedBox(height: 8),
              Text(l.rushBoopsEarned(earned), textAlign: TextAlign.center, style: body(context, 15, weight: FontWeight.w800)),
              const SizedBox(height: 14),
              StickerButton(key: const ValueKey('rush-again'), onPressed: onAgain, child: Text(l.rushPlayAgain)),
            ],
          ),
        ),
      ),
    );
  }
}
