import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/test_env.dart';
import '../game/critters.dart';
import 'critter_painter.dart';
import 'theme.dart';

/// A damped spring toward [target]. Semi-implicit Euler; stable at 60–120 Hz.
class _Spring {
  _Spring(this.value, {this.stiffness = 420, this.damping = 16}) : target = value;
  double value;
  double target;
  double velocity = 0;
  final double stiffness;
  final double damping;

  void step(double dt) {
    final a = -stiffness * (value - target) - damping * velocity;
    velocity += a * dt;
    value += velocity * dt;
  }

  bool get atRest => (value - target).abs() < 0.0008 && velocity.abs() < 0.004;

  void snap() {
    value = target;
    velocity = 0;
  }
}

/// Lets the owner trigger reactions that are not touch-driven.
class CritterStageController {
  _CritterStageState? _state;

  void sneeze() => _state?._sneeze();
  void boop() => _state?._boopAnim();
  void celebrate() => _state?._celebrate();
}

/// The boopable critter. Pointer handling is done here (not by a
/// GestureDetector) so a boop registers on finger-DOWN with zero latency and
/// several fingers can boop at once.
class CritterStage extends StatefulWidget {
  const CritterStage({
    super.key,
    required this.species,
    required this.onBoop,
    this.onBodyTap,
    this.onHugStart,
    this.onHugging,
    this.onRelease,
    this.idle,
    this.reduceMotion = false,
    this.controller,
    this.semanticLabel,
  });

  final CritterSpecies species;

  /// A boop on the nose, at [local] (stage coordinates).
  final void Function(Offset local) onBoop;
  final void Function(Offset local)? onBodyTap;
  final void Function(Offset local)? onHugStart;

  /// Repeats every [_CritterStageState.hugHeartEvery] while a hug is held.
  final void Function(Offset local)? onHugging;

  /// Blinking and dozing off. null = on a device, off under `flutter test`.
  final bool? idle;

  /// The finger left after a drag (for a "boing").
  final VoidCallback? onRelease;
  final bool reduceMotion;
  final CritterStageController? controller;
  final String? semanticLabel;

  @override
  State<CritterStage> createState() => _CritterStageState();
}

class _PointerInfo {
  _PointerInfo(this.start, this.time);
  final Offset start;
  final Duration time;
  Offset last = Offset.zero;
  bool onNose = false;
  bool dragging = false;
  bool hugging = false;
  Duration lastHugBeat = Duration.zero;
}

