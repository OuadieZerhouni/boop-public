import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// A rounded "sticker": cream-white fill, cocoa outline, hard offset shadow.
class StickerCard extends StatelessWidget {
  const StickerCard({
    super.key,
    required this.child,
    this.color = BoopColors.card,
    this.padding = const EdgeInsets.all(16),
    this.radius = kRadius,
    this.shadow = true,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: const BorderSide(color: BoopColors.ink, width: kOutline),
    );
    // A Material (not a coloured DecoratedBox) so ListTiles inside keep their ink.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ? [BoxShadow(color: BoopColors.ink, offset: kShadowOffset)] : null,
      ),
      child: Material(
        color: color,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A chunky button that physically presses down onto its shadow.
class StickerButton extends StatefulWidget {
  const StickerButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color = BoopColors.heart,
    this.foreground = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    this.radius = 22,
    this.semanticLabel,
    this.expand = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final Color foreground;
  final EdgeInsetsGeometry padding;
  final double radius;
  final String? semanticLabel;
  final bool expand;

  @override
  State<StickerButton> createState() => _StickerButtonState();
}

class _StickerButtonState extends State<StickerButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final dy = _down ? kShadowOffset.dy : 0.0;
    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      transform: Matrix4.translationValues(0, dy, 0),
      decoration: BoxDecoration(
        color: enabled ? widget.color : Color.lerp(widget.color, Colors.white, 0.5),
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: BoopColors.ink, width: kOutline),
        boxShadow: _down ? null : [BoxShadow(color: BoopColors.ink, offset: kShadowOffset)],
      ),
      padding: widget.padding,
      child: DefaultTextStyle.merge(
        style: display(context, 19, color: widget.foreground),
        textAlign: TextAlign.center,
        child: IconTheme.merge(
          data: IconThemeData(color: widget.foreground, size: 22),
          child: Center(widthFactor: widget.expand ? null : 1, child: widget.child),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: widget.onPressed,
        child: Padding(padding: EdgeInsets.only(bottom: kShadowOffset.dy), child: button),
      ),
    );
  }
}

/// A small rounded label.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.child, this.color = BoopColors.butter, this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6)});
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BoopColors.ink, width: 2.5),
      ),
      child: Padding(padding: padding, child: DefaultTextStyle.merge(style: display(context, 15), child: child)),
    );
  }
}

/// A round progress ring (daily goal).
class GoalRing extends StatelessWidget {
  const GoalRing({super.key, required this.progress, required this.child, this.size = 64, this.done = false});
  final double progress;
  final Widget child;
  final double size;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress.clamp(0, 1), done),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.p, this.done);
  final double p;
  final bool done;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 5;
    canvas.drawCircle(c, r + 3, Paint()..color = BoopColors.ink);
    canvas.drawCircle(c, r, Paint()..color = done ? BoopColors.butter : Colors.white);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = BoopColors.creamDeep;
    canvas.drawCircle(c, r - 5, track);
    if (p > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - 5),
        -math.pi / 2,
        2 * math.pi * p,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = BoopColors.heart,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.p != p || old.done != done;
}

/// Horizontal progress bar with the sticker look.
class StickerProgress extends StatelessWidget {
  const StickerProgress({super.key, required this.value, this.color = BoopColors.mint, this.height = 16});
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height),
        border: Border.all(color: BoopColors.ink, width: 2.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            heightFactor: 1,
            child: ColoredBox(color: color),
          ),
        ),
      ),
    );
  }
}