class _CritterStageState extends State<CritterStage> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _rng = math.Random();
  final _squashX = _Spring(1, stiffness: 520, damping: 14);
  final _squashY = _Spring(1, stiffness: 520, damping: 14);
  final _tilt = _Spring(0, stiffness: 260, damping: 7);
  final _shearX = _Spring(0, stiffness: 300, damping: 12);
  final _shearY = _Spring(0, stiffness: 300, damping: 12);
  final _lookX = _Spring(0, stiffness: 90, damping: 14);
  final _lookY = _Spring(0, stiffness: 90, damping: 14);

  final Map<int, _PointerInfo> _pointers = {};
  Duration _now = Duration.zero;
  Duration _lastTick = Duration.zero;
  Duration _lastInput = Duration.zero;
  Duration _happyUntil = Duration.zero;
  Duration _surprisedUntil = Duration.zero;
  Duration _nextBlink = const Duration(seconds: 3);
  Duration _blinkStart = const Duration(days: 1);
  double _blush = 0;
  double _noseFlash = 0;
  Size _size = Size.zero;

  /// Blinking and dozing off run forever on a device. Under `flutter test`
  /// they are off so springs can settle (pumpAndSettle). Breathing is motion,
  /// so Reduce motion stops it; the faces stay.
  bool get _idleLoop => widget.idle ?? !skipDeviceOnlyWork;
  bool get _breathing => _idleLoop && !widget.reduceMotion;

  static const sleepyAfter = Duration(seconds: 30);
  static const asleepAfter = Duration(seconds: 60);
  static const hugAfter = Duration(milliseconds: 600);
  static const hugHeartEvery = Duration(milliseconds: 350);
  static const dragSlop = 10.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    widget.controller?._state = this;
    _ensureTicking();
  }

  @override
  void didUpdateWidget(CritterStage old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._state = null;
      widget.controller?._state = this;
    }
    if (old.species != widget.species) {
      // A new friend arrives with a little hop.
      _squashY.value = 0.85;
      _squashX.value = 1.1;
      _lastInput = _now;
      _ensureTicking();
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    _wake?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ time

  bool get _springsAtRest => [_squashX, _squashY, _tilt, _shearX, _shearY, _lookX, _lookY].every((s) => s.atRest);

  bool get _transient => _blush > 0.01 || _noseFlash > 0.01 || _now < _happyUntil || _now < _surprisedUntil || _pointers.isNotEmpty;

  /// Wakes a stopped ticker for the next blink or doze-off (Reduce motion).
  Timer? _wake;

  void _ensureTicking() {
    _wake?.cancel();
    _wake = null;
    if (!_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero ? 1 / 60 : ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastTick = elapsed;
    _now += Duration(microseconds: (dt * 1e6).round());
    for (final s in [_squashX, _squashY, _tilt, _shearX, _shearY, _lookX, _lookY]) {
      s.step(dt);
    }
    _checkHugs();
    if (_pointers.values.any((p) => p.hugging)) _blush = 1;
    _blush = math.max(0, _blush - dt * 1.4);
    _noseFlash = math.max(0, _noseFlash - dt * 4);
    if (_idleLoop && _now >= _nextBlink && _faceBase == CritterFace.open) {
      _blinkStart = _now;
      _nextBlink = _now + Duration(milliseconds: 2000 + _rng.nextInt(3000));
    }
    if (_now - _lastInput > const Duration(seconds: 2)) {
      _lookX.target = 0;
      _lookY.target = 0;
    }
    // Without breathing there is nothing to draw between events, so the
    // ticker sleeps until the next blink or face change instead of repainting.
    if (!_breathing && _springsAtRest && !_transient && _blinkAmount == 0) {
      for (final s in [_squashX, _squashY, _tilt, _shearX, _shearY, _lookX, _lookY]) {
        s.snap();
      }
      _ticker.stop();
      if (_idleLoop) _scheduleWake();
    }
    setState(() {});
  }

  void _scheduleWake() {
    final next = [
      if (_faceBase == CritterFace.open) _nextBlink,
      _lastInput + sleepyAfter,
      _lastInput + asleepAfter,
    ].where((t) => t > _now).fold<Duration?>(null, (a, t) => a == null || t < a ? t : a);
    if (next == null) return;
    final wait = next - _now;
    _wake = Timer(wait, () {
      _now += wait;
      _ensureTicking();
    });
  }

  // ------------------------------------------------------------------ face

  CritterFace get _faceBase {
    if (_pointers.values.any((p) => p.hugging)) return CritterFace.hug;
    if (_now < _surprisedUntil) return CritterFace.surprised;
    if (_now < _happyUntil) return CritterFace.happy;
    if (_idleLoop) {
      final idle = _now - _lastInput;
      if (idle > asleepAfter) return CritterFace.asleep;
      if (idle > sleepyAfter) return CritterFace.sleepy;
    }
    return CritterFace.open;
  }

  double get _blinkAmount {
    final t = (_now - _blinkStart).inMilliseconds;
    if (t < 0 || t > 160) return 0;
    return t < 80 ? t / 80 : (160 - t) / 80;
  }

  bool get isDozing => _faceBase == CritterFace.sleepy || _faceBase == CritterFace.asleep;

  CritterPose _pose() {
    var sx = _squashX.value, sy = _squashY.value;
    if (_breathing) {
      final breath = math.sin(_now.inMilliseconds / 1000 * (isDozing ? 1.6 : 2.6));
      sy *= 1 + breath * (isDozing ? 0.022 : 0.014);
      sx *= 1 - breath * 0.006;
    }
    return CritterPose(
      squashX: sx,
      squashY: sy,
      tilt: _tilt.value,
      shear: Offset(_shearX.value, _shearY.value),
      face: _faceBase,
      look: Offset(_lookX.value, _lookY.value),
      blink: _blinkAmount,
      blush: _blush,
      noseFlash: _noseFlash,
    );
  }

  // --------------------------------------------------------------- actions

  void _touched(Offset p) {
    _lastInput = _now;
    if (_size.isEmpty) return;
    final g = CritterGeometry(_size.shortestSide, widget.species);
    final d = (p - g.center);
    _lookX.target = (d.dx / g.a).clamp(-1.0, 1.0);
    _lookY.target = (d.dy / g.b).clamp(-1.0, 1.0);
    _ensureTicking();
  }

  void _boopAnim() {
    if (widget.reduceMotion) {
      _squashX.value = 0.96;
      _squashY.value = 0.96;
    } else {
      _squashX.value = 1.16;
      _squashY.value = 0.8;
      _squashY.velocity = -1.5;
    }
    _happyUntil = _now + const Duration(milliseconds: 280);
    _blush = 1;
    _noseFlash = 1;
    _ensureTicking();
  }

  void _wobble(Offset p) {
    if (widget.reduceMotion) return;
    final g = CritterGeometry(_size.shortestSide, widget.species);
    final dir = (p.dx - g.cx).sign;
    _tilt.velocity += -dir * 3.2;
    _squashY.value = 0.93;
    _happyUntil = _now + const Duration(milliseconds: 400);
    _ensureTicking();
  }

  void _sneeze() {
    _surprisedUntil = _now + const Duration(milliseconds: 650);
    if (!widget.reduceMotion) {
      _squashY.value = 1.18;
      _squashX.value = 0.88;
      _tilt.velocity += (_rng.nextBool() ? 1 : -1) * 2.0;
    }
    _ensureTicking();
  }

  void _celebrate() {
    _happyUntil = _now + const Duration(milliseconds: 900);
    _blush = 1;
    if (!widget.reduceMotion) {
      _squashY.value = 0.78;
      _squashX.value = 1.15;
    }
    _lastInput = _now;
    _ensureTicking();
  }

  // --------------------------------------------------------------- pointers

  void _down(PointerDownEvent e) {
    final p = e.localPosition;
    final g = CritterGeometry(_size.shortestSide, widget.species);
    final info = _PointerInfo(p, _now)..last = p;
    final wasDozing = isDozing;
    _touched(p);
    if (g.hitsNose(p)) {
      info.onNose = true;
      _pointers[e.pointer] = info;
      _boopAnim();
      widget.onBoop(p);
      return;
    }
    if (!g.hitsBody(p)) return; // empty space around the critter
    _pointers[e.pointer] = info;
    if (wasDozing) _wobble(p);
    _ensureTicking(); // the hug check runs on the ticker (no Timers: tests stay clean)
  }

  /// A finger resting on the body, unmoved, for [hugAfter] becomes a hug.
  void _checkHugs() {
    for (final i in _pointers.values) {
      if (!i.onNose && !i.dragging && !i.hugging && _now - i.time >= hugAfter) {
        i.hugging = true;
        i.lastHugBeat = _now;
        _blush = 1;
        widget.onHugStart?.call(i.last);
      } else if (i.hugging && _now - i.lastHugBeat >= hugHeartEvery) {
        i.lastHugBeat = _now;
        widget.onHugging?.call(i.last);
      }
    }
  }

  void _move(PointerMoveEvent e) {
    final info = _pointers[e.pointer];
    if (info == null) return;
    info.last = e.localPosition;
    _touched(e.localPosition);
    if (info.onNose || info.hugging) return;
    final delta = e.localPosition - info.start;
    if (!info.dragging && delta.distance > dragSlop) info.dragging = true;
    if (info.dragging && !widget.reduceMotion) {
      final s = _size.shortestSide;
      _shearX.target = (delta.dx / (s * 0.5)).clamp(-0.6, 0.6);
      _shearY.target = (delta.dy / (s * 0.6)).clamp(-0.35, 0.35);
      _ensureTicking();
    }
  }

  void _up(PointerEvent e) {
    final info = _pointers.remove(e.pointer);
    if (info == null) return;
    _lastInput = _now;
    if (info.dragging) {
      _shearX.target = 0;
      _shearY.target = 0;
      _shearX.velocity -= _shearX.value * 4;
      widget.onRelease?.call();
    } else if (!info.onNose && !info.hugging && e is PointerUpEvent) {
      _wobble(info.last);
      widget.onBodyTap?.call(info.last);
    }
    _ensureTicking();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pose = _pose();
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size.square(math.min(constraints.maxWidth, constraints.maxHeight));
        final g = CritterGeometry(_size.shortestSide, widget.species);
        return Center(
          child: SizedBox.fromSize(
            size: _size,
            child: Semantics(
              label: widget.semanticLabel,
              button: true,
              onTap: () {
                _boopAnim();
                widget.onBoop(g.nose);
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _down,
                onPointerMove: _move,
                onPointerUp: _up,
                onPointerCancel: _up,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(painter: CritterPainter(species: widget.species, pose: pose)),
                      ),
                    ),
                    if (isDozing)
                      _Zzz(at: Offset(g.cx + g.a * 0.7, g.cy - g.b * 1.05), size: _size.shortestSide, t: widget.reduceMotion ? Duration.zero : _now),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "z z z" drifting up from a dozing critter.
class _Zzz extends StatelessWidget {
  const _Zzz({required this.at, required this.size, required this.t});
  final Offset at;
  final double size;
  final Duration t;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < 3; i++) {
      final phase = ((t.inMilliseconds / 1800) + i / 3) % 1.0;
      final fs = size * (0.05 + i * 0.012);
      children.add(Positioned(
        left: at.dx + phase * size * 0.08 + i * size * 0.03,
        top: at.dy - phase * size * 0.18 - i * size * 0.02,
        child: Opacity(
          opacity: (1 - phase).clamp(0.0, 1.0),
          child: Text('z', style: TextStyle(fontFamily: 'Fredoka', fontSize: fs, fontWeight: FontWeight.w700, color: BoopColors.inkSoft)),
        ),
      ));
    }
    return Positioned.fill(child: IgnorePointer(child: Stack(clipBehavior: Clip.none, children: children)));
  }
}
